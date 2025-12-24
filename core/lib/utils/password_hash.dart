// Conditional export for password hashing implementation.
export 'password_hash_native.dart'
    if (dart.library.html) 'password_hash_web.dart';
