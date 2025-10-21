import 'package:equatable/equatable.dart';

class DeviceLocationModel extends Equatable{
  final double latitude;
  final double longitude;

  const DeviceLocationModel({required this.latitude, required this.longitude});

  factory DeviceLocationModel.fromJson(Map<String, dynamic> json) {
    return DeviceLocationModel(
        latitude: json['latitude'],
        longitude: json['longitude']);
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude
    };
  }

  @override
  List<Object?> get props => [latitude, longitude];
}