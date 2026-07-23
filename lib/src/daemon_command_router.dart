import 'dart:async';
import 'package:neom_core/app_config.dart';
import 'package:neom_cli/neom_cli.dart';

/// Classifies incoming remote commands as shell-direct or AI prompts.
enum CommandType { shellDirect, aiPrompt }

/// Result of a command routed through [DaemonCommandRouter].
class DaemonCommandResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  final Duration duration;

  const DaemonCommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.duration,
  });

  bool get isSuccess => exitCode == 0;

  Map<String, dynamic> toJson() => {
        'exitCode': exitCode,
        'stdout': stdout,
        'stderr': stderr,
        'durationMs': duration.inMilliseconds,
      };
}

/// Command router for [NeomDaemonServer].
///
/// Parses, validates, and executes shell and background tasks
/// via `neom_cli` or registered domain handlers.
class DaemonCommandRouter {
  static const _shellPrefixes = ['\$', '!'];

  static final _shellPatterns = RegExp(
    r'^(ls|cd|pwd|mkdir|rmdir|rm|cp|mv|cat|echo|grep|find|chmod|chown|'
    r'touch|head|tail|wc|sort|uniq|tar|zip|unzip|curl|wget|ping|'
    r'git|flutter|dart|npm|node|python|pip|brew|apt|yum|docker|'
    r'make|cargo|go|rustc|javac|gcc|clang|'
    r'open|xdg-open|code|subl)\b',
    caseSensitive: false,
  );

  /// Blocked commands for defense-in-depth safety
  static const Set<String> _forbiddenPrefixes = {
    'rm -rf /',
    'mkfs',
    'dd if=',
    ':(){ :|:& };:',
    'format c:',
  };

  /// Classify a prompt as shell command or AI prompt.
  static CommandType classify(String prompt) {
    final trimmed = prompt.trim();
    for (final prefix in _shellPrefixes) {
      if (trimmed.startsWith(prefix)) return CommandType.shellDirect;
    }
    if (_shellPatterns.hasMatch(trimmed)) return CommandType.shellDirect;
    return CommandType.aiPrompt;
  }

  /// Extract the raw shell command (strip prefix if present).
  static String extractShellCommand(String prompt) {
    final trimmed = prompt.trim();
    for (final prefix in _shellPrefixes) {
      if (trimmed.startsWith(prefix)) {
        return trimmed.substring(prefix.length).trim();
      }
    }
    return trimmed;
  }

  /// Dispatches and executes a command string safely.
  Future<DaemonCommandResult> dispatch(
    String command, {
    String? workingDirectory,
  }) async {
    final trimmed = command.trim();
    if (trimmed.isEmpty) {
      return const DaemonCommandResult(
        exitCode: 1,
        stdout: '',
        stderr: 'Error: Comando vacío',
        duration: Duration.zero,
      );
    }

    // Safety check
    final lower = trimmed.toLowerCase();
    for (final blocked in _forbiddenPrefixes) {
      if (lower.startsWith(blocked)) {
        AppConfig.logger.w('DaemonCommandRouter: Blocked dangerous command "$trimmed"');
        return DaemonCommandResult(
          exitCode: 126,
          stdout: '',
          stderr: 'Acción bloqueada por políticas de seguridad del demonio: $trimmed',
          duration: Duration.zero,
        );
      }
    }

    final stopwatch = Stopwatch()..start();
    try {
      AppConfig.logger.d('DaemonCommandRouter executing: $trimmed');
      final result = await CliExecutor.run(
        trimmed,
        workingDirectory: workingDirectory,
      );
      stopwatch.stop();

      return DaemonCommandResult(
        exitCode: result.exitCode,
        stdout: result.stdout,
        stderr: result.stderr,
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return DaemonCommandResult(
        exitCode: 1,
        stdout: '',
        stderr: 'Error al ejecutar comando: $e',
        duration: stopwatch.elapsed,
      );
    }
  }
}
