import 'package:geolocator/geolocator.dart';

class LocationService {
  // Coordenadas geográficas da sede da empresa 
  static const double companyLatitude = -22.736829;
  static const double companyLongitude = -47.332353;
  static const double maxAllowedDistanceMeters = 100.0;

  // Verifica e solicita permissão de localização ao usuário
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('O serviço de GPS está desativado. Ative-o para continuar.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente nas configurações.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // Calcula a distância em metros entre a posição atual do usuário e a empresa
  double calculateDistance(double userLat, double userLng) {
    return Geolocator.distanceBetween(
      userLat,
      userLng,
      companyLatitude,
      companyLongitude,
    );
  }

  // Verifica se a distância calculada está dentro do limite 
  bool isWithinRadius(double distanceInMeters) {
    return distanceInMeters <= maxAllowedDistanceMeters;
  }
}