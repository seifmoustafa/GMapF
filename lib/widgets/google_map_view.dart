import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:gmapf/utils/map_services.dart';
import 'package:gmapf/utils/location_service.dart';
import 'package:gmapf/widgets/custom_list_view.dart';
import 'package:gmapf/widgets/custom_textfield.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gmapf/models/place_autocomplete_model/place_autocomplete_model.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initialCameraPositin;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late MapServices mapServices;
  Set<Marker> markers = {};
  late Uuid uuid;
  String? sessionToken;
  List<PlaceAutocompleteModel> places = [];
  late LatLng currentLocation;
  late LatLng destination;
  Set<Polyline> polyline = {};
  @override
  void initState() {
    uuid = const Uuid();
    mapServices = MapServices();
    textEditingController = TextEditingController();

    initialCameraPositin = const CameraPosition(
      target: LatLng(0, 0),
    );
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      sessionToken ??= uuid.v4();

      await mapServices.getPredictions(
          input: textEditingController.text,
          sessionToken: sessionToken!,
          places: places);
      setState(() {});
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
          polylines: polyline,
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;
            updateCurrentLocation();
          },
          initialCameraPosition: initialCameraPositin,
          zoomControlsEnabled: false,
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTextField(
                  textEditingController: textEditingController,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              textEditingController.text.isNotEmpty
                  ? CustomListView(
                      onPlaceSelect: (placeDetailsModel) async {
                        textEditingController.clear();
                        places.clear();
                        sessionToken = null;
                        setState(() {});
                        destination = LatLng(
                          placeDetailsModel.geometry!.location!.lat!,
                          placeDetailsModel.geometry!.location!.lng!,
                        );
                        var points = await mapServices.getRouteData(
                            currentLocation: currentLocation,
                            destination: destination);
                        mapServices.displayRoutes(points,
                            polyline: polyline,
                            googleMapController: googleMapController);
                        setState(() {});
                      },
                      places: places,
                      mapServices: mapServices,
                    )
                  : SizedBox(),
            ],
          ),
        )
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      currentLocation = await mapServices.updateCurrentLocation(
          googleMapController: googleMapController, markers: markers);
      setState(() {});
    } on LocationServiceException catch (e) {
    } on LocationPermissionException catch (e) {
    } catch (e) {}
  }
}
