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

import 'dart:typed_data';

import 'package:better_cryptography/browser.dart';
import 'package:better_cryptography/better_cryptography.dart';
import 'package:js/js_util.dart' as js;

import 'hmac.dart';
import 'javascript_bindings.dart' show jsArrayBufferFrom;
import 'javascript_bindings.dart' as web_crypto;

/// PBKDF2 implementation that uses _Web Cryptography API_ in browsers.
///
/// See [BrowserCryptography].
class BrowserPbkdf2 extends Pbkdf2 {
  @override
  final BrowserHmac macAlgorithm;

  @override
  final int bits;

  @override
  final int iterations;

  const BrowserPbkdf2({
    required this.macAlgorithm,
    required this.bits,
    required this.iterations,
  }) : super.constructor();

  @override
  Future<SecretKey> deriveKey({
    required SecretKey secretKey,
    required List<int> nonce,
  }) async {
    final jsCryptoKey = await _jsCryptoKey(secretKey);

    // subtle.deriveBits(...)
    final byteBuffer = await js.promiseToFuture<ByteBuffer>(
      web_crypto.deriveBits(
        web_crypto.Pkdf2Params(
          name: 'PBKDF2',
          hash: macAlgorithm.hashAlgorithmWebCryptoName,
          salt: jsArrayBufferFrom(nonce),
          iterations: iterations,
        ),
        jsCryptoKey,
        bits,
      ),
    );

    return SecretKey(List<int>.unmodifiable(
      Uint8List.view(byteBuffer),
    ));
  }

  Future<web_crypto.CryptoKey> _jsCryptoKey(SecretKey secretKey) async {
    final secretKeyData = await secretKey.extract();
    return js.promiseToFuture<web_crypto.CryptoKey>(
      web_crypto.importKey(
        'raw',
        jsArrayBufferFrom(secretKeyData.bytes),
        'PBKDF2',
        false,
        const ['deriveBits'],
      ),
    );
  }
}
