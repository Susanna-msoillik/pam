class AppUser {
  final String id;
  final String name;
  final String email;
  const AppUser({required this.id, required this.name, required this.email});
  factory AppUser.fromJson(Map<String, dynamic> data) => AppUser(
    id: (data['id'] as int).toString(),
    name: data['name'] as String,
    email: data['email'] as String,
  );
}
