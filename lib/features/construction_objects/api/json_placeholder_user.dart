class JsonPlaceholderUser {
  const JsonPlaceholderUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.company,
  });

  factory JsonPlaceholderUser.fromJson(Map<String, dynamic> json) {
    return JsonPlaceholderUser(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: JsonPlaceholderAddress.fromJson(
        json['address'] as Map<String, dynamic>,
      ),
      company: JsonPlaceholderCompany.fromJson(
        json['company'] as Map<String, dynamic>,
      ),
    );
  }

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final JsonPlaceholderAddress address;
  final JsonPlaceholderCompany company;
}

class JsonPlaceholderAddress {
  const JsonPlaceholderAddress({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
  });

  factory JsonPlaceholderAddress.fromJson(Map<String, dynamic> json) {
    return JsonPlaceholderAddress(
      street: json['street'] as String,
      suite: json['suite'] as String,
      city: json['city'] as String,
      zipcode: json['zipcode'] as String,
    );
  }

  final String street;
  final String suite;
  final String city;
  final String zipcode;
}

class JsonPlaceholderCompany {
  const JsonPlaceholderCompany({
    required this.name,
    required this.catchPhrase,
    required this.bs,
  });

  factory JsonPlaceholderCompany.fromJson(Map<String, dynamic> json) {
    return JsonPlaceholderCompany(
      name: json['name'] as String,
      catchPhrase: json['catchPhrase'] as String,
      bs: json['bs'] as String,
    );
  }

  final String name;
  final String catchPhrase;
  final String bs;
}
