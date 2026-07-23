import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:neom_core/app_config.dart';
import 'package:sint/sint.dart';

import 'daemon_command_router.dart';
import 'daemon_status.dart';

/// Universal background daemon server for Neom apps & node instances.
///
/// Provides local HTTP/IPC API endpoints for background job execution,
/// status telemetry, and command routing.
class NeomDaemonServer extends SintController {
  static const int defaultPort = 8392;

  final int port;
  final DaemonCommandRouter router;

  HttpServer? _server;
  bool _isRunning = false;
  final DateTime _startedAt = DateTime.now();

  final RxInt _activeTaskCount = 0.obs;

  NeomDaemonServer({
    this.port = defaultPort,
    DaemonCommandRouter? router,
  }) : router = router ?? DaemonCommandRouter();

  bool get isRunning => _isRunning;
  int get activeTaskCount => _activeTaskCount.value;

  /// Starts the daemon HTTP server on the configured port.
  Future<bool> start() async {
    if (_isRunning) return true;

    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        port,
        shared: true,
      );
      _isRunning = true;
      AppConfig.logger.i('NeomDaemonServer active on port $port');

      _listenRequests();
      return true;
    } catch (e) {
      AppConfig.logger.e('NeomDaemonServer failed to bind on port $port: $e');
      _isRunning = false;
      return false;
    }
  }

  /// Stops the daemon server.
  Future<void> stop() async {
    if (!_isRunning) return;

    await _server?.close(force: true);
    _server = null;
    _isRunning = false;
    AppConfig.logger.i('NeomDaemonServer stopped.');
  }

  /// Telemetry status snapshot.
  DaemonStatus getStatus() {
    return DaemonStatus(
      isRunning: _isRunning,
      port: port,
      activeTaskCount: _activeTaskCount.value,
      cpuUsagePercent: 0.0,
      memoryUsageMb: 0.0,
      hostName: Platform.localHostname,
      uptime: _startedAt,
    );
  }

  void _listenRequests() {
    _server?.listen(
      (HttpRequest request) async {
        _activeTaskCount.value++;
        try {
          if (request.uri.path == '/status' || request.uri.path == '/health') {
            _handleStatus(request);
          } else if (request.uri.path == '/command' && request.method == 'POST') {
            await _handleCommand(request);
          } else {
            request.response
              ..statusCode = HttpStatus.notFound
              ..write('NeomDaemonServer: Endpoint non-existent')
              ..close();
          }
        } catch (e) {
          AppConfig.logger.e('NeomDaemonServer error processing request: $e');
          try {
            request.response
              ..statusCode = HttpStatus.internalServerError
              ..write('Internal daemon error')
              ..close();
          } catch (_) {}
        } finally {
          _activeTaskCount.value = (_activeTaskCount.value - 1).clamp(0, 9999);
        }
      },
      onError: (error) {
        AppConfig.logger.e('NeomDaemonServer socket error: $error');
      },
    );
  }

  void _handleStatus(HttpRequest request) {
    final status = getStatus();
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(status.toJson())
      ..close();
  }

  Future<void> _handleCommand(HttpRequest request) async {
    final content = await utf8.decoder.bind(request).join();
    final result = await router.dispatch(content);

    request.response
      ..statusCode = result.isSuccess ? HttpStatus.ok : HttpStatus.badRequest
      ..headers.contentType = ContentType.json
      ..write(result.toJson())
      ..close();
  }
}
