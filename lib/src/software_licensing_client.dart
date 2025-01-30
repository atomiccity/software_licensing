import 'package:software_licensing/src/software_license.dart';
import 'package:software_licensing/src/software_licensing_cache.dart';
import 'package:software_licensing/src/software_licensing_activator.dart';
import 'package:software_licensing/src/software_licensing_validator.dart';

class SoftwareLicenseClient {
  final LicenseCache _licenseCache;
  final LicenseActivator _licenseActivator;
  final LicenseValidator _licenseValidator;

  int? defaultProductId;
  String? defaultSiteId;

  SoftwareLicense? _cachedLicense;

  SoftwareLicenseClient({
    required LicenseCache licenseCache,
    required LicenseActivator licenseActivator,
    required LicenseValidator licenseValidator,
    this.defaultProductId,
    this.defaultSiteId,
  })  : _licenseCache = licenseCache,
        _licenseActivator = licenseActivator,
        _licenseValidator = licenseValidator;

  Future<SoftwareLicense?> loadLicense() async {
    _cachedLicense = await _licenseCache.loadLicense();
    return _cachedLicense;
  }

  Future<SoftwareLicense> activateLicense({
    required String licenseKey,
    String? siteId,
    int? productId,
    Function(String message)? onSuccess,
    Function(String message)? onError,
  }) async {
    var licenseData = await _licenseActivator.activateLicense(
      licenseKey: licenseKey,
      siteId: (siteId != null) ? siteId : defaultSiteId,
      productId: (productId != null) ? productId : defaultProductId,
      onError: onError,
    );

    if (licenseData == null) {
      // If licenseData == null, then onError was already called in activateLicense.
      // Don't call it again.
      return AlwaysInvalidSoftwareLicense();
    }

    // Save license locally, then reload it (incase it was encrypted data)
    await _licenseCache.saveLicense(licenseData);
    _cachedLicense = await _licenseCache.loadLicense();
    if ((_cachedLicense == null) && (onError != null)) {
      onError("License could not be verified");
    }
    if (_cachedLicense != null) {
      if (validLicense() && onSuccess != null) {
        onSuccess("Thank you for registering ${_cachedLicense!.customerName}");
      } else if (!validLicense() && onError != null) {
        onError("License is invalid");
      }
    }
    return _cachedLicense ?? AlwaysInvalidSoftwareLicense();
  }

  bool validLicense() {
    return ((_cachedLicense != null) && (_licenseValidator.isValid(_cachedLicense!)));
  }

  String licensedUser() {
    return _cachedLicense?.customerName ?? '';
  }

  String licensedEmail() {
    return _cachedLicense?.customerEmail ?? '';
  }

  String licensedProduct() {
    return _cachedLicense?.itemName ?? '';
  }
}
