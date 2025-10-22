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

  const StickListSheet({
    super.key,
    required this.phoneNumber,
    required this.mapController,
    required this.scrollController,
    required this.sheetController,
  });

  @override
  State<StickListSheet> createState() => _StickListSheetState();
}

class _StickListSheetState extends State<StickListSheet> {
  final Set<String> subscribedDevices = MqttManager().subscribedTopics;


  @override
  void initState() {
    super.initState();

    // Fetch user devices on initialization
    print("Phone number: ${widget.phoneNumber}");
    context.read<DeviceBloc>().add(GetUserDevicesEvent(phoneNumber: widget.phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceBloc, DeviceState>(
      builder: (context, state) {
        if (state is DeviceLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DeviceLoaded) {
          final sticks = state.data;
          final mqttBloc = context.read<MqttBloc>();

          for (var d in sticks) {
            if (!subscribedDevices.contains(d.deviceInfo.deviceUid)) {
              mqttBloc.add(MqttSubscribeDeviceEvent(d.deviceInfo.deviceUid));
              subscribedDevices.add(d.deviceInfo.deviceUid);
            }
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: widget.scrollController,
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 8),
                      ),
                      SliverList.builder(
                        itemCount: sticks.length,
                        itemBuilder: (context, index) {
                          final stick = sticks[index];
                          return StickTile(
                            stick: stick,
                            onTap: () {
                              final lat = stick.location?.latitude;
                              final lng = stick.location?.longitude;

                              if (lat != null && lng != null) {
                                widget.mapController.moveTo(GeoPoint(latitude: lat, longitude: lng), animate: true);

                                widget.sheetController.animateTo(
                                  0.15,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("No location data available for this device.")),
                                );
                              }
                            },
                            onEdit: () async {
                              final formData = await showEditStickDialog(
                                context,
                                userDeviceId: stick.deviceInfo.id,
                                deviceUid: stick.deviceInfo.deviceUid,
                                currentName: stick.deviceInfo.name ?? "Stick",
                                currentImageUrl: stick.deviceInfo.profilePic,
                              );

                              if (formData != null) {
                                if (formData['action'] == 'delete') {
                                  context.read<DeviceBloc>().add(
                                    DisconnectDeviceEvent(id: stick.deviceInfo.id),
                                  );
                                } else {
                                  final image = formData['image'];
                                  context.read<DeviceBloc>().add(
                                    EditDeviceEvent(
                                      id: stick.deviceInfo.id,
                                      name: formData['name'],
                                      imageFile: image != null ? File(image) : null,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
                          child: addStickButton(context)
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
                }

        if (state is DeviceError) {
          return Center(child: Text("Error: ${state.message}"));
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget addStickButton(BuildContext context) {
    return
      Card(
        elevation: 0,
        color: Colors.white,
        child: InkWell(
          onTap: () async {
            final formData = await showUserFormDialog(context);
            if (formData != null) {
              final phone = await LocalStorageRepository().getPhoneNumber();
              final formattedPhone = FormatPhoneNumber().formatPhoneNumber(phone!);
              context.read<DeviceBloc>().add(
                ConnectDeviceEvent(
                  name: formData['name'],
                  phoneNumber: formattedPhone,
                  deviceNumber: formData['deviceUid'],
                  password: formData['password'],
                  imageFile: formData['image'] != null ? File(formData['image']) : null,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 120,
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_circle_outline, size: 40, color: Colors.blueAccent),
                SizedBox(height: 8),
                Text("Add Device",
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
  }

}
