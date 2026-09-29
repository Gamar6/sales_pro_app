class ContactPerson {
  final int id;
  final String name;
  final String nohp;

  const ContactPerson({
    required this.id,
    required this.name,
    required this.nohp,
  });

  factory ContactPerson.fromJson(Map<String, dynamic> json) {
    return ContactPerson(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nohp: json['nohp'] as String? ?? '',
    );
  }
}
