class Institute {
  const Institute({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    this.email,
    this.website,
    this.logoUrl,
    required this.timezone,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String timezone;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  factory Institute.fromJson(Map<String, dynamic> json) {
    return Institute(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String?,
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'phone': phone,
      'email': email,
      'website': website,
      'logo_url': logoUrl,
      'timezone': timezone,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Institute copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? phone,
    String? email,
    String? website,
    String? logoUrl,
    String? timezone,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Institute(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      timezone: timezone ?? this.timezone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
