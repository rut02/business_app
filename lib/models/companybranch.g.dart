// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companybranch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Companybranch _$CompanybranchFromJson(Map<String, dynamic> json) =>
    Companybranch()
      ..companyID = json['companyID'] as String
      ..name = json['name'] as String
      ..address = json['address'] as String
      ..id = json['id'] as String
      ..company = Company.fromJson(json['company'] as Map<String, dynamic>);

Map<String, dynamic> _$CompanybranchToJson(Companybranch instance) =>
    <String, dynamic>{
      'companyID': instance.companyID,
      'name': instance.name,
      'address': instance.address,
      'id': instance.id,
      'company': instance.company,
    };
