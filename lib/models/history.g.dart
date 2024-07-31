// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

History _$HistoryFromJson(Map<String, dynamic> json) => History()
  ..action = json['action'] as String
  ..userId = json['userId'] as String
  ..timestamp = json['timestamp'] as String
  ..friendId = json['friendId'] as String;

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
      'action': instance.action,
      'userId': instance.userId,
      'timestamp': instance.timestamp,
      'friendId': instance.friendId,
    };
