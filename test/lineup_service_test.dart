import 'package:flutter_test/flutter_test.dart';
import 'package:statsprov2/models/player_model.dart';
import 'package:statsprov2/services/lineup_service.dart';

void main() {
  group('LineupService Tests', () {
    final player1 = Player(
      id: '1',
      name: 'Portero Pro',
      position: 'POR',
      height: 1.90,
      preferredFoot: 'Derecho',
      nationality: 'ESP',
      pot: 90, fon: 85, vel: 50, acc: 50, con: 50, pas: 60, dis: 40, ent: 40,
    );

    final player2 = Player(
      id: '2',
      name: 'Defensa Central',
      position: 'DFC',
      height: 1.85,
      preferredFoot: 'Derecho',
      nationality: 'ESP',
      ent: 90, fon: 80, pot: 75, vel: 60, acc: 60, con: 55, pas: 65, dis: 40,
    );

    final player3 = Player(
      id: '3',
      name: 'Delantero Tanque',
      position: 'DC',
      height: 1.88,
      preferredFoot: 'Derecho',
      nationality: 'ARG',
      dis: 92, vel: 85, acc: 80, pot: 85, con: 75, pas: 70, fon: 70, ent: 30,
    );

    test('calculateGrl should respect position weights', () {
      double grlPor = LineupService.calculateGrl(player1, 'POR');
      expect(grlPor, greaterThan(75));
      
      double grlDc = LineupService.calculateGrl(player3, 'DC');
      expect(grlDc, greaterThan(80));
    });

    test('calculateGrl should apply compatibility penalty', () {
      // DFC playing as MCD should have a factor of 0.85
      double grlNatural = LineupService.calculateGrl(player2, 'DFC');
      double grlOut = LineupService.calculateGrl(player2, 'MCD');
      
      // Since baseGrl for DFC and MCD logic is similar in the implementation, 
      // the factor should be the main difference.
      expect(grlOut, lessThan(grlNatural));
    });

    test('generateBestEleven should select the best players without repetition', () {
      final players = [player1, player2, player3];
      final formation = ['POR', 'DFC', 'DC'];
      
      final result = LineupService.generateBestEleven(players, formation);
      
      expect(result.length, 3);
      expect(result[0]['player'].name, 'Portero Pro');
      expect(result[1]['player'].name, 'Defensa Central');
      expect(result[2]['player'].name, 'Delantero Tanque');
      
      // Ensure no duplicates in the final lineup
      final selectedIds = result.map((m) => (m['player'] as Player).id).toSet();
      expect(selectedIds.length, 3);
    });
  });
}
