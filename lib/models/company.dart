import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  Company();

  late String website;
  late String password;
  late String name;
  late String businessType;
  late String yearFounded;
  late String email;
  late String logo;
  late String id;
  
  factory Company.fromJson(Map<String,dynamic> json) => _$CompanyFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}
