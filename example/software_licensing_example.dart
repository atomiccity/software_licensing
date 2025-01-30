import 'dart:io';

import 'package:software_licensing/software_licensing.dart';
import 'package:software_licensing/src/software_licensing_validator.dart';

Future<void> main() async {
  // Create license client
  var licenseClient = SoftwareLicenseClient(
    licenseCache: EncryptedLicenseCache(
      publicKey: 'Public Key in PEM format',
      licensePath: 'File name & path of license file',
    ),
    licenseActivator: HttpLicenseActivator(
      host: 'example.com',
      path: '/api/v1/validate',
    ),
    licenseValidator: BuildBeforeExpireLicenseValidator(
      buildDate: DateTime(2024, 12, 30),
    ),
    defaultProductId: 1, // Whatever the activator expects this software ID to be
    defaultSiteId: Platform.localHostname, // Can tie activation to host name
  );

  // First, try to load local license
  var softwareLicense = await licenseClient.loadLicense();

  // If local license doesn't exists, try to activate customer's license key
  softwareLicense ??= await licenseClient.activateLicense(
    licenseKey: 'license_key',
    onSuccess: (message) => print('Success: $message'),
    onError: (message) => print('Error: $message'),
  );

  // At this point, softwareLicense won't be null. It will eiter be a valid
  // license or an instance of [AlwaysInvalidLicense]. Common functions are
  // exposed via [licenseClient] so you don't need to use softwareLicense
  // usually.

  if (licenseClient.validLicense()) {
    // Do something that requires valid licene here
  }
}
