class SoftwareLicense {
  final String? userId;
  final String? machineId;
  final String? licenseId;
  final DateTime? validStartTime;
  final DateTime? validEndTime;
  final List<String> features = List.empty(growable: true);
  final Map<String, dynamic> extraFields = Map.from({});

  SoftwareLicense({
    this.userId,
    this.machineId,
    this.licenseId,
    this.validStartTime,
    this.validEndTime,
    List<String>? features,
    Map<String, dynamic>? extraFields,
  }) {
    if (features != null) {
      this.features.addAll(features);
    }
    if (extraFields != null) {
      this.extraFields.addAll(extraFields);
    }
  }

  bool isValid() {
    var now = DateTime.now();
    return (now.isAfter(validStartTime ?? DateTime.fromMillisecondsSinceEpoch(0))) &&
        (now.isBefore(validEndTime ?? DateTime.fromMillisecondsSinceEpoch(0x7fffffffffffffff)));
  }

  bool hasFeature(String feature) {
    return features.contains(feature);
  }

  T get<T>(String fieldName) {
    return extraFields[fieldName] as T;
  }

  static SoftwareLicense fromMap(Map<String, dynamic> map) {
    return SoftwareLicense(
      userId: map['user_id'],
      machineId: map['machine_id'],
      licenseId: map['license_id'],
      validStartTime: (map['valid_start_time'] != null) ? DateTime.tryParse(map['valid_start_time']) : null,
      validEndTime: (map['valid_end_time'] != null) ? DateTime.tryParse(map['valid_start_time']) : null,
      features: map['features'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (userId != null) 'user_id': userId,
      if (machineId != null) 'machine_id': machineId,
      if (licenseId != null) 'license_id': licenseId,
      if (validStartTime != null) 'valid_start_time': validStartTime!.toIso8601String(),
      if (validEndTime != null) 'valid_end_time': validEndTime!.toIso8601String(),
      'features': features,
    };
  }
}

class AlwaysInvalidSoftwareLicense extends SoftwareLicense {
  @override
  bool isValid() {
    return false;
  }

  @override
  bool hasFeature(String feature) {
    return false;
  }
}

class AlwaysValidSoftwareLicense extends SoftwareLicense {
  AlwaysValidSoftwareLicense({
    super.userId,
    super.machineId,
    super.licenseId,
    super.validStartTime,
    super.validEndTime,
    super.features,
    super.extraFields,
  });

  @override
  bool isValid() {
    return true;
  }

  @override
  bool hasFeature(String feature) {
    return true;
  }
}
