class PrevisionJour {
  final DateTime date;
  final double tMax;
  final double tMin;
  final double pluie; // millimetres

  const PrevisionJour({
    required this.date,
    required this.tMax,
    required this.tMin,
    required this.pluie,
  });
}

class Meteo {
  final double temperature;
  final int humiditeAir;
  final double vent;
  final List<PrevisionJour> previsions;

  const Meteo({
    required this.temperature,
    required this.humiditeAir,
    required this.vent,
    required this.previsions,
  });

  double get pluieTotale => previsions.fold(0.0, (somme, p) => somme + p.pluie);

  factory Meteo.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final dates = daily['time'] as List<dynamic>;
    final tMax = daily['temperature_2m_max'] as List<dynamic>;
    final tMin = daily['temperature_2m_min'] as List<dynamic>;
    final pluie = daily['precipitation_sum'] as List<dynamic>;

    final previsions = <PrevisionJour>[];
    for (var i = 0; i < dates.length; i++) {
      previsions.add(PrevisionJour(
        date: DateTime.parse(dates[i] as String),
        tMax: (tMax[i] as num).toDouble(),
        tMin: (tMin[i] as num).toDouble(),
        pluie: (pluie[i] as num).toDouble(),
      ));
    }

    return Meteo(
      temperature: (current['temperature_2m'] as num).toDouble(),
      humiditeAir: (current['relative_humidity_2m'] as num).round(),
      vent: (current['wind_speed_10m'] as num).toDouble(),
      previsions: previsions,
    );
  }
}