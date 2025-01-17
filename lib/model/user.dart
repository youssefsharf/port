class User {
  final String firstName;
  final String lastName;
  final int age;
  final String address;
  final String email;
  final String phone;
  final String city;

  User({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.address,
    required this.email,
    required this.phone,
    required this.city,
  });

  // Copy constructor to create a modified copy of a user
  User copy({
    String? firstName,
    String? lastName,
    int? age,
    String? address,
    String? email,
    String? phone,
    String? city,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
    );
  }
}
