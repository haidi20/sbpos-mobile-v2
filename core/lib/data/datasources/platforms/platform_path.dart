// Conditional export for path_provider on native and a web stub otherwise.
export 'platform_path_native.dart'
    if (dart.library.html) 'platform_path_web.dart';
