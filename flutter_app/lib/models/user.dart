class User {
  final String uid;
  final String name;
  bool isLocked;

  User({
    required this.uid,
    required this.name,
    this.isLocked = true,
  });

  // Factory method to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      name: json['name'] as String,
      isLocked: json['isLocked'] != null ? json['isLocked'] as bool : true,
    );
  }

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'isLocked': isLocked,
    };
  }
}
