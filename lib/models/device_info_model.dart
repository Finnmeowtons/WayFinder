import 'package:equatable/equatable.dart';

class DeviceInfoModel extends Equatable{
  final int id;
  final String deviceUid;
  String? name;
  String? profilePic;

  DeviceInfoModel({required this.id, required this.deviceUid, this.name, this.profilePic});

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
        id: json['id'],
        deviceUid: json['device_uid'],
        name: json['name'] ?? "Stick",
        profilePic: json['profile_picture_url']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_uid': deviceUid,
      'name': name!.isEmpty ? "Stick" : name ?? "Stick",
      'profile_picture_url': profilePic
    };
  }

  @override
  List<Object?> get props => [id, deviceUid, name, profilePic];
}



