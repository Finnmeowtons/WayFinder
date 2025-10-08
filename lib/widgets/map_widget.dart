import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../models/stick_model.dart';

class MapWidget extends StatelessWidget{
  final MapController mapController;
  final List<StickModel> sticks;

  MapWidget({
    super.key,
    required this.sticks, required this.mapController,
  });


  final OSMOption osmOption = OSMOption(
    zoomOption: const ZoomOption(initZoom: 12.0, minZoomLevel: 3.0, maxZoomLevel: 18.0),
    userTrackingOption: const UserTrackingOption(enableTracking: false),
    roadConfiguration: const RoadOption(roadWidth: 5.0, roadColor: Colors.blueAccent),
    enableRotationByGesture: false,
    showZoomController: true,
    staticPoints: [],
    userLocationMarker: UserLocationMaker(
      personMarker: const MarkerIcon(icon: Icon(Icons.location_pin, color: Colors.blue, size: 48)),
      directionArrowMarker: const MarkerIcon(icon: Icon(Icons.directions, color: Colors.blue, size: 48)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: mapController,
      osmOption: osmOption,
      mapIsLoading: const Center(child: CircularProgressIndicator()),
      onMapIsReady: (bool ready) async {
        if (ready) {
          // Add all stick markers
          for (var stick in sticks) {
            await mapController.addMarker(
              GeoPoint(latitude: stick.latitude, longitude: stick.longitude),
              markerIcon: MarkerIcon(
                iconWidget: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3), // white border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3), // shadow position
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 64,
                    backgroundImage: stick.profilePic != null
                        ? NetworkImage(stick.profilePic!)
                        : null,
                    child: stick.profilePic == null ? const Icon(Icons.person, size: 64) : null,
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
