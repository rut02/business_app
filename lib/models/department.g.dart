// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Department _$DepartmentFromJson(Map<String, dynamic> json) => Department()
  ..companyID = json['companyID'] as String
  ..phone = json['phone'] as String
  ..name = json['name'] as String
  ..id = json['id'] as String;

Map<String, dynamic> _$DepartmentToJson(Department instance) =>
    <String, dynamic>{
      'companyID': instance.companyID,
      'phone': instance.phone,
      'name': instance.name,
      'id': instance.id,
    };
