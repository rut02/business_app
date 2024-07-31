import 'package:json_annotation/json_annotation.dart';

part 'request.g.dart';

@JsonSerializable()
class Request {
  Request();

  late String responderId;
  late String requesterId;
  late String Time;
  late String status;
  late String id;
  
  factory Request.fromJson(Map<String,dynamic> json) => _$RequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
