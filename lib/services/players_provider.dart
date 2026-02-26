import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/player_model.dart';
import 'storage_service.dart';

enum SortType { nombre, promedio, totalStats }

class PlayersProvider extends ChangeNotifier {
  List<Player> _players = [];
  SortType _currentSort = SortType.nombre;
  SortType get currentSort => _currentSort;
  bool get ascending => _ascending;
  String _searchQuery = "";
  String get searchQuery => _searchQuery;
  String _selectedPosition = "Todas"; // Valor inicial
  String get selectedPosition => _selectedPosition;
  
  // Estas son las variables que faltaban:
  bool _ascending = true; 
  final StorageService _storage = StorageService();
  bool isLoading = true;

  List<Player> get fullPlayers => _players;

  List<Player> get players {
    List<Player> filteredList = _players.where((p) {
      bool matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesPosition = _selectedPosition == "Todas" || p.position == _selectedPosition;
      return matchesSearch && matchesPosition;
    }).toList();

    filteredList.sort((a, b) {
      int cmp;
      switch (_currentSort) {
        case SortType.nombre: 
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase()); 
          break;
        case SortType.promedio: 
          cmp = a.promedio.compareTo(b.promedio); 
          break;
        case SortType.totalStats: 
          cmp = a.totalStats.compareTo(b.totalStats); 
          break;
      }
      return _ascending ? cmp : -cmp;
    });
    return filteredList;
  }

  // Función para cambiar la posición
  void updatePositionFilter(String position) {
    _selectedPosition = position;
    notifyListeners();
  }

  void setPlayers(List<Player> newPlayers) {
    _players = newPlayers;
    notifyListeners();
  }

  void clearAllPlayers() {
    _players.clear();
    _save();
    notifyListeners();
  }

  // Función para actualizar la búsqueda
  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void changeSort(SortType type) {
    if (_currentSort == type) {
      _ascending = !_ascending;
    } else {
      _currentSort = type;
      _ascending = true;
    }
    notifyListeners();
  }

  // Cargar datos al iniciar
  Future<void> init() async {
    _players = await _storage.loadPlayers();
    isLoading = false;
    notifyListeners();
  }

  // Agregar Jugador (Create)
  void addPlayer(String name, String pos, String nac, double hei, String pref, Map<String, int> stats) {
    _players.add(Player(
      id: const Uuid().v4(),
      name: name,
      position: pos,
      nationality: nac,
      height: hei,
      preferredFoot: pref,
      vel: stats['vel']!, acc: stats['acc']!, fon: stats['fon']!,
      pot: stats['pot']!, con: stats['con']!, pas: stats['pas']!,
      dis: stats['dis']!, ent: stats['ent']!,
    ));
    _save();
  }

  // UPDATE
  void updatePlayer(Player updatedPlayer) {
    int index = _players.indexWhere((p) => p.id == updatedPlayer.id);
    if (index != -1) {
      _players[index] = updatedPlayer;
      _save();
    }
  }

  // DELETE
  void deletePlayer(String id) {
    _players.removeWhere((p) => p.id == id);
    _save();
  }

  // Guardar cambios y notificar a la UI
  void _save() {
    _storage.savePlayers(_players);
    notifyListeners();
  }
}