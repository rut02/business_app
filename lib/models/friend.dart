import 'package:json_annotation/json_annotation.dart';

part 'friend.g.dart';

@JsonSerializable()
class Friend {
  Friend();

  late String friendId;
  late String time;
  late String userId;
  late String status;
  late String id;
  
  factory Friend.fromJson(Map<String,dynamic> json) => _$FriendFromJson(json);
  Map<String, dynamic> toJson() => _$FriendToJson(this);
}
