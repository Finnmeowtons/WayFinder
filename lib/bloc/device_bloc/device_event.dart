part of 'device_bloc.dart';

sealed class DeviceEvent extends Equatable {
  const DeviceEvent();
  @override
  List<Object> get props => [];
}

final class ConnectDeviceEvent extends DeviceEvent {
  final String phoneNumber;
  final String deviceNumber;
  final String password;
  const ConnectDeviceEvent(this.phoneNumber, this.deviceNumber, this.password);
}

final class GetUserDevicesEvent extends DeviceEvent {
  final String phoneNumber;
  const GetUserDevicesEvent(this.phoneNumber);
}

final class DisconnectDeviceEvent extends DeviceEvent {
  final String phoneNumber;
  final String deviceNumber;
  const DisconnectDeviceEvent(this.phoneNumber, this.deviceNumber);
}

// New event for MQTT updates
final class MqttDeviceUpdateEvent extends DeviceEvent {
  final String deviceId;
  final DeviceLocationModel? location;
  final DeviceGeocodeModel? geocode;

  const MqttDeviceUpdateEvent({required this.deviceId, this.location, this.geocode});
}
