class SoftwareLicense {
  final Map<String, dynamic> fields;

  SoftwareLicense({required this.fields});

  static SoftwareLicense fromMap(Map<String, dynamic> map) {
    return SoftwareLicense(fields: map);
  }

  Map<String, dynamic> toMap() {
    return fields;
  }

  int? getInt(String field) {
    return fields[field] as int?;
  }

  String? getString(String field) {
    return fields[field] as String?;
  }

  DateTime? getDateTime(String field) {
    var timeString = fields[field] as String?;
    if (timeString == null) {
      return null;
    } else {
      return DateTime.tryParse(timeString);
    }
  }
}

class AlwaysInvalidSoftwareLicense extends SoftwareLicense {
  AlwaysInvalidSoftwareLicense() : super(fields: {});
}

class AlwaysValidSoftwareLicense extends SoftwareLicense {
  AlwaysValidSoftwareLicense() : super(fields: {});
}
