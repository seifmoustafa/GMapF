import 'package:flutter/material.dart';
import 'package:gmapf/utils/location_service.dart';
import 'package:gmapf/widgets/custom_textfield.dart';
import 'package:gmapf/utils/google_maps_place_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initialCameraPositin;
  late GoogleMapsPlacesService googleMapsPlaces;
  late GoogleMapController googleMapController;
  late LocationService locationService;
  late TextEditingController textEditingController;
  Set<Marker> markers = {};
  @override
  void initState() {
    textEditingController = TextEditingController();

    initialCameraPositin = const CameraPosition(
      target: LatLng(0, 0),
    );
    locationService = LocationService();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    if (textEditingController.text.isNotEmpty) {
      textEditingController.addListener(() async {
        var result = await googleMapsPlaces.getPredictions(
            input: textEditingController.text);
      });
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;
            updateCurrentLocation();
          },
          initialCameraPosition: initialCameraPositin,
          zoomControlsEnabled: false,
        ),
        CustomTextField(
          textEditingController: textEditingController,
        )
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      LatLng currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
          markerId: const MarkerId('myLocation'), position: currentPosition);
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
