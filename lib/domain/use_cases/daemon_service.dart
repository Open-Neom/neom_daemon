import '../models/daemon_status.dart';

/// Contract for daemon background server implementations.
abstract class DaemonService {
  bool get isRunning;
  int get port;
  int get activeTaskCount;

  Future<bool> start({int? customPort});
  Future<void> stop();
  DaemonStatus getStatus();
}
