class Child {
  final String id;
  final String name;

  const Child({required this.id, required this.name});

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
