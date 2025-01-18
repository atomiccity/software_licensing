import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:software_licensing/src/software_license.dart';

class LicenseValidator {
  Future<String?> validateLicense({
    String? licenseId,
    String? machineId,
    String? userId,
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
    String? licenseId,
    String? machineId,
    String? userId,
  }) async {
    var reqParams = <String, String>{};
    if (licenseId != null) {
      reqParams['license_id'] = licenseId;
    }
    if (machineId != null) {
      reqParams['machine_id'] = machineId;
    }
    if (userId != null) {
      reqParams['user_id'] = userId;
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
    String? licenseId,
    String? machineId,
    String? userId,
  }) onValidate;

  CallbackLicenseValidator({
    required this.onValidate,
  });

  @override
  Future<String?> validateLicense({String? licenseId, String? machineId, String? userId}) {
    return onValidate(licenseId: licenseId, machineId: machineId, userId: userId);
  }
}

class AlwaysValidLicenseValidator extends LicenseValidator {
  @override
  Future<String?> validateLicense({
    String? licenseId,
    String? machineId,
    String? userId,
  }) async {
    return json.encode(SoftwareLicense(
      licenseId: licenseId,
      machineId: machineId,
      userId: userId,
    ).toMap());
  }
}
