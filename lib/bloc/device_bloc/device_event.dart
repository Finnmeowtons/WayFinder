part of 'device_bloc.dart';

sealed class DeviceEvent extends Equatable {
  const DeviceEvent();
  @override
  List<Object> get props => [];
}

final class ConnectDeviceEvent extends DeviceEvent {
  final String name;
  final String phoneNumber;
  final String deviceNumber;
  final String password;
  final File? imageFile;

  const ConnectDeviceEvent({ required this.name, required this.phoneNumber, required this.deviceNumber, required this.password, this.imageFile});
}

final class GetUserDevicesEvent extends DeviceEvent {
  final String phoneNumber;
  const GetUserDevicesEvent({ required this.phoneNumber});
}

final class DisconnectDeviceEvent extends DeviceEvent {
  final int id;
  const DisconnectDeviceEvent({required this.id});
}

class EditDeviceEvent extends DeviceEvent {
  final int id;
  final String name;
  final File? imageFile;

  const EditDeviceEvent({required this.id, required this.name, this.imageFile});
}

// New event for MQTT updates
final class MqttDeviceUpdateEvent extends DeviceEvent {
  final String deviceId;
  final DeviceLocationModel? location;
  final DeviceGeocodeModel? geocode;

  const MqttDeviceUpdateEvent({required this.deviceId, this.location, this.geocode});
}
