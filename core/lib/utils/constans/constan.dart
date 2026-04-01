import 'package:flutter_dotenv/flutter_dotenv.dart';

// Lint: keep legacy constant names but silence identifier style warnings
// ignore: constant_identifier_names
const String API = "api";
// ignore: non_constant_identifier_names
String get HOST => _readEnvOrDefault(
      key: 'BASE_URL',
      fallback: 'https://retribusi.utamaweb.com',
    );
// ignore: constant_identifier_names
const String CONNECT_STATUS = "connectStatus";

String _readEnvOrDefault({
  required String key,
  required String fallback,
}) {
  try {
    return dotenv.env[key] ?? fallback;
  } catch (_) {
    return fallback;
  }
}
