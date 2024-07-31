// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) => Request()
  ..responderId = json['responderId'] as String
  ..requesterId = json['requesterId'] as String
  ..Time = json['Time'] as String
  ..status = json['status'] as String
  ..id = json['id'] as String;

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'responderId': instance.responderId,
      'requesterId': instance.requesterId,
      'Time': instance.Time,
      'status': instance.status,
      'id': instance.id,
    };
