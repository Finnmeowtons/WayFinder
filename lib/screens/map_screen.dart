import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:way_finders/models/stick_model.dart';
import 'package:way_finders/screens/login_signup_screen.dart';
import 'package:way_finders/widgets/map_widget.dart';
import 'package:way_finders/widgets/stick_list_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final DraggableScrollableController sheetController;
  bool isLoading = false; // For progress overlay

  @override
  void initState() {
    sheetController = DraggableScrollableController();
    super.initState();
  }

  final MapController mapController = MapController(
    initPosition: GeoPoint(latitude: 12.8797, longitude: 121.7740), // PH center
  );

  List<StickModel> sticks = [
    StickModel(
        id: 1, name: "Stick Alpha", latitude: 14.6091, longitude: 120.9822, location: "Manila"),
    StickModel(
        id: 2, name: "Stick Bravo", latitude: 14.6760, longitude: 121.0437, location: "Quezon City"),
    StickModel(
        id: 3, name: "Stick Charlie", latitude: 14.5547, longitude: 121.0244, location: "Makati")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map fills the screen
          MapWidget(sticks: sticks, mapController: mapController),

          // Map buttons
          Positioned(
            bottom: 150,
            left: 16,
            child: Column(
              children: [
                _mapButton(icon: Icons.add, onTap: () => mapController.zoomIn()),
                const SizedBox(height: 8),
                _mapButton(icon: Icons.remove, onTap: () => mapController.zoomOut()),
                const SizedBox(height: 8),
                _mapButton(
                    icon: Icons.my_location_rounded,
                    onTap: () async => mapController.moveTo(await mapController.myLocation(), animate: true)),
              ],
            ),
          ),

          // Logout button
          Align(
            alignment: Alignment.topRight,
            child: _logOutWidget(),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            controller: sheetController,
            initialChildSize: 0.15,
            minChildSize: 0.15,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return StickListSheet(
                sticks: sticks,
                mapController: mapController,
                scrollController: scrollController, // Pass scrollController
              );
            },
          ),

          // Loading overlay
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }


  Widget _mapButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.blueAccent),
        onPressed: onTap,
      ),
    );
  }

  Widget _logOutWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.only(top: 40),
      child: IconButton(
        icon: const Icon(
          Icons.logout_rounded,
          size: 30,
          weight: 800,
          color: Colors.redAccent,
        ),
        padding: const EdgeInsets.all(8),
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Log out"),
              content: const Text("Are you sure you want to log out?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Log out"),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            setState(() => isLoading = true); // Show progress while navigating
            await Future.delayed(const Duration(milliseconds: 300)); // Optional small delay
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const LoginSignupScreen()));
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged out")),
            );
          }
        },
      ),
    );
  }
}
