import '../models/player_model.dart';

class LineupService {
  /// Mapa de compatibilidad de posiciones.
  /// Si un jugador juega en una posición secundaria cercana, se aplica un factor.
  static const Map<String, Map<String, double>> positionCompatibility = {
    
    'POR': {'POR': 1.0},
    'DFC': {'DFC': 1.0, 'MCD': 0.85, 'LI': 0.75, 'LD': 0.75},
    'LI': {'LI': 1.0, 'LD': 0.90, 'DFC': 0.80, 'MI': 0.85},
    'LD': {'LD': 1.0, 'LI': 0.90, 'DFC': 0.80, 'MD': 0.85},
    'MCD': {'MCD': 1.0, 'DFC': 0.80, 'MC': 0.90},
    'MC': {'MC': 1.0, 'MCD': 0.90, 'MCO': 0.90, 'MI': 0.85, 'MD': 0.85},
    'MCO': {'MCO': 1.0, 'MC': 0.90, 'SD': 0.85, 'MI': 0.80, 'MD': 0.80},
    'MI': {'MI': 1.0, 'MD': 0.90, 'EI': 0.90, 'MCO': 0.85, 'LI': 0.75},
    'MD': {'MD': 1.0, 'MI': 0.90, 'ED': 0.90, 'MCO': 0.85, 'LD': 0.75},
    'EI': {'EI': 1.0, 'ED': 0.90, 'MI': 0.90, 'SD': 0.85, 'DC': 0.80},
    'ED': {'ED': 1.0, 'EI': 0.90, 'MD': 0.90, 'SD': 0.85, 'DC': 0.80},
    'SD': {'SD': 1.0, 'DC': 0.95, 'MCO': 0.90, 'EI': 0.85, 'ED': 0.85},
    'DC': {'DC': 1.0, 'SD': 0.95, 'EI': 0.80, 'ED': 0.80},
  };

  /// Calcula el GRL Ajustado de un jugador para una posición específica.
  static double calculateGrl(Player p, String targetPosition) {
    final stats = p.stats;
    final height = p.height ?? 1.75; // Valor por defecto si no se proporciona altura
    double baseGrl = 0;

    // Criterios de Pesos por Posición
    if (targetPosition == 'POR') {

      // POR: Prioriza fon y dis.
      baseGrl = (stats['dis']! * 0.32) + (stats['fon']! * 0.34) + 
                ((stats['vel']! + stats['acc']! + stats['con']! + stats['pas']! + stats['pot']! + stats['ent']!) / 6 * 0.04) + (((100 * height) / 2.30) * 0.30); // Bonus por altura para porteros
    } else if (targetPosition == 'DFC' || targetPosition == 'MCD') {

      // DFC/MCD: Prioriza ent, fon y pot.
      baseGrl = (stats['ent']! * 0.35) + (stats['fon']! * 0.25) + (stats['pot']! * 0.2) +
                ((stats['vel']! + stats['acc']! + stats['con']! + stats['pas']! + stats['dis']!) / 5 * 0.2);
    } else if (targetPosition == 'LI' || targetPosition == 'LD') {

      // LI/LD: Prioriza vel, acc y fon.
      baseGrl = (stats['vel']! * 0.25) + (stats['acc']! * 0.25) + (stats['fon']! * 0.25) + (stats['ent']! * 0.125) +
                ((stats['con']! + stats['pas']! + stats['pot']! + stats['dis']!) / 5 * 0.125); 
    
    }else if (targetPosition == 'MC' || targetPosition == 'MI' || targetPosition == 'MD') {
      
      // MC/MI/MD: Prioriza pas, con y acc.
      baseGrl = (stats['pas']! * 0.35) + (stats['con']! * 0.3) + (stats['acc']! * 0.15) +
                ((stats['vel']! + stats['fon']! + stats['pot']! + stats['dis']! + stats['ent']!) / 5 * 0.2);
    } else if (targetPosition == 'SD' || targetPosition == 'MCO') {

      // SD/MCO: Prioriza dis, vel, acc y pas.
      baseGrl = (stats['dis']! * 0.3) + (stats['vel']! * 0.25) + (stats['acc']! * 0.2) + (stats['pas']! * 0.15) +
                ((stats['fon']! + stats['con']! + stats['pot']! + stats['ent']!) / 4 * 0.1);
    } else if (targetPosition == 'DC') {

      // DC: Prioriza dis, vel, acc y pot.
      baseGrl = (stats['dis']! * 0.3) + (stats['vel']! * 0.25) + (stats['acc']! * 0.2) + (stats['pot']! * 0.15) +
                ((stats['fon']! + stats['con']! + stats['pas']! + stats['ent']!) / 4 * 0.1);
    } else if (targetPosition == 'EI' || targetPosition == 'ED') {

      // EI/ED: Prioriza dis, vel, acc y fon.
      baseGrl = (stats['dis']! * 0.25) + (stats['vel']! * 0.2) + (stats['acc']! * 0.15) + (stats['fon']! * 0.25) +
                ((stats['pas']! + stats['con']! + stats['pot']! + stats['ent']!) / 4 * 0.15);
    } else {

      // Default
      baseGrl = (stats['ent']! * 0.3) + (stats['fon']! * 0.2) + (stats['vel']! * 0.2) +
                ((stats['acc']! + stats['pot']! + stats['con']! + stats['pas']! + stats['dis']!) / 5 * 0.3);
    }

    // Aplicar factor de compatibilidad
    double factor = 0.70; // Factor base por defecto si no hay relación directa
    if (positionCompatibility.containsKey(p.position)) {
      factor = positionCompatibility[p.position]![targetPosition] ?? 0.70;
    }

    return baseGrl * factor;
  }

  /// Genera el Mejor 11 basado en una formación dada.
  /// slots: Lista de posiciones requeridas (ej: ['POR', 'DFC', 'DFC', 'LI', 'LD', 'MC', 'MC', 'MI', 'MD', 'DC', 'DC'])
  static List<Map<String, dynamic>> generateBestEleven(List<Player> players, List<String> formationSlots) {
    List<Player> availablePlayers = List.from(players);
    List<Map<String, dynamic>> lineup = [];

    for (String slot in formationSlots) {
      Player? bestPlayer;
      double maxGrl = -1.0;

      for (Player p in availablePlayers) {
        double currentGrl = calculateGrl(p, slot);
        if (currentGrl > maxGrl) {
          maxGrl = currentGrl;
          bestPlayer = p;
        }
      }

      if (bestPlayer != null) {
        lineup.add({
          'position': slot,
          'player': bestPlayer,
          'adjustedGrl': maxGrl,
        });
        availablePlayers.remove(bestPlayer);
      }
    }

    return lineup;
  }
}
