import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/players_provider.dart';
import '../models/player_model.dart';

class CompareView extends StatefulWidget {
  const CompareView({super.key});

  @override
  State<CompareView> createState() => _CompareViewState();
}

class _CompareViewState extends State<CompareView> {
  Player? player1;
  Player? player2;
  
  Map<String, bool> enabledStats = {
    'vel': true, 'acc': true, 'fon': true, 'pot': true,
    'con': true, 'pas': true, 'dis': true, 'ent': true,
  };

  @override
  Widget build(BuildContext context) {
    final allPlayers = Provider.of<PlayersProvider>(context).players;
    final activeKeys = enabledStats.entries.where((e) => e.value).map((e) => e.key).toList();

    return Scaffold( // Asegúrate de tener un Scaffold si esta es una vista independiente
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Padding un poco más ajustado
        child: Column(
          children: [
            // 1. Selectores más compactos
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea al inicio
              children: [
                Expanded(child: _buildPlayerPicker(allPlayers, player1, (p) => setState(() => player1 = p), "Jugador 1", Colors.greenAccent)),
                const SizedBox(width: 8),
                Expanded(child: _buildPlayerPicker(allPlayers, player2, (p) => setState(() => player2 = p), "Jugador 2", Colors.blueAccent)),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // 2. Chips de Filtro (Ya lo tienes bien con Wrap)
            Wrap(
              spacing: 6,
              runSpacing: 2, // Reducimos espacio vertical
              alignment: WrapAlignment.center,
              children: enabledStats.keys.map((key) {
                return FilterChip(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(2),
                  label: Text(key.toUpperCase(), style: const TextStyle(fontSize: 9)),
                  selected: enabledStats[key]!,
                  onSelected: (val) {
                    if (!val && enabledStats.values.where((e) => e).length <= 3) return;
                    setState(() => enabledStats[key] = val);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 15),

            if (player1 != null && player2 != null) ...[
              // 3. Leyenda con Wrap (Por si los nombres son largos)
              Wrap(
                spacing: 20,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegendItem(player1!.name, Colors.greenAccent),
                  _buildLegendItem(player2!.name, Colors.blueAccent),
                ],
              ),
              
              const SizedBox(height: 15),
              
              // Gráfico con altura un poco más controlada
              SizedBox(
                height: 220, 
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    getTitle: (index, angle) => RadarChartTitle(
                      text: activeKeys[index].toUpperCase(), 
                      angle: angle,
                    ),
                    tickCount: 5,
                    tickBorderData: const BorderSide(color: Colors.transparent),
                    gridBorderData: const BorderSide(color: Colors.white24, width: 1),
                    ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                    dataSets: [
                      _buildDataSet(player1!, Colors.greenAccent, activeKeys),
                      _buildDataSet(player2!, Colors.blueAccent, activeKeys),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildStatsTable(activeKeys),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Text("Selecciona dos jugadores"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget para la leyenda
  Widget _buildLegendItem(String name, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  // Tabla comparativa de números
  Widget _buildStatsTable(List<String> keys) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              const SizedBox(),
              Text(player1!.name.split(' ')[0], textAlign: TextAlign.center, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              Text(player2!.name.split(' ')[0], textAlign: TextAlign.center, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ]),
            ...keys.map((k) {
              int val1 = _getStatValue(player1!, k);
              int val2 = _getStatValue(player2!, k);
              return TableRow(children: [
                Padding(padding: const EdgeInsets.all(8.0), child: Text(k.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey))),
                Text("$val1", textAlign: TextAlign.center, style: TextStyle(fontWeight: val1 > val2 ? FontWeight.bold : FontWeight.normal)),
                Text("$val2", textAlign: TextAlign.center, style: TextStyle(fontWeight: val2 > val1 ? FontWeight.bold : FontWeight.normal)),
              ]);
            }),
          ],
        ),
      ),
    );
  }

  int _getStatValue(Player p, String key) {
    switch (key) {
      case 'vel': return p.vel; case 'acc': return p.acc;
      case 'fon': return p.fon; case 'pot': return p.pot;
      case 'con': return p.con; case 'pas': return p.pas;
      case 'dis': return p.dis; case 'ent': return p.ent;
      default: return 0;
    }
  }

  RadarDataSet _buildDataSet(Player p, Color color, List<String> activeKeys) {
    return RadarDataSet(
      fillColor: color.withValues(alpha: 0.3),
      borderColor: color,
      entryRadius: 2,
      dataEntries: activeKeys.map((k) => RadarEntry(value: _getStatValue(p, k).toDouble())).toList(),
    );
  }

  Widget _buildPlayerPicker(List<Player> list, Player? current, Function(Player?) onSelect, String hint, Color color) {
    return DropdownButtonFormField<Player>(
      isExpanded: true, // Evita errores de ancho
      decoration: InputDecoration(
        isDense: true, // <--- CLAVE PARA EL OVERFLOW
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        labelText: hint, 
        labelStyle: TextStyle(color: color, fontSize: 12),
        border: OutlineInputBorder(borderSide: BorderSide(color: color))
      ),
      items: list.map((p) => DropdownMenuItem(
        value: p, 
        child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))
      )).toList(),
      onChanged: onSelect,
    );
  }
}