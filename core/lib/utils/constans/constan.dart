import 'package:flutter_dotenv/flutter_dotenv.dart';

// const String API = "Api";
const String API = "api";
final String HOST = dotenv.env['BASE_URL'] ?? "https://retribusi.utamaweb.com";
const String CONNECT_STATUS = "connectStatus";
