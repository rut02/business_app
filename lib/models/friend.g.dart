// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Friend _$FriendFromJson(Map<String, dynamic> json) => Friend()
  ..friendId = json['friendId'] as String
  ..time = json['time'] as String
  ..userId = json['userId'] as String
  ..status = json['status'] as String
  ..id = json['id'] as String;

Map<String, dynamic> _$FriendToJson(Friend instance) => <String, dynamic>{
      'friendId': instance.friendId,
      'time': instance.time,
      'userId': instance.userId,
      'status': instance.status,
      'id': instance.id,
    };
