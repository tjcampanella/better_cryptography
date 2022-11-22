[![Pub Package](https://img.shields.io/pub/v/better_jwk.svg)](https://pub.dev/packages/better_jwk)
[![Github Actions CI](https://github.com/tjcampanella/better_cryptography/workflows/Dart%20CI/badge.svg)](https://github.com/tjcampanella/better_cryptography/actions?query=workflow%3A%22Dart+CI%22)

# Overview
JWK (JSON Web Key) encoding and decoding. Designed to be used with
[package:better_cryptography](https://pub.dev/packages/better_cryptography).

Licensed under the [Apache License 2.0](LICENSE).

# Examples
## Encoding KeyPair
```dart
import 'package:cryptography/better_cryptography.dart';
import 'package:jwk/better_jwk.dart';

void main() {
  final keyPair = RsaKeyPairGenerator().newKeyPair();
  final jwk = Jwk.fromKeyPair(keyPair);
  final json = jwk.toJson();
}
```

## Decoding SecretKey
```dart
import 'package:jwk/better_jwk.dart';

void main() {
  final jwk = Jwk.fromJson({
    'kty': 'OCS',
    'x': 'base 64 string',
  });
  final secretKey = jwk.toSecretKey();
}
```
