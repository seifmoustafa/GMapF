import 'package:flutter/material.dart';
import 'package:gmapf/utils/location_service.dart';
import 'package:gmapf/widgets/custom_list_view.dart';
import 'package:gmapf/widgets/custom_textfield.dart';
import 'package:gmapf/utils/google_maps_place_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gmapf/models/place_autocomplete_model/place_autocomplete_model.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initialCameraPositin;
  late GoogleMapsPlacesService googleMapsPlacesService;
  late GoogleMapController googleMapController;
  late LocationService locationService;
  late TextEditingController textEditingController;
  Set<Marker> markers = {};

  List<PlaceAutocompleteModel> places = [];
  @override
  void initState() {
    googleMapsPlacesService = GoogleMapsPlacesService();
    textEditingController = TextEditingController();

    initialCameraPositin = const CameraPosition(
      target: LatLng(0, 0),
    );
    locationService = LocationService();

    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      if (textEditingController.text.isNotEmpty) {
        var result = await googleMapsPlacesService.getPredictions(
            input: textEditingController.text);

        places.clear();
        places.addAll(result);
        setState(() {});
      } else {
        places.clear();
        setState(() {});
      }
    });
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
        Column(
          children: [
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: CustomTextField(
                textEditingController: textEditingController,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            CustomListView(places: places),
          ],
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
