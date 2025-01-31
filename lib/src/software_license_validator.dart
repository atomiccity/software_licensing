import 'package:software_licensing/software_licensing.dart';

abstract class LicenseValidator {
  const LicenseValidator();

  bool isValid(SoftwareLicense license);
}

class EDDStatusLicenseValidator extends LicenseValidator {
  @override
  bool isValid(SoftwareLicense license) {
    return (license.getString('license')?.toLowerCase() == 'valid');
  }
}

class EDDBuildBeforeExpireLicenseValidator extends LicenseValidator {
  final DateTime buildDate;

  const EDDBuildBeforeExpireLicenseValidator({
    required this.buildDate,
  });

  @override
  bool isValid(SoftwareLicense license) {
    if (license.getString('license')?.toLowerCase() == 'valid') {
      return true;
    } else if (license.getDateTime('expires') != null) {
      return license.getDateTime('expires')!.isAfter(buildDate);
    } else {
      return false;
    }
  }
}

class CallbackLicenseValidator extends LicenseValidator {
  final bool Function(SoftwareLicense license) onValidate;

  const CallbackLicenseValidator({required this.onValidate});

  @override
  bool isValid(SoftwareLicense license) {
    return onValidate(license);
  }
}
