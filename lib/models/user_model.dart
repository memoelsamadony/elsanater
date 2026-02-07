class LoginRequest {
  final String emailOrPhone;
  final String password;
  final String centerCode;
  final bool rememberMe;

  LoginRequest({
    required this.emailOrPhone,
    required this.password,
    required this.centerCode,
    this.rememberMe = true,
  });

  Map<String, dynamic> toJson() => {
        'emailOrPhone': emailOrPhone,
        'password': password,
        'centerCode': centerCode,
        'rememberMe': rememberMe,
      };
}

class LoginResponse {
  final String token;
  final String email;
  final String firstName;
  final List<String> roles;
  final bool isVerified;

  LoginResponse({
    required this.token,
    required this.email,
    required this.firstName,
    required this.roles,
    required this.isVerified,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final int? governorateId;
  final String? governorateName;
  final bool? gender;
  final List<String> roles;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.governorateId,
    this.governorateName,
    this.gender,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      governorateId: json['governorateId'],
      governorateName: json['governorateName'],
      gender: json['gender'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }
}

class UpdateProfileRequest {
  final String? name;
  final String? phone;
  final String? address;
  final int? governorateId;
  final bool? gender;

  UpdateProfileRequest({
    this.name,
    this.phone,
    this.address,
    this.governorateId,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (governorateId != null) map['governorateId'] = governorateId;
    if (gender != null) map['gender'] = gender;
    return map;
  }
}
