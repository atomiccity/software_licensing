class SoftwareLicense {
  final String license;
  final int itemId;
  final String itemName;
  final String checksum;
  final DateTime? expires;
  final int paymentId;
  final String customerName;
  final String customerEmail;
  final int licenseLimit;
  final int siteCount;
  final int? activationsLeft;
  final int? priceId;

  const SoftwareLicense({
    required this.license,
    required this.itemId,
    required this.itemName,
    required this.checksum,
    this.expires,
    required this.paymentId,
    required this.customerName,
    required this.customerEmail,
    required this.licenseLimit,
    required this.siteCount,
    this.activationsLeft,
    this.priceId,
  });

  static SoftwareLicense fromMap(Map<String, dynamic> map) {
    return SoftwareLicense(
      license: map['license'],
      itemId: map['item_id'],
      itemName: map['item_name'],
      checksum: map['checksum'],
      expires: (map['expires'] == 'lifetime') ? null : DateTime.tryParse(map['expires']),
      paymentId: map['payment_id'],
      customerName: map['customer_name'],
      customerEmail: map['customer_email'],
      licenseLimit: map['license_limit'],
      siteCount: map['site_count'],
      activationsLeft: (map['activations_left'] == 'unlimited') ? null : map['activations_left'],
      priceId: (map['price_id'] == false) ? null : map['price_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'license': license,
      'item_id': itemId,
      'item_name': itemName,
      'checksum': checksum,
      'expires': (expires == null) ? 'lifetime' : expires!.toIso8601String(),
      'payment_id': paymentId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'license_limit': licenseLimit,
      'site_count': siteCount,
      'activations_left': (activationsLeft == null) ? 'unlimited' : activationsLeft,
      'price_id': (priceId == null) ? false : priceId,
    };
  }
}

class AlwaysInvalidSoftwareLicense extends SoftwareLicense {
  AlwaysInvalidSoftwareLicense({
    super.license = 'invalid',
    super.itemId = 0,
    super.itemName = '',
    super.checksum = '',
    super.paymentId = 0,
    super.customerName = 'Invalid Customer',
    super.customerEmail = 'Invalid Email',
    super.licenseLimit = 0,
    super.siteCount = 0,
  });
}

class AlwaysValidSoftwareLicense extends SoftwareLicense {
  AlwaysValidSoftwareLicense({
    super.license = 'valid',
    super.itemId = 0,
    super.itemName = 'Free Product',
    super.checksum = '',
    super.paymentId = 0,
    super.customerName = 'Valid Customer',
    super.customerEmail = 'Valid Email',
    super.licenseLimit = 0,
    super.siteCount = 0,
  });
}
