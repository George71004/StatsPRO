import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/player_model.dart';

class StorageService {
  Future<String> _getFilePath() async {
    // Esto crea la carpeta 'data' en el directorio de la aplicación
    Directory directory;

    if (Platform.isAndroid || Platform.isIOS) {
      // EN MÓVILES: Usamos la carpeta segura del sistema
      directory = await getApplicationDocumentsDirectory();
    } else {
      // EN ESCRITORIO: Puedes seguir usando tu carpeta 'data' local
      directory = Directory(p.join(Directory.current.path, 'data'));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }

    return p.join(directory.path, 'players_database.json');
  }

  Future<void> savePlayers(List<Player> players) async {
    final path = await _getFilePath();
    final file = File(path);
    // Convertimos la lista de objetos a lista de mapas y luego a texto JSON
    String jsonString = jsonEncode(players.map((p) => p.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<List<Player>> loadPlayers() async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      if (!await file.exists()) return [];

      String jsonString = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Player.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}