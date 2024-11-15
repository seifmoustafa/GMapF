import 'package:flutter/material.dart';
import 'package:gmapf/utils/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initialCameraPositin;
  late GoogleMapController googleMapController;
  late LocationService locationService;
  Set<Marker> markers = {};
  @override
  void initState() {
    initialCameraPositin = const CameraPosition(
      target: LatLng(0, 0),
    );
    locationService = LocationService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: markers,
      onMapCreated: (controller) {
        googleMapController = controller;
        updateCurrentLocation();
      },
      initialCameraPosition: initialCameraPositin,
      zoomControlsEnabled: false,
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      LatLng currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker =
          Marker(markerId: MarkerId('myLocation'), position: currentPosition);
      CameraPosition myCurrentCameraPosition = CameraPosition(
          zoom: 15,
          target: LatLng(locationData.latitude!, locationData.longitude!));
      googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(myCurrentCameraPosition));
      markers.add(currentLocationMarker);
      setState(() {});
    } on LocationServiceException catch (e) {
    } on LocationPermissionException catch (e) {
    } catch (e) {}
  }
}
