import 'package:software_licensing/software_licensing.dart';

abstract class LicenseValidator {
  const LicenseValidator();

  bool isValid(SoftwareLicense license);
}

class EDDStatusLicenseValidator extends LicenseValidator {
  @override
  bool isValid(SoftwareLicense license) {
    if (license is AlwaysInvalidSoftwareLicense) return false;
    if (license is AlwaysValidSoftwareLicense) return true;
    return (license.license.toLowerCase() == 'valid');
  }
}

class BuildBeforeExpireLicenseValidator extends LicenseValidator {
  final DateTime buildDate;

  const BuildBeforeExpireLicenseValidator({
    required this.buildDate,
  });

  @override
  bool isValid(SoftwareLicense license) {
    if (license is AlwaysInvalidSoftwareLicense) return false;
    if (license is AlwaysValidSoftwareLicense) return true;

    if (license.license == 'valid') {
      return true;
    } else if (license.expires != null) {
      return license.expires!.isAfter(buildDate);
    } else {
      return false;
    }
  }
}
