import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:way_finders/widgets/sos_dialog.dart';
import 'dart:async';

import '../../models/device_geocode_model.dart';
import '../../models/device_location_model.dart';
import '../../services/mqtt_manager.dart';
import '../device_bloc/device_bloc.dart';

part 'mqtt_event.dart';
part 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final MqttManager mqttManager = MqttManager();
  final DeviceBloc deviceBloc;

  StreamSubscription? _subscription;
  final Set<String> _subscribedDevices = {}; // ✅ Track subscribed devices

  MqttBloc(this.deviceBloc) : super(MqttInitial()) {
    on<MqttConnectEvent>(_onConnect);
    on<MqttMessageReceivedEvent>(_onMessageReceived);
    on<MqttSubscribeDeviceEvent>(_onSubscribeDevice);

    // Automatically connect when the bloc is created
    add(MqttConnectEvent());
  }

  Future<void> _onConnect(
      MqttConnectEvent event, Emitter<MqttState> emit) async {
    await mqttManager.initialize();

    // Listen to all incoming MQTT messages
    _subscription = mqttManager.messageStream.listen((message) {
      add(MqttMessageReceivedEvent(message['topic'], message['data']));
    });

    emit(MqttConnected());
  }

  Future<void> _onSubscribeDevice(
      MqttSubscribeDeviceEvent event, Emitter<MqttState> emit) async {
    // Remove '+' if present in UID
    final uid = event.deviceUid.replaceAll('+', '');


    // ✅ Prevent duplicate subscriptions
    if (_subscribedDevices.contains(uid)) {
      return;
    }

    mqttManager.subscribe('wayfinder/device/$uid/location');
    mqttManager.subscribe('wayfinder/device/$uid/geocode');
    mqttManager.subscribe('wayfinder/device/$uid/sos');

    print('Subscribed to device $uid');
  }

  void _onMessageReceived(MqttMessageReceivedEvent event, Emitter<MqttState> emit) {
    final topicParts = event.topic.split('/'); // ["wayfinder", "device", "UID", "location"]

    if (topicParts.length == 4 && topicParts[0] == 'wayfinder' && topicParts[1] == 'device') {
      final deviceUid = topicParts[2]; // dynamic UID
      final type = topicParts[3];      // "location" or "geocode"

      try {
        if (type == 'location') {
          print("Type Location");
          final data = DeviceLocationModel.fromJson(event.data);
          print( "Data = $data");
          emit(MqttLocationUpdated(data));

          // Update DeviceBloc automatically
          deviceBloc.add(MqttDeviceUpdateEvent(
            deviceId: deviceUid,
            location: data,
          ));
          print("Updated");
        } else if (type == 'geocode') {
          final data = DeviceGeocodeModel.fromJson(event.data);

          emit(MqttGeocodeUpdated(data));

          // Update DeviceBloc automatically
          deviceBloc.add(MqttDeviceUpdateEvent(
            deviceId: deviceUid,
            geocode: data,
          ));
        } else if (type == "sos"){
          print("Type SOS");
          emit(MqttSOSReceived(deviceUid));
        }
      } catch (e) {
        print('Invalid data format for $type: $e');
      }
    } else {
      print('Unhandled topic: ${event.topic}');
    }
  }



  @override
  Future<void> close() {
    _subscription?.cancel();
    mqttManager.disconnect();
    return super.close();
  }
}
