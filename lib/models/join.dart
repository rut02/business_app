import 'package:json_annotation/json_annotation.dart';

part 'join.g.dart';

@JsonSerializable()
class Join {
  Join();

  late String id;
  late String groupId;
  late String userId;
  
  factory Join.fromJson(Map<String,dynamic> json) => _$JoinFromJson(json);
  Map<String, dynamic> toJson() => _$JoinToJson(this);
}
