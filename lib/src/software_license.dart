import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

class SoftwareLicense {
  final String? userId;
  final String? machineId;
  final String? licenseId;
  final DateTime? validStartTime;
  final DateTime? validEndTime;
  final List<String> features = List.empty(growable: true);
  final Map<String, dynamic> extraFields = Map.from({});

  SoftwareLicense({
    this.userId,
    this.machineId,
    this.licenseId,
    this.validStartTime,
    this.validEndTime,
    List<String>? features,
    Map<String, dynamic>? extraFields,
  }) {
    if (features != null) {
      this.features.addAll(features);
    }
    if (extraFields != null) {
      this.extraFields.addAll(extraFields);
    }
  }

  bool isValid() {
    var now = DateTime.now();
    return (now.isAfter(validStartTime ?? DateTime.fromMillisecondsSinceEpoch(0))) &&
        (now.isBefore(validEndTime ?? DateTime.fromMillisecondsSinceEpoch(0x7fffffffffffffff)));
  }

  bool hasFeature(String feature) {
    return features.contains(feature);
  }

  T get<T>(String fieldName) {
    return extraFields[fieldName] as T;
  }

  static SoftwareLicense fromMap(Map<String, dynamic> map) {
    return SoftwareLicense(
      userId: map['user_id'],
      machineId: map['machine_id'],
      licenseId: map['license_id'],
      validStartTime: (map['valid_start_time'] != null) ? DateTime.tryParse(map['valid_start_time']) : null,
      validEndTime: (map['valid_end_time'] != null) ? DateTime.tryParse(map['valid_start_time']) : null,
      features: map['features'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (userId != null) 'user_id': userId,
      if (machineId != null) 'machine_id': machineId,
      if (licenseId != null) 'license_id': licenseId,
      if (validStartTime != null) 'valid_start_time': validStartTime!.toIso8601String(),
      if (validEndTime != null) 'valid_end_time': validEndTime!.toIso8601String(),
      'features': features,
    };
  }
}

class EncryptedSoftwareLicense extends SoftwareLicense {
  final String encryptedData;

  EncryptedSoftwareLicense({
    required this.encryptedData,
    super.userId,
    super.machineId,
    super.licenseId,
    super.validStartTime,
    super.validEndTime,
    super.features,
    super.extraFields,
  });

  static SoftwareLicense fromEncryptedData({
    required String data,
    required String publicKey,
  }) {
    final base64Decoder = utf8.fuse(base64);
    final payload = json.decode(base64Decoder.decode(data));
    final softwareLicense = utf8.encode(payload['data']);
    final signature = RSASignature(base64.decode(payload['signature']));
    final algorithm = payload['algorithm'];
    final verifier = Signer(algorithm);

    // Verify signature
    verifier.init(false, PublicKeyParameter<RSAPublicKey>(_pemToRsaPublicKey(publicKey)));
    if (!verifier.verifySignature(softwareLicense, signature)) {
      return AlwaysInvalidSoftwareLicense();
    }

    final jsonData = json.decode(base64Decoder.decode(payload['data']));
    return SoftwareLicense.fromMap(jsonData);
  }

  static RSAPublicKey _pemToRsaPublicKey(String pem) {
    final lines = pem.split('\n').where((line) => line.isNotEmpty && !line.startsWith('---')).toList();
    final b64String = lines.join('');
    final asn1Parser = ASN1Parser(base64.decode(b64String));
    final asn1Sequence = asn1Parser.nextObject() as ASN1Sequence;

    final publicKeyString = asn1Sequence.elements?[1] as ASN1BitString;
    final publicKeyBytes = publicKeyString.stringValues!;
    final publicKeyParser = ASN1Parser(Uint8List.fromList(publicKeyBytes));
    final publicKeySequence = publicKeyParser.nextObject() as ASN1Sequence;

    final modulus = publicKeySequence.elements?[0] as ASN1Integer;
    final exponent = publicKeySequence.elements?[1] as ASN1Integer;

    return RSAPublicKey(_decodeBigInt(modulus.valueBytes!), _decodeBigInt(exponent.valueBytes!));
  }

  static BigInt _decodeBigInt(List<int> bytes) {
    final negative = bytes.isNotEmpty && bytes[0] & 0x80 == 0x80;
    final unsignedBytes = negative ? [0] + bytes : bytes;
    final result = BigInt.parse(unsignedBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(), radix: 16);
    return negative ? result.toUnsigned(8 * bytes.length) : result;
  }
}

class AlwaysInvalidSoftwareLicense extends SoftwareLicense {
  @override
  bool isValid() {
    return false;
  }

  @override
  bool hasFeature(String feature) {
    return false;
  }
}

class AlwaysValidSoftwareLicense extends SoftwareLicense {
  AlwaysValidSoftwareLicense({
    super.userId,
    super.machineId,
    super.licenseId,
    super.validStartTime,
    super.validEndTime,
    super.features,
    super.extraFields,
  });

  @override
  bool isValid() {
    return true;
  }

  @override
  bool hasFeature(String feature) {
    return true;
  }
}
