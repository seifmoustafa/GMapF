import 'package:flutter/material.dart';
import 'package:gmapf/widgets/google_map_view.dart';

void main() {
  runApp(const GMapF());
}
class GMapF extends StatelessWidget {
  const GMapF({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GoogleMapView(),
    );
  }
}