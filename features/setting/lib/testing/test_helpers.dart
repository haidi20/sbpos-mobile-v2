// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/testing/setting_test_fixtures.dart';

const String kSettingTestRootText = 'Root Screen';

Future<ProviderContainer> pumpSettingRoute(
  WidgetTester tester, {
  required String routePath,
  required Widget screen,
  bool pushFromRoot = false,
  Map<String, Widget> extraRoutes = const {},
  void Function(ProviderContainer container)? arrange,
}) async {
  final remote = FakeSettingRemoteDataSource();
  final local = FakeSettingLocalDataSource();
  final printerService = FakePrinterFacade();
  final container = ProviderContainer(
    overrides: [
      settingRemoteDataSourceProvider.overrideWithValue(remote),
      settingLocalDataSourceProvider.overrideWithValue(local),
        printerFacadeProvider.overrideWithValue(printerService),
    ],
  );
  addTearDown(container.dispose);

  final previousHttpOverrides = HttpOverrides.current;
  HttpOverrides.global = _TestHttpOverrides();
  addTearDown(() => HttpOverrides.global = previousHttpOverrides);

  final routes = <GoRoute>[
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text(kSettingTestRootText),
        ),
      ),
    ),
    GoRoute(
      path: routePath,
      builder: (context, state) => screen,
    ),
    ...extraRoutes.entries.map(
      (entry) => GoRoute(
        path: entry.key,
        builder: (context, state) => entry.value,
      ),
    ),
  ];

  final router = GoRouter(
    initialLocation: pushFromRoot ? '/' : routePath,
    routes: routes,
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();

  if (pushFromRoot) {
    router.push(routePath);
    await tester.pumpAndSettle();
  }

  arrange?.call(container);
  await tester.pumpAndSettle();

  return container;
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TestHttpClientRequest(url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _TestHttpClientRequest(url);
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}

class _TestHttpClientRequest implements HttpClientRequest {
  _TestHttpClientRequest(this._uri);

  final Uri _uri;

  @override
  bool bufferOutput = false;

  @override
  int contentLength = -1;

  @override
  Encoding encoding = utf8;

  @override
  bool followRedirects = false;

  @override
  final HttpHeaders headers = _TestHttpHeaders();

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = false;

  @override
  Future<HttpClientResponse> close() async => _TestHttpClientResponse();

  @override
  Uri get uri => _uri;

  @override
  noSuchMethod(Invocation invocation) => null;
}

class _TestHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> data)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(
      <List<int>>[_transparentImage],
    ).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}

class _TestHttpHeaders implements HttpHeaders {
  @override
  noSuchMethod(Invocation invocation) => null;
}

const List<int> _transparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

BoxDecoration findAnimatedContainerDecoration(
  WidgetTester tester,
  Finder textFinder,
) {
  final container = tester.widget<AnimatedContainer>(
    find.ancestor(
      of: textFinder,
      matching: find.byType(AnimatedContainer),
    ),
  );

  return container.decoration! as BoxDecoration;
}
