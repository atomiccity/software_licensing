import 'dart:convert';

import 'package:software_licensing/software_licensing.dart';
import 'package:test/test.dart';

void main() {
  group('Client Tests', () {
    var testValidator = CallbackLicenseValidator(
      onValidate: ({licenseId, machineId, userId}) async {
        return json.encode({
          'user_id': userId,
          'machine_id': machineId,
          'license_id': licenseId,
          'features': ['test1', 'test2', 'test3'],
          'extra_fields': {
            'new_public_key': 'new_key',
            'extra_field_1': 'a',
            'extra_field_2': 'b',
          },
        });
      },
    );
    String? data;

    var testCache = CallbackLicenseCache(
      onSave: (licenseData) async {
        data = licenseData;
      },
      onLoad: () async {
        if (data == null) {
          return null;
        } else {
          return SoftwareLicense.fromMap(json.decode(data!));
        }
      },
    );

    setUp(() {
      // Additional setup goes here.
    });

    test('Standard usage', () async {
      var client = SoftwareLicensingClient(
        licenseCache: testCache,
        licenseValidator: testValidator,
      );
      var license = await client.loadLicense();
      expect(license, isNull);
      license = await client.validateLicense(
        licenseId: 'license',
        userId: 'user',
        machineId: 'machine',
      );
      expect(license, isNotNull);

      expect(license.licenseId, equals('license'));
      expect(license.machineId, equals('machine'));
      expect(license.userId, equals('user'));
      expect(license.hasFeature('test1'), isTrue);
      expect(license.extraFields['extra_field_1'], equals('a'));
    });
  });
}
