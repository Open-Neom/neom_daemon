import 'dart:async';
import 'package:neom_cli/neom_cli.dart';
import 'package:neom_core/app_config.dart';

import '../../domain/models/command_type.dart';
import '../../domain/models/daemon_command_result.dart';
import '../../utils/constants/daemon_constants.dart';

/// Command router for [NeomDaemonServer].
///
/// Parses, validates, and executes shell and background tasks
/// via `neom_cli` or registered domain handlers.
class DaemonCommandRouter {
  static final _shellPatterns = RegExp(
    r'^(ls|cd|pwd|mkdir|rmdir|rm|cp|mv|cat|echo|grep|find|chmod|chown|'
    r'touch|head|tail|wc|sort|uniq|tar|zip|unzip|curl|wget|ping|'
    r'git|flutter|dart|npm|node|python|pip|brew|apt|yum|docker|'
    r'make|cargo|go|rustc|javac|gcc|clang|'
    r'open|xdg-open|code|subl)\b',
    caseSensitive: false,
  );

  /// Classify a prompt as shell command or AI prompt.
  static CommandType classify(String prompt) {
    final trimmed = prompt.trim();
    for (final prefix in DaemonConstants.shellPrefixes) {
      if (trimmed.startsWith(prefix)) return CommandType.shellDirect;
    }
    if (_shellPatterns.hasMatch(trimmed)) return CommandType.shellDirect;
    return CommandType.aiPrompt;
  }

  /// Extract the raw shell command (strip prefix if present).
  static String extractShellCommand(String prompt) {
    final trimmed = prompt.trim();
    for (final prefix in DaemonConstants.shellPrefixes) {
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
    for (final blocked in DaemonConstants.forbiddenCommandPrefixes) {
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
