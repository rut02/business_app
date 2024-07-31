// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company()
  ..website = json['website'] as String
  ..password = json['password'] as String
  ..name = json['name'] as String
  ..businessType = json['businessType'] as String
  ..yearFounded = json['yearFounded'] as String
  ..email = json['email'] as String
  ..logo = json['logo'] as String
  ..id = json['id'] as String;

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'website': instance.website,
      'password': instance.password,
      'name': instance.name,
      'businessType': instance.businessType,
      'yearFounded': instance.yearFounded,
      'email': instance.email,
      'logo': instance.logo,
      'id': instance.id,
    };
