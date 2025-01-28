import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:software_licensing/src/software_license.dart';

class LicenseValidator {
  Future<String?> validateLicense({
    String? licenseKey,
    String? siteId,
    String? productId,
  }) async {
    return null;
  }
}

class HttpLicenseValidator extends LicenseValidator {
  final String host;
  final String? path;

  HttpLicenseValidator({required this.host, this.path});

  @override
  Future<String?> validateLicense({
    String? licenseKey,
    String? siteId,
    String? productId,
  }) async {
    var reqParams = {
      'item_id': productId,
      'license_key': licenseKey,
    };
    if (siteId != null) {
      reqParams['site_id'] = siteId;
    }
    var reqUri = Uri.https(host, path ?? '', reqParams);

    // Make request
    var response = await http.get(reqUri);

    // Process response
    if (response.statusCode != 200) {
      return null;
    }

    var responseMap = json.decode(response.body);
    if (responseMap['status'] != 'valid') {
      return null;
    }

    return responseMap['license'];
  }
}

class CallbackLicenseValidator extends LicenseValidator {
  final Future<String?> Function({
    String? licenseKey,
    String? siteId,
    String? productId,
  }) onValidate;

  CallbackLicenseValidator({
    required this.onValidate,
  });

  @override
  Future<String?> validateLicense({
    String? licenseKey,
    String? siteId,
    String? productId,
  }) {
    return onValidate(licenseKey: licenseKey, siteId: siteId, productId: productId);
  }
}

class AlwaysValidLicenseValidator extends LicenseValidator {
  @override
  Future<String?> validateLicense({
    String? licenseKey,
    String? siteId,
    String? productId,
  }) async {
    return json.encode(AlwaysValidSoftwareLicense().toMap());
  }
}
