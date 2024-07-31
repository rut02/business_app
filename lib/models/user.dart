import 'package:json_annotation/json_annotation.dart';
import "companybranch.dart";
import "department.dart";
part 'user.g.dart';

@JsonSerializable()
class User {
  User();

  late String firstname;
  late String password;
  late String birthdate;
  late String address;
  late String business_card;
  late String gender;
  late String phone;
  late String? startwork;
  late Companybranch? companybranch;
  late String position;
  late Department? department;
  late String email;
  late String lastname;
  late String profile;
  late String id;
  late num age;
  
  factory User.fromJson(Map<String,dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
