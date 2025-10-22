import 'package:equatable/equatable.dart';

class DeviceGeocodeModel extends Equatable{
  final String location;

  const DeviceGeocodeModel({required this.location});

  factory DeviceGeocodeModel.fromJson(Map<String, dynamic> json) {
    return DeviceGeocodeModel(
        location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
    };
  }

  @override
  List<Object?> get props => [location];
}