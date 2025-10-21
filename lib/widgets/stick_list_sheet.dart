import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:way_finders/models/device_with_status.dart';

import '../bloc/device_bloc/device_bloc.dart';
import '../bloc/mqtt_bloc/mqtt_bloc.dart';
import '../models/device_info_model.dart';
import 'add_stick_dialog.dart';

class StickListSheet extends StatefulWidget {
  final String phoneNumber;
  final MapController mapController;
  final ScrollController scrollController;

  const StickListSheet({
    super.key,
    required this.phoneNumber,
    required this.mapController,
    required this.scrollController,
  });

  @override
  State<StickListSheet> createState() => _StickListSheetState();
}

class _StickListSheetState extends State<StickListSheet> {
  late final DraggableScrollableController sheetController;

  @override
  void initState() {
    super.initState();
    sheetController = DraggableScrollableController();

    // Fetch user devices on initialization
    print("Phone number: ${widget.phoneNumber}");
    context.read<DeviceBloc>().add(GetUserDevicesEvent(widget.phoneNumber));
  }

  void _editStick(DeviceInfoModel stick) {
    final nameController = TextEditingController(text: stick.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Stick"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // handle profile pic change
              },
              icon: const Icon(Icons.image),
              label: const Text("Change Profile Picture"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: send update event or API call
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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
            mqttBloc.add(MqttSubscribeDeviceEvent(d.deviceInfo.deviceUid));
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
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: sticks.length + 1,
                    itemBuilder: (context, index) {
                      if (index < sticks.length) {
                        final stick = sticks[index];
                        return _swipeableTile(stick);
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showUserFormDialog(context);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add Stick"),
                          ),
                        );
                      }
                    },
                  ),
                ),
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

  Widget _swipeableTile(DeviceWithStatus stick) {
    return SwipeableTile.swipeToTrigger(
      key: ValueKey(stick.deviceInfo.id),
      color: Colors.white,
      swipeThreshold: 0.2,
      direction: SwipeDirection.endToStart,
      behavior: HitTestBehavior.translucent,
      onSwiped: (direction) {
        if (direction == SwipeDirection.endToStart) {
          _editStick(stick.deviceInfo);
        }
      },
      backgroundBuilder: (context, direction, progress) {
        if (direction == SwipeDirection.endToStart) {
          return Container(
            color: Colors.blueAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.settings, color: Colors.white),
          );
        }
        return Container();
      },
      child: InkWell(
        onTap: () async {
          await widget.mapController.moveTo(
            GeoPoint(latitude: stick.location!.latitude, longitude: stick.location!.longitude),
            animate: true,
          );
          await sheetController.animateTo(
            0.15,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundImage:
            AssetImage("assets/kenth.jpg"),
            // NetworkImage(stick.deviceInfo.profilePic ?? "https://preview.redd.it/l0ergarfzst61.png?auto=webp&s=5de076eac09bb645d58b11cd8ce82f99ec487329", ),
            child: null,
          ),
          title:
          Text("Kenth Marasigan"),
          // Text(stick.deviceInfo.name ?? "stick"),
          subtitle:
          Text("Distance: 1332m")
          // Text("${stick.deviceInfo.id}"),
        ),
      ),
    );
  }
}
