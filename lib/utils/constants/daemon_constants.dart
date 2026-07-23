/// Constants used across [neom_daemon].
class DaemonConstants {
  static const int defaultPort = 8392;

  static const Set<String> forbiddenCommandPrefixes = {
    'rm -rf /',
    'mkfs',
    'dd if=',
    ':(){ :|:& };:',
    'format c:',
  };

  static const List<String> shellPrefixes = ['\$', '!'];
}
