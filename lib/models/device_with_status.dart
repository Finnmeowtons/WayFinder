import 'package:equatable/equatable.dart';

import 'device_geocode_model.dart';
import 'device_info_model.dart';
import 'device_location_model.dart';

class DeviceWithStatus extends Equatable {
  final DeviceInfoModel deviceInfo;
  final DeviceLocationModel? location;
  final DeviceGeocodeModel? geocode;

  const DeviceWithStatus({
    required this.deviceInfo,
    this.location,
    this.geocode,
  });

  DeviceWithStatus copyWith({
    DeviceLocationModel? location,
    DeviceGeocodeModel? geocode,
  }) {
    return DeviceWithStatus(
      deviceInfo: deviceInfo,
      location: location ?? this.location,
      geocode: geocode ?? this.geocode,
    );
  }

  @override
  List<Object?> get props => [deviceInfo, location, geocode];
}
