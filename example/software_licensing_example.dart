import 'dart:io';

import 'package:software_licensing/software_licensing.dart';

Future<void> main() async {
  // If using the EDDBuildBeforeExpireLicenseValidator, passing this to
  // `flutter build` can inject the build date:
  // --dart-define=BUILD_DATE="$(date -Idate)"
  var buildDate = const String.fromEnvironment('BUILD_DATE');

  // Create license client
  var licenseClient = SoftwareLicenseClient(
    licenseCache: EncryptedLicenseCache.fromPem(
      publicKeyPem: 'Public Key in PEM format',
      licensePath: 'File name & path of license file',
    ),
    licenseActivator: HttpLicenseActivator(
      host: 'example.com',
      path: '/api/v1/validate',
    ),
    licenseValidator: EDDBuildBeforeExpireLicenseValidator(
      buildDate: DateTime.parse(buildDate),
    ),
    defaultProductId: 1, // Whatever the activator expects this software ID to be
    defaultSiteId: Platform.localHostname, // Can tie activation to host name
  );

  // First, try to load local license
  var softwareLicense = await licenseClient.loadLicense();

  // If local license does exist, make sure it's valid
  if (!licenseClient.isLicenseValid()) {
    // License isn't valid
  }

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

  if (licenseClient.isLicenseValid()) {
    // Do something that requires valid licene here
  }
}
