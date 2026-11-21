import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:agrismart/models/meteo.dart';

class MeteoException implements Exception {
  final String message;
  const MeteoException(this.message);
}

class MeteoService {
  static const String latitude = '33.70';
  static const String longitude = '8.97';

  Future<Meteo> charger() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude,
      'longitude': longitude,
      'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m',
      'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum',
      'timezone': 'auto',
      'forecast_days': '3',
    });

    final http.Response reponse;
    try {
      reponse = await http.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const MeteoException('Le serveur met trop de temps à répondre');
    } catch (e) {
      debugPrint('ERREUR METEO: $e'); // temporaire
      throw const MeteoException('Pas de connexion Internet');
    }

    if (reponse.statusCode != 200) {
      throw MeteoException('Erreur du serveur (${reponse.statusCode})');
    }

    try {
      final json = jsonDecode(reponse.body) as Map<String, dynamic>;
      return Meteo.fromJson(json);
    } catch (_) {
      throw const MeteoException('Réponse du serveur illisible');
    }
  }
}