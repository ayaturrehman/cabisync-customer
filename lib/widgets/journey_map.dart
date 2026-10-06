import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_model.dart';

/// Shows actual selected locations, without inventing a road route.
class JourneyMap extends StatefulWidget {
  final List<LocationModel> locations;
  final LatLng? driver;
  const JourneyMap({super.key, required this.locations, this.driver});

  @override
  State<JourneyMap> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<JourneyMap> {
  GoogleMapController? _controller;
  List<LatLng> get _points => [
    for (final location in widget.locations)
      if (location.lat.isFinite &&
          location.lng.isFinite &&
          location.lat.abs() <= 90 &&
          location.lng.abs() <= 180 &&
          (location.lat != 0 || location.lng != 0))
        LatLng(location.lat, location.lng),
  ];

  Future<void> _fit() async {
    final points = _points;
    if (points.isEmpty || _controller == null) return;
    if (points.length == 1) {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }
    var south = points.first.latitude, north = south;
    var west = points.first.longitude, east = west;
    for (final point in points.skip(1)) {
      south = point.latitude < south ? point.latitude : south;
      north = point.latitude > north ? point.latitude : north;
      west = point.longitude < west ? point.longitude : west;
      east = point.longitude > east ? point.longitude : east;
    }
    if (south == north && west == east) {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
    } else {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(south, west),
            northeast: LatLng(north, east),
          ),
          36,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant JourneyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPoints = oldWidget.locations
        .map((p) => '${p.lat},${p.lng}')
        .join(';');
    final newPoints = widget.locations
        .map((p) => '${p.lat},${p.lng}')
        .join(';');
    if (oldPoints != newPoints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fit();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = _points;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: points.isEmpty ? const LatLng(51.5074, -0.1278) : points.first,
        zoom: 14,
      ),
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      markers: {
        for (var i = 0; i < points.length; i++)
          Marker(
            markerId: MarkerId('stop_$i'),
            position: points[i],
            infoWindow: InfoWindow(
              title:
                  i == 0
                      ? 'Pickup'
                      : i == points.length - 1
                      ? 'Destination'
                      : 'Stop $i',
            ),
          ),
        if (widget.driver != null)
          Marker(
            markerId: const MarkerId('driver'),
            position: widget.driver!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: const InfoWindow(title: 'Driver'),
          ),
      },
      onMapCreated: (controller) {
        _controller = controller;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fit();
        });
      },
    );
  }
}
