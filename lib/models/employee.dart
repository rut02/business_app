import 'package:json_annotation/json_annotation.dart';
import "companybranch.dart";
import "department.dart";
part 'employee.g.dart';

@JsonSerializable()
class Employee {
  Employee();

  late String firstname;
  late String birthdate;
  late String address;
  late String gender;
  late String lastname;
  late String password;
  late String phone;
  late String startwork;
  late String position;
  late String email;
  late String profile;
  late String business_cards;
  late Companybranch companybranch;
  late Department department;
  late String id;
  late num age;
  
  factory Employee.fromJson(Map<String,dynamic> json) => _$EmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
}
