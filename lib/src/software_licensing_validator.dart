import 'package:software_licensing/software_licensing.dart';

abstract class LicenseValidator {
  const LicenseValidator();

  bool isValid(SoftwareLicense license);
}

class StatusLicenseValidator extends LicenseValidator {
  @override
  bool isValid(SoftwareLicense license) {
    return license.license.toLowerCase() == 'valid';
  }
}

class BuildBeforeExpireLicenseValidator extends LicenseValidator {
  final DateTime buildDate;

  const BuildBeforeExpireLicenseValidator({
    required this.buildDate,
  });

  @override
  bool isValid(SoftwareLicense license) {
    if (license.license == 'valid') {
      return true;
    } else if (license.expires != null) {
      return license.expires!.isAfter(buildDate);
    } else {
      return false;
    }
  }
}
