import 'package:json_annotation/json_annotation.dart';
import "company.dart";
part 'companybranch.g.dart';

@JsonSerializable()
class Companybranch {
  Companybranch();

  late String companyID;
  late String name;
  late String address;
  late String id;
  late Company company;
  
  factory Companybranch.fromJson(Map<String,dynamic> json) => _$CompanybranchFromJson(json);
  Map<String, dynamic> toJson() => _$CompanybranchToJson(this);
}
