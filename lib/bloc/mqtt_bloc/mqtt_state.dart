part of 'mqtt_bloc.dart';

abstract class MqttState extends Equatable {
  const MqttState();
  @override
  List<Object?> get props => [];
}

class MqttInitial extends MqttState {}

class MqttConnected extends MqttState {}

class MqttSOSReceived extends MqttState {
  final String deviceUid;
  final DateTime timestamp;

  MqttSOSReceived(this.deviceUid) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [deviceUid];
}

class MqttLocationUpdated extends MqttState {
  final DeviceLocationModel location;
  const MqttLocationUpdated(this.location);
  @override
  List<Object?> get props => [location];
}

class MqttGeocodeUpdated extends MqttState {
  final DeviceGeocodeModel geocode;
  const MqttGeocodeUpdated(this.geocode);
  @override
  List<Object?> get props => [geocode];
}
