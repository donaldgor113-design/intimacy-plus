class ChatMessage {
  final int? id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({this.id, required this.role, required this.content, DateTime? timestamp, this.isError = false})
      : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';

  Map<String, dynamic> toMap() => {
        'id': id, 'role': role, 'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isError': isError ? 1 : 0,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as int?,
        role: map['role'] as String,
        content: map['content'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        isError: (map['isError'] as int? ?? 0) == 1,
      );

  Map<String, String> toApiMap() => {'role': role, 'content': content};
}
