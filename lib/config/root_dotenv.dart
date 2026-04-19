import 'root_dotenv_stub.dart'
    if (dart.library.io) 'root_dotenv_io.dart' as root_impl;

Future<String?> readRootDotenvIfPresent() => root_impl.readRootDotenvIfPresent();
