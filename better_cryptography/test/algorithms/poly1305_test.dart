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

import 'dart:convert';
import 'dart:typed_data';

import 'package:better_cryptography/better_cryptography.dart';
import 'package:better_cryptography/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('poly1305:', () {
    final algorithm = Poly1305();
    test('100 000 cycles', () async {
      final secretKeyBytes = Uint8List(32)
        ..[0] = 1
        ..[2] = 2;
      var k = SecretKey(secretKeyBytes);
      var state = utf8.encode('Hello world');
      for (var i = 0; i < 100000; i++) {
        final mac = await algorithm.calculateMac(
          state,
          secretKey: k,
          nonce: const <int>[],
        );
        state = mac.bytes;

        // Change key to something else
        final kBytes = Uint8List(32);
        kBytes.setAll(0, state);
        kBytes.setAll(16, state);
        for (var i = 0; i < kBytes.length; i++) {
          kBytes[i] = (kBytes[i] + i) % 256;
        }
        k = SecretKey(kBytes);
      }
      expect(
        hexFromBytes(state),
        hexFromBytes(hexToBytes(
          '2b a2 02 d1 83 82 24 83 fa e2 33 8c 1c 9a 88 e3',
        )),
      );
    });

    test('Empty message', () async {
      final inputBytes = hexToBytes('');
      final secretKey = SecretKey(hexToBytes(
        '85:d6:be:78:57:55:6d:33:7f:44:52:fe:42:d5:06:a8:01:03:80:8a:fb:0d:b2:fd:4a:bf:f6:af:41:49:f5:1b',
      ));
      final expectedMac = Mac(hexToBytes(
        '86 d9 3e 93 4f 63 1f 01 c7 03 49 be 81 1e fc 23',
      ));

      final mac = await algorithm.calculateMac(
        inputBytes,
        secretKey: secretKey,
        nonce: const <int>[],
      );
      expect(
        hexFromBytes(mac.bytes),
        hexFromBytes(expectedMac.bytes),
      );
    });

    test('Example in the RFC: full message', () async {
      // -------------------------------------------------------------------------
      // The following input/output constants are copied from the RFC 7539:
      // https://tools.ietf.org/html/rfc7539
      // -------------------------------------------------------------------------
      final inputBytes = utf8.encode('Cryptographic Forum Research Group');

      final secretKey = SecretKey(hexToBytes(
        '85:d6:be:78:57:55:6d:33:7f:44:52:fe:42:d5:06:a8:01:03:80:8a:fb:0d:b2:fd:4a:bf:f6:af:41:49:f5:1b',
      ));

      final expectedMac = Mac(hexToBytes(
        'a8:06:1d:c1:30:51:36:c6:c2:2b:8b:af:0c:01:27:a9',
      ));

      final mac = await algorithm.calculateMac(
        inputBytes,
        secretKey: secretKey,
        nonce: const <int>[],
      );
      expect(
        hexFromBytes(mac.bytes),
        hexFromBytes(expectedMac.bytes),
      );
    });
  });
}
