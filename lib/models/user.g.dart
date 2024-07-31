// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User()
  ..firstname = json['firstname'] as String
  ..password = json['password'] as String
  ..birthdate = json['birthdate'] as String
  ..address = json['address'] as String
  ..business_card = json['business_card'] as String
  ..gender = json['gender'] as String
  ..phone = json['phone'] as String
  ..startwork = json['startwork'] as String?
  ..companybranch = json['companybranch'] == null
      ? null
      : Companybranch.fromJson(json['companybranch'] as Map<String, dynamic>)
  ..position = json['position'] as String
  ..department = json['department'] == null
      ? null
      : Department.fromJson(json['department'] as Map<String, dynamic>)
  ..email = json['email'] as String
  ..lastname = json['lastname'] as String
  ..profile = json['profile'] as String
  ..id = json['id'] as String
  ..age = json['age'] as num;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'firstname': instance.firstname,
      'password': instance.password,
      'birthdate': instance.birthdate,
      'address': instance.address,
      'business_card': instance.business_card,
      'gender': instance.gender,
      'phone': instance.phone,
      'startwork': instance.startwork,
      'companybranch': instance.companybranch,
      'position': instance.position,
      'department': instance.department,
      'email': instance.email,
      'lastname': instance.lastname,
      'profile': instance.profile,
      'id': instance.id,
      'age': instance.age,
    };
