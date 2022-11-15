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

import 'package:better_cryptography/better_cryptography.dart';
import 'package:better_cryptography/dart.dart';
import 'package:better_cryptography/src/utils.dart';
import 'package:test/test.dart';

void main() {
  late Chacha20 algorithm;
  setUp(() {
    algorithm = Chacha20.poly1305Aead();
  });

  group('Chacha20.poly1305Aead():', () {
    test('== / hashCode', () {
      final clone = Chacha20(
        macAlgorithm: DartChacha20Poly1305AeadMacAlgorithm(),
      );
      final other0 = Chacha20(
        macAlgorithm: Hmac.sha256(),
      );
      expect(algorithm, clone);
      expect(algorithm, isNot(other0));
      expect(algorithm.hashCode, clone.hashCode);
      expect(algorithm.hashCode, isNot(other0.hashCode));
    });

    test('toString', () {
      expect(
        algorithm.toString(),
        'Chacha20.poly1305Aead()',
      );
    });

    test('information', () {
      expect(
        algorithm.macAlgorithm,
        isA<DartChacha20Poly1305AeadMacAlgorithm>(),
      );
      expect(algorithm.macAlgorithm.supportsAad, isTrue);
      expect(algorithm.secretKeyLength, 32);
      expect(algorithm.nonceLength, 12);
    });

    group('Checks MAC', () {
      Future<void> f(List<int> message) async {
        final secretKey = await algorithm.newSecretKey();
        final secretBox = await algorithm.encrypt(
          [],
          secretKey: secretKey,
        );
        final badMac = Mac(secretBox.mac.bytes.map((e) => 0xFF ^ e).toList());
        final badSecretBox = SecretBox(
          secretBox.cipherText,
          nonce: secretBox.nonce,
          mac: badMac,
        );
        await expectLater(
          algorithm.decrypt(badSecretBox, secretKey: secretKey),
          throwsA(isA<SecretBoxAuthenticationError>()),
        );
      }

      test('message: []', () async {
        await f([]);
      });
      test('message: [1,2,3]', () async {
        await f([1, 2, 3]);
      });
    });

    test('SecretBox contains MAC', () async {
      final secretKey = await algorithm.newSecretKey();
      final nonce = algorithm.newNonce();
      final clearText = [1, 2, 3];
      final secretBox = await algorithm.encrypt(
        clearText,
        secretKey: secretKey,
        nonce: nonce,
      );
      expect(secretBox.cipherText, hasLength(3));
      expect(secretBox.mac.bytes, hasLength(16));
    });

    group('RFC 7539: test vectors', () {
      // -------------------------------------------------------------------------
      // The following input/output constants are copied from the RFC 7539:
      // https://tools.ietf.org/html/rfc7539
      // -------------------------------------------------------------------------
      final clearText =
          "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it."
              .runes
              .toList();

      final aad = hexToBytes(
        '50 51 52 53 c0 c1 c2 c3 c4 c5 c6 c7',
      );

      final secretKey = SecretKey(hexToBytes(
        '80 81 82 83 84 85 86 87 88 89 8a 8b 8c 8d 8e 8f'
        '90 91 92 93 94 95 96 97 98 99 9a 9b 9c 9d 9e 9f',
      ));

      final nonce = hexToBytes(
        '07 00 00 00 40 41 42 43 44 45 46 47',
      );

      final expectedCipherText = hexToBytes('''
d3 1a 8d 34 64 8e 60 db 7b 86 af bc 53 ef 7e c2
a4 ad ed 51 29 6e 08 fe a9 e2 b5 a7 36 ee 62 d6
3d be a4 5e 8c a9 67 12 82 fa fb 69 da 92 72 8b
1a 71 de 0a 9e 06 0b 29 05 d6 a5 b6 7e cd 3b 36
92 dd bd 7f 2d 77 8b 8c 98 03 ae e3 28 09 1b 58
fa b3 24 e4 fa d6 75 94 55 85 80 8b 48 31 d7 bc
3f f4 de f0 8e 4b 7a 9d e5 76 d2 65 86 ce c6 4b
61 16
''');

      final expectedMac = Mac(hexToBytes(
        '1a:e1:0b:59:4f:09:e2:6a:7e:90:2e:cb:d0:60:06:91',
      ));

      // -----------------------------------------------------------------------
      // End of constants from RFC 7539
      // -----------------------------------------------------------------------

      test('encrypt(...)', () async {
        final secretBox = await algorithm.encrypt(
          clearText,
          secretKey: secretKey,
          nonce: nonce,
          aad: aad,
        );
        expect(
          hexFromBytes(secretBox.cipherText),
          hexFromBytes(expectedCipherText),
        );
        expect(
          hexFromBytes(secretBox.mac.bytes),
          hexFromBytes(expectedMac.bytes),
        );
      });

      test('decrypt(...)', () async {
        final secretBox = SecretBox(
          expectedCipherText,
          nonce: nonce,
          mac: expectedMac,
        );
        final actualClearText = await algorithm.decrypt(
          secretBox,
          secretKey: secretKey,
          aad: aad,
        );
        expect(
          hexFromBytes(actualClearText),
          hexFromBytes(clearText),
        );
      });
    });
  });
}
