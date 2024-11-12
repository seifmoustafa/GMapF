import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  /// Checks if the location service is enabled on the device.
  /// If the service is not enabled, it requests the user to enable it.
  /// Displays a SnackBar if the permission is denied.
  ///
  /// This method is asynchronous and returns a [Future<void>].
  Future<void> checkAndRequestLocationService() async {
    var isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        throw LocationServiceException();
      }
    }
  }

  /// Checks if the location permission is granted.
  /// If permission is denied, it requests the user for permission.
  /// Returns false if permission is denied forever or if the user does not grant permission.
  /// Returns true if permission is already granted or granted after the request.
  ///
  /// This method is asynchronous and returns a [Future<void>].
  Future<void> checkAndRequestLocationPermission() async {
    var permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      throw LocationPermissionException;
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        throw LocationPermissionException();
      }
    }
  }

  /// Locates the specified data in the location and returns it.
  ///
  /// This method takes a [onData] parameter, which represents the data to be located.
  /// It returns the located data from the specified location.
  void getRealTimeLocationData(void Function(LocationData)? onData) async {
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();
    location.onLocationChanged.listen(onData);
  }

  /// Retrieves the location data asynchronously.
  ///
  /// This method fetches the location data and returns it as a Future.
  /// It can be used to obtain the current location of the user or device.
  Future<LocationData> getLocation() async {
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();
    return await location.getLocation();
  }
}

class LocationServiceException implements Exception {}

class LocationPermissionException implements Exception {}
