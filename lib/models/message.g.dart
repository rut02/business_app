// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      messageContent: json['messageContent'] as String,
      dateTime: const TimestampConverter()
          .fromJson(json['dateTime'] as Map<String, dynamic>),
    )..id = json['id'] as String;

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'messageContent': instance.messageContent,
      'dateTime': const TimestampConverter().toJson(instance.dateTime),
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
    };
