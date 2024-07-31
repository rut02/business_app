// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee()
  ..firstname = json['firstname'] as String
  ..birthdate = json['birthdate'] as String
  ..address = json['address'] as String
  ..gender = json['gender'] as String
  ..lastname = json['lastname'] as String
  ..password = json['password'] as String
  ..phone = json['phone'] as String
  ..startwork = json['startwork'] as String
  ..position = json['position'] as String
  ..email = json['email'] as String
  ..profile = json['profile'] as String
  ..business_cards = json['business_cards'] as String
  ..companybranch =
      Companybranch.fromJson(json['companybranch'] as Map<String, dynamic>)
  ..department = Department.fromJson(json['department'] as Map<String, dynamic>)
  ..id = json['id'] as String
  ..age = json['age'] as num;

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'firstname': instance.firstname,
      'birthdate': instance.birthdate,
      'address': instance.address,
      'gender': instance.gender,
      'lastname': instance.lastname,
      'password': instance.password,
      'phone': instance.phone,
      'startwork': instance.startwork,
      'position': instance.position,
      'email': instance.email,
      'profile': instance.profile,
      'business_cards': instance.business_cards,
      'companybranch': instance.companybranch,
      'department': instance.department,
      'id': instance.id,
      'age': instance.age,
    };
