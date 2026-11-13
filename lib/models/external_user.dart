class ExternalUser {
  final int id;
  final String fullName;
  final String email;
  final String image;

  const ExternalUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.image,
  });

  factory ExternalUser.fromJson(Map<String, dynamic> json) {
    return ExternalUser(
      id: json['id'] as int,
      fullName: '${json['firstName']} ${json['lastName']}',
      email: json['email'] as String,
      image: json['image'] as String,
    );
  }
}