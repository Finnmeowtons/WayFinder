import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:way_finders/repository/local_storage_repository.dart';
import 'package:way_finders/services/mqtt_manager.dart';
import '../../models/device_geocode_model.dart';
import '../../models/device_info_model.dart';
import '../../models/device_location_model.dart';
import '../../models/device_with_status.dart';
import '../../repository/device_repository.dart';

part 'device_event.dart';
part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final MqttManager mqttClient;
  final DeviceRepository deviceRepository;

  DeviceBloc(this.deviceRepository, this.mqttClient) : super(DeviceInitial()) {
    // Connect device
    on<ConnectDeviceEvent>((event, emit) async {
      emit(DeviceLoading());
      try {
        await deviceRepository.connectDevice(
          event.name,
          event.phoneNumber,
          event.deviceNumber,
          event.password,
          event.imageFile
        );
        print( "Loading");
        final result = await deviceRepository.getUserDevices(event.phoneNumber);
        // Wrap result into DeviceWithStatus
        final devicesWithStatus = result.map<DeviceWithStatus>((d) => DeviceWithStatus(deviceInfo: d)).toList();
        emit(DeviceLoaded(devicesWithStatus));
      } catch (e) {
        emit(DeviceError(e.toString()));
      }
    });

    // Get user devices
    on<GetUserDevicesEvent>((event, emit) async {
      emit(DeviceLoading());
      try {
        final devices = await deviceRepository.getUserDevices(event.phoneNumber);

        // Wrap into DeviceWithStatus
        final devicesWithStatus =
        devices.map<DeviceWithStatus>((d) => DeviceWithStatus(deviceInfo: d)).toList();
        print( "Device with Status $devicesWithStatus");
        emit(DeviceLoaded(devicesWithStatus));
      } catch (e) {
        print(e);
        emit(DeviceError(e.toString()));
      }
    });

    // Edit device
    on<EditDeviceEvent>((event, emit) async {
      emit(DeviceLoading());
      try {
        // Call repository to edit device
        await deviceRepository.editDevice(event.id, event.name, event.imageFile);

        // Refresh user's devices after edit
        final phoneNumber = await LocalStorageRepository().getPhoneNumber();
        final devices = await deviceRepository.getUserDevices(phoneNumber!);

        final devicesWithStatus = devices
            .map<DeviceWithStatus>((d) => DeviceWithStatus(deviceInfo: d))
            .toList();

        emit(DeviceLoaded(devicesWithStatus));
      } catch (e) {
        print(e.toString());
        emit(DeviceError(e.toString()));
      }
    });

    // Disconnect device
    on<DisconnectDeviceEvent>((event, emit) async {
      emit(DeviceLoading());
      try {
        await deviceRepository.disconnectDevice(
          event.id
        );

        final phoneNumber = await LocalStorageRepository().getPhoneNumber();
        final devices = await deviceRepository.getUserDevices(phoneNumber!);
        final devicesWithStatus =
        devices.map<DeviceWithStatus>((d) => DeviceWithStatus(deviceInfo: d)).toList();
        emit(DeviceLoaded(devicesWithStatus));
      } catch (e) {
        emit(DeviceError(e.toString()));
      }
    });

    // Handle MQTT updates
    on<MqttDeviceUpdateEvent>((event, emit) {
      print("Updating device ${event.deviceId}");
      final currentState = state as DeviceLoaded;
      final devices = currentState.data;

      print( "Current devices $devices");
        final updatedDevices = devices.map((d) {
          print( "Updating device2 $d, Event ${event.location}, ${event.geocode}, ${event.deviceId}");
          if (d.deviceInfo.deviceUid == "+${event.deviceId}") {
            print( "Event Location: ${event.location}, Device Location: ${d.location}");
            return d.copyWith(
              location: event.location ?? d.location,
              geocode: event.geocode ?? d.geocode,
            );
          }
          return d;
        }).toList();
        print( "Updated devices $updatedDevices");
        emit(DeviceLoaded(updatedDevices)); // emits new state every time

    });
  }
}