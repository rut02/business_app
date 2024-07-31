import 'package:json_annotation/json_annotation.dart';

part 'profileImage.g.dart';

@JsonSerializable()
class ProfileImage {
  ProfileImage();

  late String message;
  late String imageUrl;
  
  factory ProfileImage.fromJson(Map<String,dynamic> json) => _$ProfileImageFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileImageToJson(this);
}
