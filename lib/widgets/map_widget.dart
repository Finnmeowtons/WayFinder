import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:way_finders/ip_address.dart';
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
  final Map<String, GeoPoint> _deviceMarkers = {}; // deviceId -> last known GeoPoint
  final Map<String, String?> _markerProfiles = {}; // deviceId -> last profile URL
  bool _mapReady = false;
  final double _toleranceMeters = 5;

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

  GeoPoint _roundGeoPoint(GeoPoint p, {int decimals = 6}) {
    double factor = pow(10, decimals).toDouble();
    return GeoPoint(
      latitude: (p.latitude * factor).round() / factor,
      longitude: (p.longitude * factor).round() / factor,
    );
  }

  double _distanceInMeters(GeoPoint a, GeoPoint b) {
    const double R = 6371000; // Earth radius in meters
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final haversine = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(haversine), sqrt(1 - haversine));
    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeviceBloc, DeviceState>(
      listener: (context, state) async {
        if (!_mapReady) return;

        if (state is DeviceLoaded) {
          final currentIds = state.data.map((d) => d.deviceInfo.deviceUid).toSet();
          final existingIds = _deviceMarkers.keys.toSet();

          // Remove markers for deleted devices
          for (final removedId in existingIds.difference(currentIds)) {
            try {
              await widget.mapController.removeMarker(_deviceMarkers[removedId]!);
            } catch (_) {}
            _deviceMarkers.remove(removedId);
            _markerProfiles.remove(removedId);
          }

          // Update or add markers for existing/new devices
          for (final device in state.data) {
            if (device.location != null) {
              await _updateDeviceMarker(device);
            }
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
                _deviceMarkers[device.deviceInfo.deviceUid] = _roundGeoPoint(
                  GeoPoint(
                    latitude: device.location!.latitude,
                    longitude: device.location!.longitude,
                  ),
                );
                _markerProfiles[device.deviceInfo.deviceUid] = device.deviceInfo.profilePic;
              }
            }
          }

          widget.onMapReady?.call();
        },
      ),
    );
  }

  Future<void> _updateDeviceMarker(DeviceWithStatus device) async {
    if (device.location == null) return;

    final deviceId = device.deviceInfo.deviceUid;
    final newPoint = _roundGeoPoint(GeoPoint(
      latitude: device.location!.latitude,
      longitude: device.location!.longitude,
    ));
    final oldPoint = _deviceMarkers[deviceId];
    final oldProfile = _markerProfiles[deviceId];

    // Only update if moved or profile changed
    final moved = oldPoint == null || _distanceInMeters(oldPoint, newPoint) >= _toleranceMeters;
    final profileChanged = oldProfile != device.deviceInfo.profilePic;

    if (!moved && !profileChanged) return;

    if (oldPoint != null) {
      try {
        await widget.mapController.changeLocationMarker(
          oldLocation: oldPoint,
          newLocation: newPoint,
        );
      } catch (_) {
        try {
          await widget.mapController.removeMarker(oldPoint);
        } catch (_) {}
        await _addDeviceMarker(device);
      }
    } else {
      await _addDeviceMarker(device);
    }

    // If profile changed, replace marker
    if (profileChanged) {
      try {
        await widget.mapController.removeMarker(newPoint);
      } catch (_) {}
      await _addDeviceMarker(device);
    }

    _deviceMarkers[deviceId] = newPoint;
    _markerProfiles[deviceId] = device.deviceInfo.profilePic;
  }

  Future<void> _addDeviceMarker(DeviceWithStatus device) async {
    final loc = device.location!;
    final point = _roundGeoPoint(GeoPoint(
      latitude: loc.latitude,
      longitude: loc.longitude,
    ));

    await widget.mapController.addMarker(
      point,
      markerIcon: MarkerIcon(
        iconWidget: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 3)),
            ],
          ),
          child: CircleAvatar(
            radius: 48,
            backgroundImage: device.deviceInfo.profilePic != null
                ? NetworkImage("${IpAddress.ipAddress}${device.deviceInfo.profilePic}")
                : null,
            backgroundColor: Colors.grey[200],
            child: device.deviceInfo.profilePic == null ? const Icon(Icons.person, size: 48) : null,
          ),
        ),
      ),
    );
  }
}
