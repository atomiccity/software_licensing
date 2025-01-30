import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:software_licensing/src/software_license.dart';

class LicenseActivator {
  Future<String?> activateLicense({
    String? licenseKey,
    String? siteId,
    int? productId,
    Function(String message)? onError,
  }) async {
    return null;
  }
}

class HttpLicenseActivator extends LicenseActivator {
  final String host;
  final String? path;

  HttpLicenseActivator({required this.host, this.path});

  @override
  Future<String?> activateLicense({
    String? licenseKey,
    String? siteId,
    int? productId,
    Function(String message)? onError,
  }) async {
    var reqParams = {
      'item_id': productId.toString(),
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
      if (onError != null) {
        onError("Licensing server error");
      }
      return null;
    }

    var responseMap = json.decode(response.body);
    if (!responseMap['success']) {
      if (onError != null) {
        onError("Invalid license: ${responseMap['error']}");
      }
      return null;
    }

    return responseMap['license'];
  }
}

class CallbackLicenseActivator extends LicenseActivator {
  final Future<String?> Function({
    String? licenseKey,
    String? siteId,
    int? productId,
  }) onActivate;

  CallbackLicenseActivator({
    required this.onActivate,
  });

  @override
  Future<String?> activateLicense({
    String? licenseKey,
    String? siteId,
    int? productId,
    Function(String message)? onError,
  }) {
    return onActivate(licenseKey: licenseKey, siteId: siteId, productId: productId);
  }
}

class AlwaysValidLicenseValidator extends LicenseActivator {
  @override
  Future<String?> activateLicense({
    String? licenseKey,
    String? siteId,
    int? productId,
    Function(String message)? onError,
  }) async {
    return json.encode(AlwaysValidSoftwareLicense().toMap());
  }
}
