import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:way_finders/models/device_with_status.dart';
import '../bloc/device_bloc/device_bloc.dart';

class MapWidget extends StatefulWidget {
  final MapController mapController;
  final VoidCallback? onMapReady;

  const MapWidget({
    super.key,
    required this.mapController,
    this.onMapReady,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final Map<String, GeoPoint> _deviceMarkers = {}; // deviceId -> GeoPoint
  bool _mapReady = false;


  final OSMOption osmOption = OSMOption(
    zoomOption: const ZoomOption(initZoom: 12.0, minZoomLevel: 3.0, maxZoomLevel: 18.0),
    userTrackingOption: const UserTrackingOption(enableTracking: false),
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
    return BlocListener<DeviceBloc, DeviceState>(
      listener: (context, state) async {
        if (!_mapReady) return;

        if (state is DeviceLoaded) {
          for (final device in state.data) {
            if (device.location == null) continue;

            final newPoint = GeoPoint(
              latitude: device.location!.latitude,
              longitude: device.location!.longitude,
            );

            if (_deviceMarkers.containsKey(device.deviceInfo.deviceUid)) {
              // Move existing marker
              await widget.mapController.changeLocationMarker(
                oldLocation: _deviceMarkers[device.deviceInfo.deviceUid]!,
                newLocation: newPoint,
              );
            } else {
              // Add new marker
              await _addDeviceMarker(device);
            }

            _deviceMarkers[device.deviceInfo.deviceUid] = newPoint;
          }
        }
      },
      child: OSMFlutter(
        controller: widget.mapController,
        osmOption: osmOption,
        mapIsLoading: const Center(child: CircularProgressIndicator()),
        onMapIsReady: (bool ready) async {
          if (!ready) return;
          _mapReady = true;

          final state = context.read<DeviceBloc>().state;
          if (state is DeviceLoaded) {
            for (final device in state.data) {
              if (device.location != null) {
                await _addDeviceMarker(device);
                _deviceMarkers[device.deviceInfo.deviceUid] = GeoPoint(
                  latitude: device.location!.latitude,
                  longitude: device.location!.longitude,
                );
              }
            }
          }

          widget.onMapReady?.call();
        },
      ),
    );
  }

  Future<void> _addDeviceMarker(DeviceWithStatus device) async {
    final loc = device.location!;
    final point = GeoPoint(latitude: loc.latitude, longitude: loc.longitude);

    await widget.mapController.addMarker(
      point,
      markerIcon: MarkerIcon(
        iconWidget: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: CircleAvatar(
            radius: 64,
            backgroundImage: AssetImage("assets/kenth.jpg"),
            // NetworkImage(device.deviceInfo.profilePic!),
          ),
        ),
      ),
    );
  }
}
