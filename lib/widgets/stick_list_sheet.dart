import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import '../models/stick_model.dart';
import 'dart:math';

class StickListSheet extends StatefulWidget {
  final List<StickModel> sticks;
  final MapController mapController;
  final ScrollController scrollController;

  const StickListSheet({
    super.key,
    required this.sticks,
    required this.mapController, required this.scrollController,
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
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // km
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  void _editStick(StickModel stick) {
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                stick.name = nameController.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<List<StickModel>> _getSortedSticks() async {
    GeoPoint? userLocation = await widget.mapController.myLocation();
    if (userLocation == null) return widget.sticks;

    List<StickModel> sorted = List.from(widget.sticks);
    sorted.sort((a, b) {
      double distA = calculateDistance(a.latitude, a.longitude, userLocation.latitude, userLocation.longitude);
      double distB = calculateDistance(b.latitude, b.longitude, userLocation.latitude, userLocation.longitude);
      return distA.compareTo(distB);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StickModel>>(
      future: _getSortedSticks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sticksSorted = snapshot.data!;
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
                  itemCount: sticksSorted.length + 1,
                  itemBuilder: (context, index) {
                    if (index < sticksSorted.length) {
                      final stick = sticksSorted[index];
                      return _swipeableTile(stick);
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // handle add stick
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
      },
    );
  }

  Widget _swipeableTile(StickModel stick) {
    return SwipeableTile.swipeToTrigger(
      key: ValueKey(stick.id),
      color: Colors.white,
      swipeThreshold: 0.2,
      direction: SwipeDirection.endToStart,
      behavior: HitTestBehavior.translucent,
      onSwiped: (direction) {
        if (direction == SwipeDirection.endToStart) {
          _editStick(stick);
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
            GeoPoint(latitude: stick.latitude, longitude: stick.longitude),
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
            backgroundImage: stick.profilePic != null
                ? NetworkImage(stick.profilePic!)
                : null,
            child: stick.profilePic == null ? const Icon(Icons.person, size: 24) : null,
          ),
          title: Text(stick.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stick.location),
              Text(
                snapshotDistanceText(stick),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String snapshotDistanceText(StickModel stick) {
    final loc = widget.mapController.myLocation();
    // TODO: Use Bloc to get user location
    return "${calculateDistance(stick.latitude, stick.longitude, 16.021327741243624, 120.32933674117412).toStringAsFixed(2)} km away";
  }
}
