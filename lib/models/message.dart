class Message {
  final String fromUserId;
  final String toUserId;
  final String message;
  // final String avatar;
  final DateTime createdAt;

  const Message({
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    // required this.avatar,
    required this.createdAt,
  });

  static Message fromJson(Map<String, dynamic> json) => Message(
        fromUserId: json['fromUserId'],
        toUserId: json['toUserId'],
        message: json['message'],
        // avatar: json['avatar'],
        createdAt: (json['createdAt']).toDate(),
      );

  Map<String, dynamic> toJson() => {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'message': message,
        // 'avatar': avatar,
        'createdAt': createdAt.toUtc(),
      };
}
