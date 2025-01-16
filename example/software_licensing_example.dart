import 'dart:io';

import 'package:software_licensing/software_licensing.dart';

Future<void> main() async {
  var licensingClient = SoftwareLicensingClient(
    licenseCache: EncryptedLicenseCache(
      publicKey: 'publicKey',
      licensePath: '',
    ),
    licenseValidator: AlwaysValidLicenseValidator(),
  );
  var softwareLicense = await licensingClient.loadLicense();
  softwareLicense ??= await licensingClient.validateLicense(
    licenseId: 'LicenseKey',
    machineId: Platform.localHostname,
    userId: 'User Name',
  );

  if (softwareLicense.isValid() && softwareLicense.hasFeature('appname_1')) {
    // Do something that requires a valid license here
  }
}
