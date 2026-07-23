/// Telemetry and health status report for [NeomDaemonServer].
class DaemonStatus {
  final bool isRunning;
  final int port;
  final int activeTaskCount;
  final double cpuUsagePercent;
  final double memoryUsageMb;
  final String hostName;
  final DateTime uptime;

  const DaemonStatus({
    required this.isRunning,
    required this.port,
    required this.activeTaskCount,
    required this.cpuUsagePercent,
    required this.memoryUsageMb,
    required this.hostName,
    required this.uptime,
  });

  Map<String, dynamic> toJson() => {
        'isRunning': isRunning,
        'port': port,
        'activeTaskCount': activeTaskCount,
        'cpuUsagePercent': cpuUsagePercent,
        'memoryUsageMb': memoryUsageMb,
        'hostName': hostName,
        'uptime': uptime.toIso8601String(),
      };
}
