import 'package:json_annotation/json_annotation.dart';

part 'history.g.dart';

@JsonSerializable()
class History {
  History();

  late String action;
  late String userId;
  late String timestamp;
  late String friendId;
  
  factory History.fromJson(Map<String,dynamic> json) => _$HistoryFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryToJson(this);
}
