import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:way_finders/ip_address.dart';
import 'package:way_finders/widgets/sos_dialog.dart';

import '../bloc/mqtt_bloc/mqtt_bloc.dart';
import '../models/device_with_status.dart';

class StickTile extends StatefulWidget {
  final DeviceWithStatus stick;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const StickTile({super.key, required this.stick, this.onTap, this.onEdit, this.onDelete});

  @override
  State<StickTile> createState() => _StickTileState();
}

class _StickTileState extends State<StickTile> {
  @override
  Widget build(BuildContext context) {
    final device = widget.stick.deviceInfo;
    final formattedDeviceUid = device.deviceUid.replaceAll('+', '');


    return BlocListener<MqttBloc, MqttState>(
      listener: (context, state) {
        if (state is MqttSOSReceived) {
          print("State Device UID: ${state.deviceUid}, Device UID: $formattedDeviceUid");
          if(state.deviceUid == formattedDeviceUid) {
            print("SOS");
            showSOSDialog(context, device.name ?? "Stick", widget.stick.geocode?.location ?? "");
          }
        }
      },
      child: GestureDetector(
        onTap: () => widget.onTap!(),
        child: SwipeableTile.swipeToTrigger(
          key: ValueKey(device.id),
          color: Colors.white,
          swipeThreshold: 0.2,
          direction: SwipeDirection.endToStart,
          behavior: HitTestBehavior.translucent,
          onSwiped: (direction) {
            if (direction == SwipeDirection.endToStart && widget.onEdit != null) {
              widget.onEdit!();
            }
          },
          backgroundBuilder: (context, direction, progress) {
            return Container(
              color: Colors.blueAccent,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.edit_rounded, color: Colors.white),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: device.profilePic != null ? NetworkImage("${IpAddress.ipAddress}${device.profilePic}") : null,
              backgroundColor: Colors.grey[200],
              child: device.profilePic == null ? const Icon(Icons.person) : null,
            ),
            title: Text(device.name ?? "Stick"),
            subtitle: Text(widget.stick.geocode?.location ?? "", style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis,),
            // trailing: IconButton(
            //   icon: const Icon(Icons.edit),
            //   onPressed: widget.onEdit,
            // ),
          ),
        ),
      ),
    );
  }
}
