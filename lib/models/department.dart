import 'package:json_annotation/json_annotation.dart';

part 'department.g.dart';

@JsonSerializable()
class Department {
  Department();

  late String companyID;
  late String phone;
  late String name;
  late String id;
  
  factory Department.fromJson(Map<String,dynamic> json) => _$DepartmentFromJson(json);
  Map<String, dynamic> toJson() => _$DepartmentToJson(this);
}
