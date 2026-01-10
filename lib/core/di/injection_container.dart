import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

bool _initialized = false;

Future<void> initDependencies() async {
  if (_initialized) {
    return;
  }
  _initialized = true;
}

void resetForTest() {
  _initialized = false;
}
