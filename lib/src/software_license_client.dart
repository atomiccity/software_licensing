import 'package:software_licensing/src/software_license.dart';
import 'package:software_licensing/src/software_license_cache.dart';
import 'package:software_licensing/src/software_license_activator.dart';
import 'package:software_licensing/src/software_license_validator.dart';

class SoftwareLicenseClient {
  final LicenseCache _licenseCache;
  final LicenseActivator _licenseActivator;
  final LicenseValidator _licenseValidator;
  final String? customerField;
  final String? emailField;
  final String? itemField;
  final String? expireField;

  int? defaultProductId;
  String? defaultSiteId;

  SoftwareLicense? _cachedLicense;

  SoftwareLicenseClient({
    required LicenseCache licenseCache,
    required LicenseActivator licenseActivator,
    required LicenseValidator licenseValidator,
    this.defaultProductId,
    this.defaultSiteId,
    this.customerField,
    this.emailField,
    this.itemField,
    this.expireField,
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
      if (isLicenseValid() && onSuccess != null) {
        if (customerField != null) {
          onSuccess("Thank you for registering ${_cachedLicense!.getString(customerField!) ?? ""}");
        } else {
          onSuccess("Thank you for registering");
        }
      } else if (!isLicenseValid() && onError != null) {
        onError("License is invalid");
      }
    }
    return _cachedLicense ?? AlwaysInvalidSoftwareLicense();
  }

  bool isLicenseValid() {
    if (_cachedLicense is AlwaysInvalidSoftwareLicense) {
      return false;
    } else if (_cachedLicense is AlwaysValidSoftwareLicense) {
      return true;
    }
    return ((_cachedLicense != null) && (_licenseValidator.isValid(_cachedLicense!)));
  }

  String licensedUser() {
    if (customerField != null) {
      return _cachedLicense?.getString(customerField!) ?? '';
    } else {
      return '';
    }
  }

  String licensedEmail() {
    if (emailField != null) {
      return _cachedLicense?.getString(emailField!) ?? '';
    } else {
      return '';
    }
  }

  String licensedProduct() {
    if (itemField != null) {
      return _cachedLicense?.getString(itemField!) ?? '';
    } else {
      return '';
    }
  }

  DateTime licenseExpireDate() {
    var backupExpireDate = DateTime.now().add(Duration(days: 364 * 100));
    if (expireField != null) {
      return _cachedLicense?.getDateTime(expireField!) ?? backupExpireDate;
    } else {
      return backupExpireDate;
    }
  }
}
