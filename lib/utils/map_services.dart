import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gmapf/utils/routes_service.dart';
import 'package:gmapf/utils/location_service.dart';
import 'package:gmapf/models/location_info/lat_lng.dart';
import 'package:gmapf/models/location_info/location.dart';
import 'package:gmapf/utils/google_maps_place_service.dart';
import 'package:gmapf/models/routes_model/routes_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gmapf/models/location_info/location_info.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gmapf/models/place_details_model/place_details_model.dart';
import 'package:gmapf/models/place_autocomplete_model/place_autocomplete_model.dart';

class MapServices {
  PlacesService placesService = PlacesService();
  LocationService locationService = LocationService();
  RoutesService routesService = RoutesService();
  LatLng? currentLocation;
  Future<void> getPredictions(
      {required String input,
      required String sessionToken,
      required List<PlaceAutocompleteModel> places}) async {
    if (input.isNotEmpty) {
      var result = await placesService.getPredictions(
          sessionToken: sessionToken, input: input);
      places.clear();
      places.addAll(result);
    } else {
      places.clear();
    }
  }

  Future<List<LatLng>> getRouteData({required LatLng destination}) async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation!.latitude,
          longitude: currentLocation!.longitude,
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

  void displayRoutes(List<LatLng> points,
      {required Set<Polyline> polyline,
      required GoogleMapController googleMapController}) {
    Polyline route = Polyline(
      color: Colors.blue,
      width: 5,
      polylineId: const PolylineId('route'),
      points: points,
    );
    polyline.add((route));
    LatLngBounds bounds = getLatLngBounds(points);
    googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 32));
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

  void updateCurrentLocation(
      {required GoogleMapController googleMapController,
      required Set<Marker> markers,
      required Function onUpdateCurrentLocation}) {
    locationService.getRealTimeLocationData(
      (locationData) {
        currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
        Marker currentLocationMarker = Marker(
            markerId: const MarkerId('myLocation'), position: currentLocation!);
        CameraPosition myCurrentCameraPosition =
            CameraPosition(zoom: 15, target: currentLocation!);
        googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(myCurrentCameraPosition));
        markers.add(currentLocationMarker);
        onUpdateCurrentLocation();
      },
    );
  }

  Future<PlaceDetailsModel> getPlaceDetails({required String placeId}) async {
    return await placesService.getPlaceDetails(placeId: placeId);
  }
}
