import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gmapf/models/routes_modifier.dart';
import 'package:gmapf/models/routes_model/routes_model.dart';
import 'package:gmapf/models/location_info/location_info.dart';

class RoutesService {
  final String baseUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = 'AIzaSyAHRtKMcRoMsCQ4quZtxoIfoph4F9vOimk';
  Future<RoutesModel> fetchRoute(
      {required LocationInfo origin,
      required LocationInfo destenation,
      RoutesModifier? routesModifier}) async {
    Uri url = Uri.parse(baseUrl);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          ' routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
    };
    Map<String, dynamic> body = {
      "origin": origin.toJson(),
      "destination": destenation.toJson(),
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": routesModifier != null
          ? routesModifier.toJson()
          : RoutesModifier().toJson(),
      "languageCode": "en-US",
      "units": "IMPERIAL"
    };
    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return RoutesModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('No routes found');
    }
  }
}
