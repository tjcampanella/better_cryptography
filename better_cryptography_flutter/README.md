[![Pub Package](https://img.shields.io/pub/v/better_cryptography_flutter.svg)](https://pub.dev/packages/better_cryptography_flutter)
[![Github Actions CI](https://github.com/tjcampanella/better_cryptography/workflows/Dart%20CI/badge.svg)](https://github.com/tjcampanella/better_cryptography/actions?query=workflow%3A%22Dart+CI%22)

# Overview

This is a version of the package [better_cryptography](https://pub.dev/packages/better_cryptography) that
optimizes performance of some cryptographic algorithms by using native APIs of Android, iOS, and
Mac OS X. You must use asynchronous methods to get the performance boost.

Licensed under the [Apache License 2.0](LICENSE).

## Optimized algorithms
### In Android
  * [AesCbc()](https://pub.dev/documentation/better_cryptography/latest/better_cryptography/AesCbc-class.html)
  * [AesCtr()](https://pub.dev/documentation/better_cryptography/latest/better_cryptography/AesCtr-class.html)
  * [AesGcm()](https://pub.dev/documentation/better_cryptography/latest/better_cryptography/AesGcm-class.html)
  * [Chacha20.poly1305()](https://pub.dev/documentation/better_cryptography/latest/better_cryptography/Chacha20-class.html)

### In iOS and Mac OS X
  * [AesGcm()](https://pub.dev/documentation/better_cryptography/latest/better_cryptography/AesGcm-class.html)
  * [Chacha20.poly1305()](https://pub.dev/documentation/better_cryptography/latest/better_cryptography/Chacha20-class.html)

## Links
  * [Github project](https://github.com/tjcampanella/better_cryptography)
  * [Issue tracker](https://github.com/tjcampanella/better_cryptography/issues)
  * [Pub package](https://pub.dev/packages/better_cryptography_flutter)
  * [API reference](https://pub.dev/documentation/better_cryptography_flutter/latest/)

# Getting started
In _pubspec.yaml_:
```yaml
dependencies:
  cryptography: ^2.0.5
  cryptography_flutter: ^2.0.2
```

Then just use:
```dart
import 'package:better_cryptography_flutter/better_cryptography_flutter.dart';

void main() {
  // Enable Flutter cryptography
  FlutterCryptography.enable();

  // ....
}
```

For APIs, read documentation for [package:better_cryptography](https://pub.dev/packages/better_cryptography).

# Contributing?
Test the plugin by running integration tests in
_cryptography_flutter/example/_ (see README in the directory).