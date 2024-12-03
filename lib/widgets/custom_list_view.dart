import 'package:flutter/material.dart';
import 'package:gmapf/utils/map_services.dart';
import 'package:gmapf/utils/google_maps_place_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gmapf/models/place_details_model/place_details_model.dart';
import 'package:gmapf/models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places,
    required this.mapServices,
    required this.onPlaceSelect,
  });

  final List<PlaceAutocompleteModel> places;
  final void Function(PlaceDetailsModel) onPlaceSelect;
  final MapServices mapServices;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(FontAwesomeIcons.mapPin),
            title: Text(places[index].description!),
            trailing: IconButton(
                onPressed: () async {
                  var placeDetails = await mapServices.getPlaceDetails(
                      placeId: places[index].placeId!);
                  onPlaceSelect(placeDetails);
                },
                icon: const Icon(Icons.arrow_forward_ios)),
          );
        },
        itemCount: places.length,
      ),
    );
  }
}
