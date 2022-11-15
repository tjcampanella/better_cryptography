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

import 'package:better_cryptography/better_cryptography.dart';
import 'package:better_cryptography/dart.dart';
import 'package:better_cryptography/src/utils.dart';

class DartBlake2s extends Blake2s with DartHashAlgorithmMixin {
  const DartBlake2s() : super.constructor();

  @override
  DartHashSink newHashSink() {
    return _Blake2sSink();
  }
}

class _Blake2sSink extends DartHashSink {
  static const List<int> _sigma = <int>[
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, // 16 bytes
    14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3,
    11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4,
    7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8,
    9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13,
    2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9,
    12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11,
    13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10,
    6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5,
    10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0,
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3
  ];
  static const List<int> _initializationVector = <int>[
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19,
  ];
  final Uint32List _hash = Uint32List(16);
  final Uint32List _buffer = Uint32List(16);
  Uint8List? _bufferAsBytes;

  ByteData? _bufferAsByteData;

  int _length = 0;

  Hash? _result;

  bool _isClosed = false;

  final Uint32List _localValues = Uint32List(16);

  _Blake2sSink() {
    final h = _hash;
    final iv = _initializationVector;
    for (var i = 0; i < 8; i++) {
      h[i] = iv[i];
    }
    h[0] = h[0] ^ 0x01010000 ^ 32;
  }

  @override
  void addSlice(List<int> chunk, int start, int end, bool isLast) {
    if (_isClosed) {
      throw StateError('Already closed');
    }

    var bufferAsBytes = _bufferAsBytes;
    if (bufferAsBytes == null) {
      bufferAsBytes ??= Uint8List.view(_buffer.buffer);
      _bufferAsBytes = bufferAsBytes;
    }
    var length = _length;
    for (var i = start; i < end; i++) {
      final bufferIndex = length % 64;

      // If first byte of a new block
      if (bufferIndex == 0 && length > 0) {
        // Store length
        _length = length;

        // Compress the previous block
        _compress(false);
      }

      // Set byte
      bufferAsBytes[bufferIndex] = chunk[i];

      // Increment length
      length++;
    }

    // Store length
    _length = length;

    if (isLast) {
      close();
    }
  }

  @override
  void close() {
    if (_isClosed) {
      return;
    }
    _isClosed = true;

    final length = _length;

    // Fill remaining indices with zeroes
    final blockLength = length % 64;
    if (blockLength > 0) {
      _bufferAsBytes!.fillRange(blockLength, 64, 0);
    }

    // Compress
    _compress(true);

    // Change:
    // Host endian --> little endian
    final hash = _hash;
    if (Endian.host != Endian.little) {
      final byteData = ByteData.view(hash.buffer);
      for (var i = 0; i < 32; i += 4) {
        byteData.setUint32(
          i,
          byteData.getUint32(i, Endian.host),
          Endian.little,
        );
      }
    }

    // Return bytes
    _result = Hash(List<int>.unmodifiable(
      Uint8List.view(
        hash.buffer,
        hash.offsetInBytes,
        32,
      ),
    ));
  }

  @override
  Hash hashSync() {
    final result = _result;
    if (result == null) {
      throw StateError('Not closed');
    }
    return result;
  }

  void _compress(bool isLast) {
    // Change:
    // little endian --> host endian
    if (Endian.host != Endian.little) {
      // We need ByteData view
      final bufferAsByteData =
          _bufferAsByteData ??= ByteData.view(_buffer.buffer);

      // Every 4 bytes
      for (var i = 0; i < 64; i += 4) {
        // Convert endian
        bufferAsByteData.setUint32(
          i,
          bufferAsByteData.getUint32(i, Endian.little),
          Endian.host,
        );
      }
    }

    final h = _hash;
    final v = _localValues;
    final m = _buffer;

    // Initialize v[0..7]
    for (var i = 0; i < 8; i++) {
      v[i] = h[i];
    }

    // Initialize v[8..15]
    final initializationVector = _initializationVector;
    for (var i = 0; i < 8; i++) {
      v[8 + i] = initializationVector[i];
    }

    // Set length.
    // We can't use setUint64(...) because it doesn't work in browsers.
    final length = _length;
    v[12] ^= uint32mask & length;
    v[13] ^= length ~/ (uint32mask + 1);

    // Is this the last block?
    if (isLast) {
      v[14] ^= uint32mask;
    }

    final sigma = _sigma;

    // 10 rounds
    for (var round = 0; round < 10; round++) {
      // Sigma index
      final si = round * 16;

      _g(v, 0, 4, 8, 12, m[sigma[si + 0]], m[sigma[si + 1]]);
      _g(v, 1, 5, 9, 13, m[sigma[si + 2]], m[sigma[si + 3]]);
      _g(v, 2, 6, 10, 14, m[sigma[si + 4]], m[sigma[si + 5]]);
      _g(v, 3, 7, 11, 15, m[sigma[si + 6]], m[sigma[si + 7]]);

      _g(v, 0, 5, 10, 15, m[sigma[si + 8]], m[sigma[si + 9]]);
      _g(v, 1, 6, 11, 12, m[sigma[si + 10]], m[sigma[si + 11]]);
      _g(v, 2, 7, 8, 13, m[sigma[si + 12]], m[sigma[si + 13]]);
      _g(v, 3, 4, 9, 14, m[sigma[si + 14]], m[sigma[si + 15]]);
    }

    // Copy.
    for (var i = 0; i < 8; i++) {
      h[i] = h[i] ^ v[i] ^ v[8 + i];
    }
  }

  static void _g(Uint32List v, int a, int b, int c, int d, int x, int y) {
    v[a] = uint32mask & (v[a] + v[b] + x);
    v[d] = rotateRight32((v[d] ^ v[a]), 16);
    v[c] = uint32mask & (v[c] + v[d]);
    v[b] = rotateRight32((v[b] ^ v[c]), 12);
    v[a] = uint32mask & (v[a] + v[b] + y);
    v[d] = rotateRight32((v[d] ^ v[a]), 8);
    v[c] = uint32mask & (v[c] + v[d]);
    v[b] = rotateRight32((v[b] ^ v[c]), 7);
  }
}
