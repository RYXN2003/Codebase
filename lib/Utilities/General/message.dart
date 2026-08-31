
class Message{
  final String text;
  final DateTime date;
  final String time;
  final bool isSentByMe;
  final List<dynamic> seenBy;

  const Message({
    required this.text,
    required this.date,
    required this.time,
    required this.isSentByMe,
    required this.seenBy,
  });
}