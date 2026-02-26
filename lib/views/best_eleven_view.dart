import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player_model.dart';
import '../services/lineup_service.dart';
import '../services/players_provider.dart';

class BestElevenView extends StatelessWidget {
  const BestElevenView({super.key});

  @override
  Widget build(BuildContext context) {
    final allPlayers = Provider.of<PlayersProvider>(context).fullPlayers;
    
    // Formación táctica 4-3-3 (POR, DFC, DFC, LI, LD, MCD, MC, MCO, EI, ED, DC)
    final formation = ['POR', 'DFC', 'DFC', 'LI', 'LD', 'MCD', 'MC', 'MCO', 'EI', 'ED', 'DC'];
    final bestEleven = LineupService.generateBestEleven(allPlayers, formation);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mejor 11 Formacion 4-3-3"),
        centerTitle: true,
      ),
      body: bestEleven.isEmpty
          ? const Center(child: Text("Agrega más jugadores para ver la formación"))
          : LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green[900]!, Colors.green[700]!, Colors.green[800]!],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // --- LÍNEAS DE LA CANCHA ---
                      _buildPitchLines(),

                      // --- JUGADORES ---
                      ...List.generate(bestEleven.length, (index) {
                        final item = bestEleven[index];
                        final Player p = item['player'];
                        final String slotPos = item['position'];
                        final double adjustedGrl = item['adjustedGrl'];
                        
                        return _buildPlayerOnPitch(
                          constraints, 
                          p, 
                          slotPos, 
                          adjustedGrl, 
                          index
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPitchLines() {
    return Stack(
      children: [
        // Área grande (Superior - DC)
        Positioned(
          top: 0, left: 60, right: 60, height: 80,
          child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white24, width: 2))),
        ),
        // Área grande (Inferior - POR)
        Positioned(
          bottom: 0, left: 60, right: 60, height: 80,
          child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white24, width: 2))),
        ),
        // Círculo Central
        Center(
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
          ),
        ),
        // Línea de medio campo
        Center(
          child: Container(width: double.infinity, height: 2, color: Colors.white24),
        ),
      ],
    );
  }

  Widget _buildPlayerOnPitch(BoxConstraints constraints, Player p, String slotPos, double grl, int index) {
    // Definimos las coordenadas (x, y) relativas para cada posición (0.0 a 1.0)
    final Map<int, Offset> coords = {
      0:  const Offset(0.50, 0.88), // POR
      1:  const Offset(0.35, 0.72), // DFC 1
      2:  const Offset(0.65, 0.72), // DFC 2
      3:  const Offset(0.12, 0.65), // LI
      4:  const Offset(0.88, 0.65), // LD
      5:  const Offset(0.50, 0.55), // MCD
      6:  const Offset(0.28, 0.42), // MC
      7:  const Offset(0.72, 0.42), // MCO
      8:  const Offset(0.15, 0.22), // EI
      9:  const Offset(0.85, 0.22), // ED
      10: const Offset(0.50, 0.10), // DC
    };

    final offset = coords[index] ?? const Offset(0.5, 0.5);
    final Color levelColor = p.getPlayerColor(p.totalStats);
    bool isNatural = p.position == slotPos;

    return Positioned(
      left: (offset.dx * constraints.maxWidth) - 35,
      top: (offset.dy * constraints.maxHeight) - 45,
      child: Column(
        children: [
          // Marker del jugador
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
              border: Border.all(color: levelColor, width: 3),
              boxShadow: [
                BoxShadow(color: levelColor.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1),
              ],
            ),
            child: Center(
              child: Text(
                grl.toStringAsFixed(0),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Info del jugador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  p.name.split(' ').first,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isNatural ? slotPos : "$slotPos*",
                  style: TextStyle(
                    fontSize: 8, 
                    color: isNatural ? Colors.greenAccent : Colors.orangeAccent,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
