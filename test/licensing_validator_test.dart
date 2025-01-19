import 'dart:convert';

import 'package:software_licensing/software_licensing.dart';
import 'package:test/test.dart';

void main() {
  group('Validator Tests', () {
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

    setUp(() {
      // Additional setup goes here.
    });

    test('Simple validation', () async {
      var licenseData = await testValidator.onValidate(
        userId: 'user',
        machineId: 'machine',
        licenseId: 'license',
      );

      expect(licenseData, isNotNull);

      var dataMap = json.decode(licenseData!);

      expect(dataMap['user_id'], equals('user'));
      expect(dataMap['machine_id'], equals('machine'));
      expect(dataMap['license_id'], equals('license'));
    });
  });
}
