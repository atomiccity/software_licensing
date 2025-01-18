import 'dart:convert';

import 'package:software_licensing/src/software_license.dart';

class LicenseValidator {
  Future<String?> validateLicense({
    String? licenseId,
    String? machineId,
    String? userId,
  }) async {
    return null;
  }
}

class AlwaysValidLicenseValidator extends LicenseValidator {
  @override
  Future<String?> validateLicense({
    String? licenseId,
    String? machineId,
    String? userId,
  }) async {
    return json.encode(SoftwareLicense(
      licenseId: licenseId,
      machineId: machineId,
      userId: userId,
    ).toMap());
  }
}
