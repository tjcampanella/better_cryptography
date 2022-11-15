// Copyright 2019-2020 Gohilla Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:better_cryptography/browser.dart';
import 'package:better_cryptography/better_cryptography.dart';
import 'package:better_cryptography/dart.dart';
import 'package:better_cryptography/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('Pbkdf2:', () {
    group('DartCryptography:', () {
      setUp(() {
        Cryptography.instance = DartCryptography.defaultInstance;
      });
      _main();
    });
    group('BrowserCryptography:', () {
      setUp(() {
        Cryptography.instance = BrowserCryptography.defaultInstance;
      });
      _main();
    });
  });
}

void _main() {
  test('deriveKey(...): Hmac(sha256), 1 iteration', () async {
    final macAlgorithm = Hmac(Sha256());
    const input = <int>[1, 2, 3];
    const nonce = [4, 5, 6];
    final bits = 128;
    final iterations = 1;
    final expectedBytes = hexToBytes(
      '3f 22 41 8b c0 47 83 9f b5 54 b5 c6 16 ef 35 55',
    );

    final pbkdf2 = Pbkdf2(
      macAlgorithm: macAlgorithm,
      bits: bits,
      iterations: iterations,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(input),
      nonce: nonce,
    );
    final actualBytes = await secretKey.extractBytes();
    expect(
      hexFromBytes(actualBytes),
      hexFromBytes(expectedBytes),
    );
  });

  test('deriveKey(...): Hmac(sha256), 2 iterations', () async {
    final macAlgorithm = Hmac(Sha256());
    const input = <int>[1, 2, 3];
    const nonce = [4, 5, 6];
    final bits = 128;
    final iterations = 2;
    final expectedBytes = hexToBytes(
      '43 bb 42 58 d4 54 0e d2 45 c3 87 78 8b 60 5d 95',
    );

    final pbkdf2 = Pbkdf2(
      macAlgorithm: macAlgorithm,
      bits: bits,
      iterations: iterations,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(input),
      nonce: nonce,
    );
    final actualBytes = await secretKey.extractBytes();
    expect(
      hexFromBytes(actualBytes),
      hexFromBytes(expectedBytes),
    );
  });

  test('deriveKey(...): Hmac(sha256), 3 iterations', () async {
    final macAlgorithm = Hmac(Sha256());
    const input = <int>[1, 2, 3];
    const nonce = [4, 5, 6];
    final bits = 128;
    final iterations = 3;
    final expectedBytes = hexToBytes(
      '00 4b 50 3c 32 a1 b7 44 ca 98 a9 ce 2e 17 23 18',
    );

    final pbkdf2 = Pbkdf2(
      macAlgorithm: macAlgorithm,
      bits: bits,
      iterations: iterations,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(input),
      nonce: nonce,
    );
    final actualBytes = await secretKey.extractBytes();
    expect(
      hexFromBytes(actualBytes),
      hexFromBytes(expectedBytes),
    );
  });

  test('deriveKey(...): Hmac(sha384), 3 iterations', () async {
    final macAlgorithm = Hmac(Sha384());
    const input = <int>[1, 2];
    const nonce = <int>[3, 4];
    final bits = 128;
    final iterations = 3;
    final expectedBytes = hexToBytes(
      'c0 db 36 72 53 83 f6 e5 01 b5 3d 3d fb 3b 43 64',
    );

    final pbkdf2 = Pbkdf2(
      macAlgorithm: macAlgorithm,
      bits: bits,
      iterations: iterations,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKeyData(input),
      nonce: nonce,
    );
    final actualBytes = await secretKey.extractBytes();
    expect(
      hexFromBytes(actualBytes),
      hexFromBytes(expectedBytes),
    );
  });

  test('deriveKey(...): Hmac(sha512), 3 iterations', () async {
    final macAlgorithm = Hmac(Sha512());
    const input = <int>[1, 2];
    const nonce = [3, 4];
    final bits = 128;
    final iterations = 3;
    final expectedBytes = hexToBytes(
      'c9 70 19 df 29 5a 18 e9 c4 39 63 76 d3 c9 4d 96',
    );

    final pbkdf2 = Pbkdf2(
      macAlgorithm: macAlgorithm,
      bits: bits,
      iterations: iterations,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(input),
      nonce: nonce,
    );
    final actualBytes = await secretKey.extractBytes();
    expect(
      hexFromBytes(actualBytes),
      hexFromBytes(expectedBytes),
    );
  });
}
