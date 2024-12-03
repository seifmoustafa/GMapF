import 'package:gmapf/utils/routes_service.dart';
import 'package:gmapf/utils/location_service.dart';
import 'package:gmapf/utils/google_maps_place_service.dart';
import 'package:gmapf/models/place_autocomplete_model/place_autocomplete_model.dart';

class MapServices {
  PlacesService placesService = PlacesService();
  LocationService locationService = LocationService();
  RoutesService routesService = RoutesService();

  getPredictions(
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
}
