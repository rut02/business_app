// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Create _$CreateFromJson(Map<String, dynamic> json) => Create()
  ..message = json['message'] as String
  ..userId = json['userId'] as String;

Map<String, dynamic> _$CreateToJson(Create instance) => <String, dynamic>{
      'message': instance.message,
      'userId': instance.userId,
    };
