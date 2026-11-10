class TripEvent {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime? timestamp;

  const TripEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.timestamp,
  });

  factory TripEvent.fromMap(Map<String, dynamic> map) {
    final rawTimestamp = map['timestamp'];
    final timestamp = rawTimestamp is num
        ? DateTime.fromMillisecondsSinceEpoch(rawTimestamp.toInt())
        : DateTime.tryParse(rawTimestamp?.toString() ?? '');

    return TripEvent(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? 'TRIP_UPDATE',
      title: map['title']?.toString() ?? 'Trip update',
      description: map['description']?.toString() ?? '',
      timestamp: timestamp,
    );
  }
}
