import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './services/players_provider.dart';
import './models/player_model.dart';
import './views/compare_view.dart';
import './views/settings_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PlayersProvider()..init())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fútbol Stats PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, brightness: Brightness.dark),
      home: const HomeScreen(),
    );
  }
}

// --- VISTA DE LISTA ---
class PlayersListView extends StatelessWidget {
  const PlayersListView({super.key});

  void _showEditDialog(BuildContext context, Player player) {
    // Inicializamos los controladores con los datos actuales del jugador
    final nameController = TextEditingController(text: player.name);
    String editPos = player.position;
    
    // Cargamos las estadísticas actuales
    Map<String, int> editStats = {
      'vel': player.vel, 'acc': player.acc, 'fon': player.fon, 'pot': player.pot,
      'con': player.con, 'pas': player.pas, 'dis': player.dis, 'ent': player.ent,
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Necesario para que los Sliders funcionen en el diálogo
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Editando a ${player.name}"),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Nombre"),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        items: positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (val) => setDialogState(() => editPos = val!),
                        decoration: const InputDecoration(labelText: "Posición"),
                      ),
                      const Divider(height: 30),
                      ...editStats.keys.map((key) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${key.toUpperCase()}: ${editStats[key]}", style: const TextStyle(fontSize: 11)),
                            Slider(
                              value: editStats[key]!.toDouble(),
                              min: 0, max: 100,
                              divisions: 100,
                              onChanged: (val) => setDialogState(() => editStats[key] = val.toInt()),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      // Creamos el objeto actualizado
                      final updatedPlayer = Player(
                        id: player.id, // Mantenemos el mismo ID
                        name: nameController.text,
                        position: editPos,
                        vel: editStats['vel']!, acc: editStats['acc']!,
                        fon: editStats['fon']!, pot: editStats['pot']!,
                        con: editStats['con']!, pas: editStats['pas']!,
                        dis: editStats['dis']!, ent: editStats['ent']!,
                      );

                      // Llamamos al provider para actualizar y guardar
                      Provider.of<PlayersProvider>(context, listen: false)
                          .updatePlayer(updatedPlayer);
                      
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Guardar Cambios"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayersProvider>(context);
    final List<String> filterPositions = ["Todas", "POR", "DFC", "MC", "DC", "ED", "EI", "MCD", "MCO", "SD", "CAI", "CAD"];

    return Column(
      children: [
          // --- BARRA DE BÚSQUEDA ---
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            onChanged: (value) => provider.updateSearch(value),
            decoration: InputDecoration(
              hintText: "Buscar jugador...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.searchQuery.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => provider.updateSearch(""), // Limpia la búsqueda
                  )
                : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Wrap(
            spacing: 8.0,    // Espacio horizontal entre chips
            runSpacing: 10.0, // Espacio vertical cuando saltan de fila <--- ESTO ES LA CLAVE
            alignment: WrapAlignment.start, // Alineación al inicio
            children: filterPositions.map((pos) {
              bool isSelected = provider.selectedPosition == pos;
              return ChoiceChip(
                label: Text(pos),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) provider.updatePositionFilter(pos);
                },
                selectedColor: Colors.greenAccent.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.greenAccent : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(), // Separador visual entre filtro de posición y ordenamiento
        // --- FILTROS DE ORDENAMIENTO (Nombre, Promedio, Total) ---
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0), // <--- ESTO crea el espacio abajo
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterBtn(context, "Nombre", SortType.nombre, provider),
                _filterBtn(context, "Promedio", SortType.promedio, provider),
                _filterBtn(context, "Total Stats", SortType.totalStats, provider),
              ],
            ),
          ),
        ),
        Expanded(
          child: provider.players.isEmpty 
            ? const Center(child: Text("No hay jugadores"))
            : ListView.builder(
                itemCount: provider.players.length,
                itemBuilder: (ctx, i) {
                  final p = provider.players[i];
                  final Color levelColor = p.getPlayerColor(p.totalStats);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide.none, // Borde del color según nivel
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: levelColor,
                        child: Text(p.position, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Promedio: ${p.promedio}, Total stats: ${p.totalStats}", style: TextStyle(color: Colors.white)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color.fromARGB(255, 233, 233, 233)), 
                            onPressed: () => _showEditDialog(context, p)
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 233, 233, 233)), 
                            onPressed: () => provider.deletePlayer(p.id)
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _filterBtn(BuildContext context, String label, SortType type, PlayersProvider provider) {
    // Verificamos si este es el filtro que está activo actualmente
    bool isActive = provider.currentSort == type;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        avatar: isActive 
          ? Icon(
              provider.ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: Colors.greenAccent,
            ) 
          : null,
        label: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.greenAccent : Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: isActive ? Colors.green.withValues(alpha: 0.2) : null,
        onPressed: () => provider.changeSort(type),
      ),
    );
  }
}

// --- VISTA DE CREACIÓN ---
final List<String> positions = [
  'DFC', 'LD', 'LI', 'MI', 'MD', 'SD', 'DC', 'ED', 'EI', 'MC', 'MCO', 'MCD', 'POR', 'CAI', 'CAD'
];

class CreatePlayerView extends StatefulWidget {
  const CreatePlayerView({super.key});

  @override
  State<CreatePlayerView> createState() => _CreatePlayerViewState();
}

class _CreatePlayerViewState extends State<CreatePlayerView> {
  final nameController = TextEditingController();
  String selectedPos = 'MC'; // Movido aquí para que sea parte del estado
  
  Map<String, int> stats = {
    'vel': 50, 'acc': 50, 'fon': 50, 'pot': 50,
    'con': 50, 'pas': 50, 'dis': 50, 'ent': 50,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre del Jugador",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Posición", border: OutlineInputBorder()),
              items: positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => selectedPos = val!),
            ),
            const SizedBox(height: 20),
            const Text("Estadísticas (0-100)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...stats.keys.map((key) {
              return Row(
                children: [
                  SizedBox(width: 40, child: Text(key.toUpperCase(), style: const TextStyle(fontSize: 12))),
                  Expanded(
                    child: Slider(
                      value: stats[key]!.toDouble(),
                      min: 0, max: 100,
                      divisions: 100,
                      onChanged: (v) => setState(() => stats[key] = v.toInt()),
                    ),
                  ),
                  SizedBox(width: 30, child: Text("${stats[key]}")),
                ],
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green[700]
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // ORDEN CORRECTO: Nombre, Posición, Stats
                  Provider.of<PlayersProvider>(context, listen: false)
                      .addPlayer(nameController.text, selectedPos, stats);
                  
                  nameController.clear();
                  setState(() => selectedPos = 'MC');
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jugador Guardado Exitosamente")),
                  );
                }
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("GUARDAR JUGADOR", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PlayersListView(),
    const CompareView(),
    const CreatePlayerView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("StatsPRO"),
        centerTitle: true,
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.groups), label: 'Jugadores'),
          NavigationDestination(icon: Icon(Icons.compare), label: 'Comparar'),
          NavigationDestination(icon: Icon(Icons.person_add), label: 'Crear'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}