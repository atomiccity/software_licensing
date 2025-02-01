import 'package:software_licensing/software_licensing.dart';
import 'package:test/test.dart';

import 'example_edd_packets.dart';

void main() {
  group('Validator tests', () {
    var noExpirationLicense = SoftwareLicense.fromMap(eddNoExpiration);
    var withExpirationLicense = SoftwareLicense.fromMap(eddWithExpiration);
    var expiredLicense = SoftwareLicense.fromMap(eddExpired);

    test('EDD License Status Validator', () {
      var validator = EDDStatusLicenseValidator();
      expect(validator.isValid(noExpirationLicense), isTrue);
      expect(validator.isValid(withExpirationLicense), isTrue);
      expect(validator.isValid(expiredLicense), isFalse);
    });

    test('EDD Build Date Validator with Valid Licenses', () {
      var buildDate = expiredLicense.getDateTime('expires')!.subtract(Duration(days: 30));
      var validator = EDDBuildBeforeExpireLicenseValidator(buildDate: buildDate);
      expect(validator.isValid(noExpirationLicense), isTrue);
      expect(validator.isValid(withExpirationLicense), isTrue);
      expect(validator.isValid(expiredLicense), isTrue);
    });

    test('EDD Build Date Validator with Invalid Licenses', () {
      var buildDate = expiredLicense.getDateTime('expires')!.add(Duration(days: 30));
      var validator = EDDBuildBeforeExpireLicenseValidator(buildDate: buildDate);
      expect(validator.isValid(noExpirationLicense), isTrue);
      expect(validator.isValid(withExpirationLicense), isTrue);
      expect(validator.isValid(expiredLicense), isFalse);
    });
  });
}
