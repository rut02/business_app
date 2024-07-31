import 'package:json_annotation/json_annotation.dart';

part 'create.g.dart';

@JsonSerializable()
class Create {
  Create();

  late String message;
  late String userId;
  
  factory Create.fromJson(Map<String,dynamic> json) => _$CreateFromJson(json);
  Map<String, dynamic> toJson() => _$CreateToJson(this);
}
