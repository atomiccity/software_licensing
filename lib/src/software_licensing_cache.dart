import 'dart:convert';
import 'dart:io';

import 'package:software_licensing/src/software_license.dart';

class LicenseCache {
  final String licensePath;

  const LicenseCache({required this.licensePath});

  Future<void> saveLicense(SoftwareLicense license) async {
    var licenseFile = File(licensePath);

    if (!licenseFile.existsSync()) {
      licenseFile.create(recursive: true);
    }

    // Save license data
    await licenseFile.writeAsString(json.encode(license.toMap()));
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
  Future<void> saveLicense(covariant EncryptedSoftwareLicense license) async {
    var licenseFile = File(licensePath);

    if (!licenseFile.existsSync()) {
      licenseFile.create(recursive: true);
    }

    // Save encrypted data (strip off bookends if they exist)
    await licenseFile.writeAsString(_cleanLicense(license.encryptedData));
  }

  @override
  Future<SoftwareLicense?> loadLicense() async {
    final licenseFile = File(licensePath);

    if (!licenseFile.existsSync()) {
      return null;
    }

    // Return encrypted data inside EncryptedSoftwareLicense class
    return EncryptedSoftwareLicense.fromEncryptedData(
      data: _cleanLicense(await licenseFile.readAsString()),
      publicKey: publicKey,
    );
  }

  String _cleanLicense(String licenseData) {
    return licenseData
        .replaceFirst(licenseFileHeader, '')
        .replaceFirst(licenseFileFooter, '')
        .replaceAll('\r', '')
        .replaceAll('\n', '');
  }
}
