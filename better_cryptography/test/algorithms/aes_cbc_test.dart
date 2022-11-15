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
  group('AesCbc:', () {
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
  late AesCbc algorithm;
  setUp(() {
    algorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
  });

  final secretKey128 = SecretKey(List<int>.filled(16, 2));
  final secretKey256 = SecretKey(List<int>.filled(32, 2));

  test('== / hashCode', () {
    final clone = AesCbc.with256bits(
      macAlgorithm: Hmac.sha256(),
    );
    final other0 = AesCbc.with128bits(
      macAlgorithm: Hmac.sha256(),
    );
    final other1 = AesCbc.with256bits(
      macAlgorithm: Hmac.sha512(),
    );
    final other2 = AesCtr.with256bits(
      macAlgorithm: Hmac.sha256(),
    );
    expect(algorithm, clone);
    expect(algorithm, isNot(other0));
    expect(algorithm, isNot(other1));
    expect(algorithm, isNot(other2));
    expect(algorithm.hashCode, clone.hashCode);
    expect(algorithm.hashCode, isNot(other0.hashCode));
    expect(algorithm.hashCode, isNot(other1.hashCode));
    expect(algorithm.hashCode, isNot(other2.hashCode));
  });

  test('toString', () {
    expect(
      algorithm.toString(),
      'AesCbc.with256bits(macAlgorithm: Hmac.sha256())',
    );
  });

  test('information', () {
    expect(algorithm.macAlgorithm, Hmac.sha256());
    expect(algorithm.secretKeyLength, 32);
    expect(algorithm.nonceLength, 16);
  });

  test('Encrypted without specifying nonce: two results are different',
      () async {
    // Encrypt
    final clearText = [1, 2, 3];
    final secretKey = await algorithm.newSecretKey();
    final secretBox = await algorithm.encrypt(
      clearText,
      secretKey: secretKey,
    );
    final otherSecretBox = await algorithm.encrypt(
      clearText,
      secretKey: secretKey,
    );
    expect(secretBox.nonce, isNot(otherSecretBox.nonce));
    expect(secretBox.cipherText, isNot(otherSecretBox.cipherText));
    expect(secretBox.mac, isNot(otherSecretBox.mac));
  });

  test('Encrypted without specifying nonce: decrypted correctly', () async {
    // Encrypt
    final clearText = [1, 2, 3];
    final secretKey = await algorithm.newSecretKey();
    final secretBox = await algorithm.encrypt(
      clearText,
      secretKey: secretKey,
    );

    // Check MAC
    final expectedMac = await Hmac.sha256().calculateMac(
      secretBox.cipherText,
      secretKey: secretKey,
      nonce: secretBox.nonce,
    );
    expect(secretBox.mac, expectedMac);

    // Decrypt
    final decryptedSecretBox = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );
    expect(decryptedSecretBox, clearText);
  });

  test('Encrypt without specifying nonce + decrypt', () async {
    // Encrypt
    final clearText = [1, 2, 3];
    final secretKey = await algorithm.newSecretKey();
    final secretBox = await algorithm.encrypt(
      clearText,
      secretKey: secretKey,
    );
    final anotherSecretBox = await algorithm.encrypt(
      clearText,
      secretKey: secretKey,
    );
    expect(secretBox.nonce, isNot(anotherSecretBox.nonce));

    // Decrypt
    final decryptedSecretBox = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );
    expect(decryptedSecretBox, clearText);
  });

  test('newSecretKey(): length is 32', () async {
    final secretKey = await algorithm.newSecretKey();
    final secretKeyData = await secretKey.extract();
    expect(
      secretKeyData.bytes,
      hasLength(32),
    );
  });

  test('newSecretKey(): two results are not equal', () async {
    final secretKey = await algorithm.newSecretKey();
    final otherSecretKey = await algorithm.newSecretKey();
    final bytes = await secretKey.extractBytes();
    final otherBytes = await otherSecretKey.extractBytes();
    expect(bytes, isNot(otherBytes));
  });

  test('newNonce(): length is 16', () async {
    final nonce = algorithm.newNonce();
    expect(nonce, hasLength(16));
  });

  test('newNonce(): two results are not equal', () async {
    final nonce = algorithm.newNonce();
    final otherNonce = algorithm.newNonce();
    expect(nonce, isNot(otherNonce));
    expect(nonce.hashCode, isNot(otherNonce.hashCode));
  });

  test('encrypt/decrypt input lengths 0...1000', () async {
    for (var i = 0; i < 1000; i++) {
      final clearText = List<int>.filled(i, 1);
      final secretKey = await algorithm.newSecretKey();
      final nonce = List<int>.filled(16, 1);

      // encrypt(...)
      final secretBox = await algorithm.encrypt(
        clearText,
        secretKey: secretKey,
        nonce: nonce,
      );
      final expectedMac = await Hmac.sha256().calculateMac(
        secretBox.cipherText,
        secretKey: secretKey,
        nonce: nonce,
      );
      expect(
        hexFromBytes(secretBox.mac.bytes),
        hexFromBytes(expectedMac.bytes),
      );

      // decrypt(...)
      final decrypted = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );
      expect(decrypted, clearText);
    }
  });

  group('128-bit key, 0 bytes', () {
    late AesCbc algorithm;
    final clearText = <int>[];
    final secretKey = secretKey128;
    final nonce = List<int>.filled(16, 1);
    final cipherText = hexToBytes(
      'f8 f9 57 22 63 9b 89 51 82 04 86 47 2e 45 a3 e7',
    );
    late Mac mac;
    setUp(() async {
      algorithm = AesCbc.with128bits(macAlgorithm: Hmac.sha256());
      mac = await algorithm.macAlgorithm.calculateMac(
        cipherText,
        secretKey: secretKey,
        nonce: nonce,
      );
    });

    test('encrypt', () async {
      final secretBox = await algorithm.encrypt(
        clearText,
        secretKey: secretKey,
        nonce: nonce,
      );
      expect(hexFromBytes(secretBox.cipherText), hexFromBytes(cipherText));
      expect(secretBox.mac, mac);
    });

    test('decrypt', () async {
      final decrypted = await algorithm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: secretKey,
      );
      expect(decrypted, clearText);
    });
  });

  group('128-bit key, 31 bytes:', () {
    late AesCbc algorithm;
    final clearText = List<int>.generate(31, (i) => 1 + i);
    final secretKey = secretKey128;
    final nonce = List<int>.filled(16, 1);
    final cipherText = hexToBytes(
      '68 4f a0 20 8c 9f 75 f3 71 b9 77 cc 4d 4f 04 4b'
      '84 9a f4 46 1f 00 e0 ac 7c 2f d2 24 1c 71 14 e8',
    );
    late Mac mac;
    setUp(() async {
      algorithm = AesCbc.with128bits(macAlgorithm: Hmac.sha256());
      mac = await algorithm.macAlgorithm.calculateMac(
        cipherText,
        secretKey: secretKey,
        nonce: nonce,
      );
    });

    test('encrypt', () async {
      final secretBox = await algorithm.encrypt(
        clearText,
        secretKey: secretKey,
        nonce: nonce,
      );
      expect(hexFromBytes(secretBox.cipherText), hexFromBytes(cipherText));
      expect(secretBox.mac, mac);
    });

    test('decrypt', () async {
      final decrypted = await algorithm.decrypt(
        SecretBox(
          cipherText,
          nonce: nonce,
          mac: mac,
        ),
        secretKey: secretKey,
      );
      expect(decrypted, clearText);
    });
  });

  group('128-bit key, 32 bytes', () {
    late AesCbc algorithm;
    final clearText = List<int>.generate(32, (i) => 1 + i);
    final secretKey = secretKey128;
    final nonce = List<int>.filled(16, 1);
    final cipherText = hexToBytes(
      '68 4f a0 20 8c 9f 75 f3 71 b9 77 cc 4d 4f 04 4b'
      '62 11 8f 13 ae 07 60 1d 28 15 e9 cc 4c 8a b6 84'
      '31 b2 2a 1a 9d fa f2 f5 77 8c c6 28 65 51 e3 fe',
    );
    late Mac mac;
    setUp(() async {
      algorithm = AesCbc.with128bits(macAlgorithm: Hmac.sha256());
      mac = await algorithm.macAlgorithm.calculateMac(
        cipherText,
        secretKey: secretKey,
        nonce: nonce,
      );
    });

    test('encrypt', () async {
      final secretBox = await algorithm.encrypt(
        clearText,
        secretKey: secretKey,
        nonce: nonce,
      );
      expect(hexFromBytes(secretBox.cipherText), hexFromBytes(cipherText));
      expect(secretBox.mac, mac);
    });

    test('decrypt', () async {
      final decrypted = await algorithm.decrypt(
        SecretBox(
          cipherText,
          nonce: nonce,
          mac: mac,
        ),
        secretKey: secretKey,
      );
      expect(decrypted, clearText);
    });
  });

  group('256-bit key, 3 bytes', () {
    late AesCbc algorithm;
    final clearText = List<int>.unmodifiable([1, 2, 3]);
    final secretKey = secretKey256;
    final nonce = List<int>.unmodifiable(List<int>.filled(16, 1));
    final cipherText = hexToBytes(
      '45 4c 0d c4 53 02 f3 62 d2 4c 5c a0 37 ee 67 66',
    );
    late Mac mac;
    setUp(() async {
      algorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
      mac = await algorithm.macAlgorithm.calculateMac(
        cipherText,
        secretKey: secretKey,
        nonce: nonce,
      );
    });

    test('encrypt', () async {
      final encrypted = await algorithm.encrypt(
        clearText,
        secretKey: secretKey,
        nonce: nonce,
      );
      expect(hexFromBytes(encrypted.cipherText), hexFromBytes(cipherText));
      expect(encrypted.mac, mac);
    });

    test('decrypt', () async {
      final decrypted = await algorithm.decrypt(
        SecretBox(
          cipherText,
          nonce: nonce,
          mac: mac,
        ),
        secretKey: secretKey,
      );
      expect(decrypted, clearText);
    });
  });
}
