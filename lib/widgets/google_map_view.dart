import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:gmapf/utils/routes_service.dart';
import 'package:gmapf/utils/location_service.dart';
import 'package:gmapf/widgets/custom_list_view.dart';
import 'package:gmapf/widgets/custom_textfield.dart';
import 'package:gmapf/models/location_info/lat_lng.dart';
import 'package:gmapf/models/location_info/location.dart';
import 'package:gmapf/utils/google_maps_place_service.dart';
import 'package:gmapf/models/routes_model/routes_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gmapf/models/location_info/location_info.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gmapf/models/place_autocomplete_model/place_autocomplete_model.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initialCameraPositin;
  late PlacesService placesService;
  late GoogleMapController googleMapController;
  late LocationService locationService;
  late TextEditingController textEditingController;
  Set<Marker> markers = {};
  late RoutesService routesService;
  late Uuid uuid;
  String? sessionToken;
  List<PlaceAutocompleteModel> places = [];
  late LatLng currentLocation;
  late LatLng destination;
  Set<Polyline> polyline = {};
  @override
  void initState() {
    uuid = const Uuid();
    placesService = PlacesService();
    textEditingController = TextEditingController();

    initialCameraPositin = const CameraPosition(
      target: LatLng(0, 0),
    );
    locationService = LocationService();
    routesService = RoutesService();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      if (textEditingController.text.isNotEmpty) {
        sessionToken ??= uuid.v4();
        var result = await placesService.getPredictions(
            sessionToken: sessionToken!, input: textEditingController.text);

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
          polylines: polyline,
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
            CustomListView(
              onPlaceSelect: (placeDetailsModel) async {
                textEditingController.clear();
                places.clear();
                sessionToken = null;
                setState(() {});
                destination = LatLng(
                  placeDetailsModel.geometry!.location!.lat!,
                  placeDetailsModel.geometry!.location!.lng!,
                );
                var points = await getRouteData();
                displayRoutes(points);
              },
              places: places,
              placesService: placesService,
            ),
          ],
        )
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
          markerId: const MarkerId('myLocation'), position: currentLocation);
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

  Future<List<LatLng>> getRouteData() async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        ),
      ),
    );
    LocationInfoModel destenation = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: destination.latitude,
          longitude: destination.longitude,
        ),
      ),
    );

    RoutesModel routes = await routesService.fetchRoute(
        origin: origin, destenation: destenation);
    PolylinePoints polylinePoints = PolylinePoints();

    List<LatLng> points = getDecodedRoutes(polylinePoints, routes);
    return points;
  }

  List<LatLng> getDecodedRoutes(
      PolylinePoints polylinePoints, RoutesModel routes) {
    List<PointLatLng> result = polylinePoints
        .decodePolyline(routes.routes!.first.polyline!.encodedPolyline!);
    List<LatLng> points =
        result.map((e) => LatLng(e.latitude, e.longitude)).toList();
    return points;
  }

  void displayRoutes(List<LatLng> points) {
    Polyline route = Polyline(
      color: Colors.blue,
      width: 5,
      polylineId: const PolylineId('route'),
      points: points,
    );
    polyline.add((route));
    LatLngBounds bounds = getLatLngBounds(points);
    googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 32));
    setState(() {});
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    var soutWestLatitude = points.first.latitude;
    var soutWestLongitude = points.first.longitude;
    var northEastLatitude = points.first.latitude;
    var northEastLongitude = points.first.longitude;
    for (var point in points) {
      soutWestLatitude = min(soutWestLatitude, point.latitude);
      soutWestLongitude = min(soutWestLongitude, point.longitude);
      northEastLatitude = max(northEastLatitude, point.latitude);
      northEastLongitude = max(northEastLongitude, point.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(soutWestLatitude, soutWestLongitude),
      northeast: LatLng(
        northEastLatitude,
        northEastLongitude,
      ),
    );
  }
}
