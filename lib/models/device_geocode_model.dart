import 'package:equatable/equatable.dart';

class DeviceGeocodeModel extends Equatable{
  final int id;
  final double distance;
  final String location;

  const DeviceGeocodeModel({ required this.id ,required this.distance, required this.location});

  factory DeviceGeocodeModel.fromJson(Map<String, dynamic> json) {
    return DeviceGeocodeModel(
        id: json['id'],
        distance: json['distance'],
        location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distance': distance,
      'location': location,
    };
  }

  @override
  List<Object?> get props => [id, distance, location];
}