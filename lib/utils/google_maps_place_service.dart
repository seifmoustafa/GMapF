import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gmapf/models/place_details_model/place_details_model.dart';
import 'package:gmapf/models/place_autocomplete_model/place_autocomplete_model.dart';

/// A service class for interacting with the Google Maps Places API.
class PlacesService {
  /// The base URL for the Google Maps Places API.
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// The API key for authenticating requests to the Google Maps Places API.
  final String apiKey = 'AIzaSyAHRtKMcRoMsCQ4quZtxoIfoph4F9vOimk';

  /// Fetches a list of place predictions based on the provided input string.
  ///
  /// This method makes a request to the Google Maps Places API's autocomplete endpoint
  /// and returns a list of predictions that match the input.
  ///
  /// [input] - The input string to search for place predictions.
  ///
  /// Returns a [Future<List<PlaceAutocompleteModel>>] containing the list of place predictions.
  /// Throws an [Exception] if the request fails.
  Future<List<PlaceAutocompleteModel>> getPredictions(
      {required String input, required String sessionToken}) async {
    var response = await http.get(Uri.parse(
        '$baseUrl/autocomplete/json?key=$apiKey&input=$input&sessiontoken=$sessionToken'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['predictions'];
      List<PlaceAutocompleteModel> places = [];
      for (var item in data) {
        places.add(PlaceAutocompleteModel.fromJson(item));
      }
      return places;
    } else {
      throw Exception();
    }
  }

  /// Fetches detailed information about a place using its unique place ID.
  ///
  /// This method makes a request to the Google Maps Places API's details endpoint
  /// to retrieve detailed information about a specific place.
  ///
  /// [placeId] - The unique identifier for the place whose details are to be fetched.
  ///
  /// Returns a [Future<PlaceDetailsModel>] containing the details of the specified place.
  /// Throws an [Exception] if the request fails.
  Future<PlaceDetailsModel> getPlaceDetails({required String placeId}) async {
    var response = await http
        .get(Uri.parse('$baseUrl/details/json?key=$apiKey&place_id=$placeId'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['result'];

      return PlaceDetailsModel.fromJson(data);
    } else {
      throw Exception();
    }
  }
}
