import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  Message({
    required this.senderId,
    required this.receiverId,
    required this.messageContent,
    required this.dateTime,
  });

  late String id;
  late String messageContent;

  @TimestampConverter()
  late DateTime dateTime;

  late String senderId;
  late String receiverId;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

class TimestampConverter implements JsonConverter<DateTime, Map<String, dynamic>> {
  const TimestampConverter();

  @override
  DateTime fromJson(Map<String, dynamic> json) {
    return DateTime.fromMillisecondsSinceEpoch(json['_seconds'] * 1000 + json['_nanoseconds'] ~/ 1000000);
  }

  @override
  Map<String, dynamic> toJson(DateTime date) => {
        '_seconds': date.millisecondsSinceEpoch ~/ 1000,
        '_nanoseconds': (date.millisecondsSinceEpoch % 1000) * 1000000,
      };
}
