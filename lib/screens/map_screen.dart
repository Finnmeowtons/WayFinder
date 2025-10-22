import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:way_finders/models/device_info_model.dart';
import 'package:way_finders/repository/local_storage_repository.dart';
import 'package:way_finders/screens/login_signup_screen.dart';
import 'package:way_finders/widgets/map_widget.dart';
import 'package:way_finders/widgets/sos_dialog.dart';
import 'package:way_finders/widgets/stick_list_sheet.dart';

import '../bloc/mqtt_bloc/mqtt_bloc.dart';
import '../widgets/tutorial_helper.dart';

class MapScreen extends StatefulWidget {
  final String phoneNumber;

  const MapScreen({super.key, required this.phoneNumber});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey keyBottomSheet = GlobalKey();
  final GlobalKey keyMap = GlobalKey();
  final GlobalKey keyLocation = GlobalKey();
  late final DraggableScrollableController sheetController;
  bool isLoading = false; // For progress overlay
  bool _tutorialShown = false;

  @override
  void initState() {
    sheetController = DraggableScrollableController();
    super.initState();
  }


  final MapController mapController = MapController(
    initPosition: GeoPoint(latitude: 12.8797, longitude: 121.7740), // PH center
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: keyMap,
      body: Stack(
        children: [
          MapWidget(
            mapController: mapController,
            onMapReady: () {
              print("Map is Ready!!");

              if (!_tutorialShown) {
                print("Tutorial now showing");
                MapTutorial(
                  context: context,
                  mapKey: keyMap,
                  locationKey: keyLocation,
                  bottomSheetKey: keyBottomSheet,
                ).show();
                _tutorialShown = true;
              }
            },
          ),

          // Map buttons
          Positioned(
            bottom: 150,
            left: 16,
            child: Column(
              children: [
                _mapButton(icon: Icons.add, onTap: () => mapController.zoomIn()),
                const SizedBox(height: 8),
                _mapButton(icon: Icons.remove, onTap: () => mapController.zoomOut()),
                // _mapButton(icon: Icons.remove, onTap: () => showSOSDialog(context, "Kenth Marasigan")),
                const SizedBox(height: 8),
                _mapButton(
                    icon: Icons.my_location_rounded,
                    onTap: () async => mapController.moveTo(await mapController.myLocation(), animate: true),
                    key: keyLocation),
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
            maxChildSize: 0.3,
            builder: (context, scrollController) {
              return StickListSheet(
                key: keyBottomSheet,
                mapController: mapController,
                scrollController: scrollController,
                sheetController: sheetController,
                phoneNumber: widget.phoneNumber,
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


  Widget _mapButton({required IconData icon, required VoidCallback onTap, Key? key}) {
    return Container(
      key: key,
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
            builder: (context) =>
                AlertDialog(
                  title: const Text("Log out"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                        LocalStorageRepository().clearData();
                      },
                      child: const Text("Log out"),
                    ),
                  ],
                ),
          );

          if (shouldLogout == true) {
            setState(() => isLoading = true);
            await Future.delayed(const Duration(milliseconds: 300));
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
