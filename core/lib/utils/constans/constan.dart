import 'package:flutter_dotenv/flutter_dotenv.dart';

// Lint: keep legacy constant names but silence identifier style warnings
// ignore: constant_identifier_names
const String API = "api";
// ignore: non_constant_identifier_names
final String HOST = dotenv.env['BASE_URL'] ?? "https://retribusi.utamaweb.com";
// ignore: constant_identifier_names
const String CONNECT_STATUS = "connectStatus";
