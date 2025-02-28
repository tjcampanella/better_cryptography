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

import 'package:collection/collection.dart';
import 'package:better_cryptography/better_cryptography.dart';

/// A digital signature made of [bytes] and [publicKey].
///
/// Messages can be signed and verified with some [SignatureAlgorithm].
class Signature {
  /// Signature bytes.
  final List<int> bytes;

  /// Public key of the signer.
  final PublicKey publicKey;

  const Signature(this.bytes, {required this.publicKey});

  @override
  int get hashCode =>
      const ListEquality<int>().hash(bytes) ^ publicKey.hashCode;

  @override
  bool operator ==(other) =>
      other is Signature &&
      const ListEquality<int>().equals(bytes, other.bytes) &&
      publicKey == other.publicKey;

  @override
  String toString() =>
      'Signature([${bytes.join(', ')}], publicKey: $publicKey)';
}
