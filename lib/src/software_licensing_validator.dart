import 'package:software_licensing/src/software_license.dart';

class LicenseValidator {
  Future<SoftwareLicense?> validateLicense({
    String? licenseId,
    String? machineId,
    String? userId,
  }) async {
    return null;
  }
}

class AlwaysValidLicenseValidator extends LicenseValidator {
  @override
  Future<SoftwareLicense?> validateLicense({
    String? licenseId,
    String? machineId,
    String? userId,
  }) async {
    return AlwaysValidSoftwareLicense(
      licenseId: licenseId,
      userId: userId,
      machineId: machineId,
    );
  }
}
