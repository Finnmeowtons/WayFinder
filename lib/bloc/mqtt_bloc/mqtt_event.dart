part of 'mqtt_bloc.dart';

abstract class MqttEvent extends Equatable {
  const MqttEvent();
  @override
  List<Object?> get props => [];
}

class MqttConnectEvent extends MqttEvent {}

class MqttSubscribeDeviceEvent extends MqttEvent {
  final String deviceUid;
  const MqttSubscribeDeviceEvent(this.deviceUid);
}



class MqttMessageReceivedEvent extends MqttEvent {
  final String topic;
  final Map<String, dynamic> data;

  const MqttMessageReceivedEvent(this.topic, this.data);

  @override
  List<Object?> get props => [topic, data];
}
