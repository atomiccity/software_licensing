import 'package:software_licensing/src/software_license.dart';
import 'package:software_licensing/src/software_licensing_cache.dart';
import 'package:software_licensing/src/software_licensing_validator.dart';

class SoftwareLicensingClient {
  final LicenseCache _licenseCache;
  final LicenseValidator _licenseValidator;

  SoftwareLicensingClient({
    required LicenseCache licenseCache,
    required LicenseValidator licenseValidator,
  })  : _licenseCache = licenseCache,
        _licenseValidator = licenseValidator;

  Future<SoftwareLicense?> loadLicense() async {
    return _licenseCache.loadLicense();
  }

  Future<SoftwareLicense> validateLicense({
    String? licenseId,
    String? machineId,
    String? userId,
  }) async {
    var licenseData = await _licenseValidator.validateLicense(
      licenseId: licenseId,
      machineId: machineId,
      userId: userId,
    );

    if (licenseData == null) {
      return AlwaysInvalidSoftwareLicense();
    }

    // Save license locally, then reload it (incase it was encrypted data)
    _licenseCache.saveLicense(licenseData);
    return await _licenseCache.loadLicense() ?? AlwaysInvalidSoftwareLicense();
  }
}
