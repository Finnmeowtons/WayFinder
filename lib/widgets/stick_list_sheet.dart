import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:way_finders/format_phone_number.dart';
import 'package:way_finders/ip_address.dart';
import 'package:way_finders/models/device_with_status.dart';
import 'package:way_finders/services/mqtt_manager.dart';
import 'package:way_finders/widgets/show_edit_dialog.dart';

import '../bloc/device_bloc/device_bloc.dart';
import '../bloc/mqtt_bloc/mqtt_bloc.dart';
import '../models/device_info_model.dart';
import '../repository/local_storage_repository.dart';
import 'stick_tile.dart';
import 'add_stick_dialog.dart';

class StickListSheet extends StatefulWidget {
  final String phoneNumber;
  final MapController mapController;
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;

  const StickListSheet({super.key, required this.phoneNumber, required this.mapController, required this.scrollController, required this.sheetController});

  @override
  State<StickListSheet> createState() => _StickListSheetState();
}

class _StickListSheetState extends State<StickListSheet> {
  final Set<String> subscribedDevices = MqttManager().subscribedTopics;
  final Map<String, String> _deviceLocations = {};
  @override
  void initState() {
    super.initState();

    // Fetch user devices on initialization
    print("Phone number: ${widget.phoneNumber}");
    context.read<DeviceBloc>().add(GetUserDevicesEvent(phoneNumber: widget.phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeviceBloc, DeviceState>(
      listener: (context, state) {
        if (state is DeviceShowDialog) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(state.message),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
            ),
          );
        }
      },
      child: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          final sticks = (state is DeviceLoaded) ? List<DeviceWithStatus>.from(state.data) : (state is DeviceShowDialog ? state.previousDevices ?? [] : []);

          if (state is DeviceLoading) {
            print("Loading Idol");
            return _bottomSheet(child: Center(child: CircularProgressIndicator()));
          }
          if (state is DeviceLoaded) {
            final mqttBloc = context.read<MqttBloc>();

            // Subscribe to devices
            for (var d in sticks) {
              final deviceUid = d.deviceInfo.deviceUid;

              // Subscribe to new devices
              if (!subscribedDevices.contains(deviceUid)) {
                mqttBloc.add(MqttSubscribeDeviceEvent(deviceUid));
                subscribedDevices.add(deviceUid);
              }

              // Always update the location if new geocode is available
              if (d.geocode?.location != null && d.geocode!.location!.isNotEmpty) {
                _deviceLocations[deviceUid] = d.geocode!.location!;
              }

              print("DEVICE LOCATIONS $_deviceLocations");
            }


            return _bottomSheet(
              child: sticks.isEmpty
                  ? SingleChildScrollView(child: Center(child: addStickButton(context)))
                  : CustomScrollView(
                controller: widget.scrollController,
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverList.builder(
                    itemCount: sticks.length,
                    itemBuilder: (context, index) {
                      final stick = sticks[index];
                      final deviceUid = stick.deviceInfo.deviceUid;

                      return StickTile(
                        stick: stick,
                        subtitle: _deviceLocations[deviceUid],
                        onTap: () {
                          final lat = stick.location?.latitude;
                          final lng = stick.location?.longitude;

                          if (lat != null && lng != null) {
                            widget.mapController.moveTo(
                                GeoPoint(latitude: lat, longitude: lng),
                                animate: true);

                            widget.sheetController.animateTo(0.15,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "No location data available for this device.")));
                          }
                        },
                        onEdit: () async {
                          final formData = await showEditStickDialog(
                            context,
                            userDeviceId: stick.deviceInfo.id,
                            deviceUid: deviceUid,
                            currentName: stick.deviceInfo.name ?? "Stick",
                            currentImageUrl: stick.deviceInfo.profilePic,
                          );

                          if (formData != null) {
                            if (formData['action'] == 'delete') {
                              _deviceLocations.remove(deviceUid);
                              context.read<DeviceBloc>().add(
                                  DisconnectDeviceEvent(id: stick.deviceInfo.id));
                            } else if (formData['action'] == 'edit') {
                              final image = formData['image'];
                              context.read<DeviceBloc>().add(EditDeviceEvent(
                                  id: stick.deviceInfo.id,
                                  name: formData['name'],
                                  imageFile: image != null ? File(image) : null));
                            }
                          }
                        },
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: addStickButton(context)),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is DeviceError) {
            print("Error: ${state.message}");
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget addStickButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: InkWell(
          onTap: () async {
            final formData = await showUserFormDialog(context);
            if (formData != null) {
              final phone = await LocalStorageRepository().getPhoneNumber();
              final formattedPhone = FormatPhoneNumber().formatPhoneNumber(phone!);
              context.read<DeviceBloc>().add(ConnectDeviceEvent(name: formData['name'], phoneNumber: formattedPhone, deviceNumber: formData['deviceUid'], password: formData['password'], imageFile: formData['image'] != null ? File(formData['image']) : null));
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline, size: 40, color: Colors.blueAccent),
              SizedBox(height: 8),
              Text(
                "Add Device",
                style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomSheet({required Widget child})  {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: SafeArea(
        top: false,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
            ),
            Flexible(fit: FlexFit.loose, child: child),
          ],
        ),
      ),
    );
  }
}
