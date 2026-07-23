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
