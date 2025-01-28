import 'package:software_licensing/src/software_license.dart';
import 'package:software_licensing/src/software_licensing_cache.dart';
import 'package:software_licensing/src/software_licensing_validator.dart';

class SoftwareLicensingClient {
  final LicenseCache _licenseCache;
  final LicenseValidator _licenseValidator;
  int? defaultProductId;
  String? defaultSiteId;

  SoftwareLicensingClient({
    required LicenseCache licenseCache,
    required LicenseValidator licenseValidator,
    this.defaultProductId,
    this.defaultSiteId,
  })  : _licenseCache = licenseCache,
        _licenseValidator = licenseValidator;

  Future<SoftwareLicense?> loadLicense() async {
    return _licenseCache.loadLicense();
  }

  Future<SoftwareLicense> validateLicense({
    required String licenseKey,
    String? siteId,
    int? productId,
    Function(String message)? onSuccess,
    Function(String message)? onError,
  }) async {
    var licenseData = await _licenseValidator.validateLicense(
      licenseKey: licenseKey,
      siteId: (siteId != null) ? siteId : defaultSiteId,
      productId: (productId != null) ? productId : defaultProductId,
      onError: onError,
    );

    if (licenseData == null) {
      if (onError != null) {
        onError("No license received from server");
      }
      return AlwaysInvalidSoftwareLicense();
    }

    // Save license locally, then reload it (incase it was encrypted data)
    _licenseCache.saveLicense(licenseData);
    var license = await _licenseCache.loadLicense();
    if ((license == null) && (onError != null)) {
      onError("License could not be verified");
    }
    if ((license != null) && (onSuccess != null)) {
      onSuccess("Thank you for registering ${license.customerName}");
    }
    return license ?? AlwaysInvalidSoftwareLicense();
  }
}
