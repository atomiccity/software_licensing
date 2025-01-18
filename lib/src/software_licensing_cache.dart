import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';
import 'package:software_licensing/src/software_license.dart';

class LicenseCache {
  final String licensePath;

  const LicenseCache({required this.licensePath});

  Future<void> saveLicense(String licenseData) async {
    var licenseFile = File(licensePath);

    if (!licenseFile.existsSync()) {
      licenseFile.create(recursive: true);
    }

    // Save license data
    await licenseFile.writeAsString(licenseData);
  }

  Future<SoftwareLicense?> loadLicense() async {
    var licenseFile = File(licensePath);

    if (!licenseFile.existsSync()) {
      return null;
    }

    // Read license data
    var licenseData = await licenseFile.readAsString();
    return SoftwareLicense.fromMap(json.decode(licenseData));
  }
}

class EncryptedLicenseCache extends LicenseCache {
  static const licenseFileHeader = '-----BEGIN LICENSE FILE-----';
  static const licenseFileFooter = '------END LICENSE FILE------';
  final String publicKey;

  const EncryptedLicenseCache({
    required this.publicKey,
    required super.licensePath,
  });

  @override
  Future<void> saveLicense(String licenseData) async {
    var licenseFile = File(licensePath);

    if (!licenseFile.existsSync()) {
      licenseFile.create(recursive: true);
    }

    // Save encrypted data (strip off bookends if they exist)
    await licenseFile.writeAsString(_cleanLicense(licenseData));
  }

  @override
  Future<SoftwareLicense?> loadLicense() async {
    final licenseFile = File(licensePath);

    if (!licenseFile.existsSync()) {
      return null;
    }

    final data = _cleanLicense(await licenseFile.readAsString());
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

  String _cleanLicense(String licenseData) {
    return licenseData
        .replaceFirst(licenseFileHeader, '')
        .replaceFirst(licenseFileFooter, '')
        .replaceAll('\r', '')
        .replaceAll('\n', '');
  }
}
