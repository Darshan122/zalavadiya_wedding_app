class GuestModel {
  final String id;
  String name;
  String phone;
  String city;
  String inviteType; // 'સપરિવાર', 'બે વ્યક્તિ', '૧ વ્યક્તિ'
  bool mandap;      // ૨૫ જાન્યુઆરી ૩:૦૦ PM માંડવ મુહૂર્ત
  bool garba;       // ૨૫ જાન્યુઆરી ૮:૦૦ PM રાસ-ગરબા & ડીજે
  bool haldi;       // ૨૬ જાન્યુઆરી ૯:૦૦ AM પીઠી / હળદર
  bool jaan;        // ૨૬ જાન્યુઆરી ૫:૦૦ PM જાન પ્રસ્થાન
  bool lagna;       // ૨૬ જાન્યુઆરી ૭:૦૦ PM લગ્ન સમારોહ
  String status;    // 'Pending', 'Sent'
  DateTime? sentAt;
  String notes;

  GuestModel({
    required this.id,
    required this.name,
    required this.phone,
    this.city = 'ગુજરાત',
    this.inviteType = 'સપરિવાર',
    this.mandap = true,
    this.garba = true,
    this.haldi = false,
    this.jaan = true,
    this.lagna = true,
    this.status = 'Pending',
    this.sentAt,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'city': city,
      'inviteType': inviteType,
      'mandap': mandap,
      'garba': garba,
      'haldi': haldi,
      'jaan': jaan,
      'lagna': lagna,
      'status': status,
      'sentAt': sentAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? 'ગુજરાત',
      inviteType: json['inviteType']?.toString() ?? 'સપરિવાર',
      mandap: json['mandap'] == true || json['mandap']?.toString() == 'true',
      garba: json['garba'] == true || json['garba']?.toString() == 'true',
      haldi: json['haldi'] == true || json['haldi']?.toString() == 'true',
      jaan: json['jaan'] == true || json['jaan']?.toString() == 'true',
      lagna: json['lagna'] == true || json['lagna']?.toString() == 'true',
      status: json['status']?.toString() ?? 'Pending',
      sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt']) : null,
      notes: json['notes']?.toString() ?? '',
    );
  }

  GuestModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? city,
    String? inviteType,
    bool? mandap,
    bool? garba,
    bool? haldi,
    bool? jaan,
    bool? lagna,
    String? status,
    DateTime? sentAt,
    String? notes,
  }) {
    return GuestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      inviteType: inviteType ?? this.inviteType,
      mandap: mandap ?? this.mandap,
      garba: garba ?? this.garba,
      haldi: haldi ?? this.haldi,
      jaan: jaan ?? this.jaan,
      lagna: lagna ?? this.lagna,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      notes: notes ?? this.notes,
    );
  }
}
