import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  Group();

  late String id;
  late String name;
  late String ownerId;
  
  factory Group.fromJson(Map<String,dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}
