class UserProfile {
  final String id;
  final String displayName;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });
}
