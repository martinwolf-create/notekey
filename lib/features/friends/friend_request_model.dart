class FriendRequest {
  final String fromUserId;
  final String toUserId;
  final DateTime timestamp;

  FriendRequest({
    required this.fromUserId,
    required this.toUserId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      fromUserId: map['fromUserId'],
      toUserId: map['toUserId'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
