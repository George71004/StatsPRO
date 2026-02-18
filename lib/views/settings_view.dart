import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/players_provider.dart';
import '../models/player_model.dart';
import 'package:share_plus/share_plus.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  // --- EXPORTAR ---
  Future<void> _exportData(BuildContext context, List<Player> players) async {
    try {
      final String jsonString = jsonEncode(players.map((p) => p.toMap()).toList());
      
      // 1. Obtener directorio (funciona en ambos)
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/jugadores_backup.json');
      
      // 2. Escribir el archivo
      await file.writeAsString(jsonString, flush: true);

      if (!context.mounted) return;

      // 3. Diferenciar comportamiento por plataforma
      if (Platform.isAndroid || Platform.isIOS) {
        // EN MÓVIL: Abrimos el menú de compartir usando SharePlus.instance.share() con ShareParams
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'Backup de mis jugadores StatsPRO',
            subject: 'Backup de mis jugadores StatsPRO',
          ),
        );
      } else {
        // EN ESCRITORIO: Solo mostramos la ruta (como ya hacías)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Exportado en: ${file.path}")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al exportar")),
        );
      }
    }
  }

  // --- IMPORTAR ---
 Future<void> _importData(BuildContext context, PlayersProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        // En escritorio/móvil es mejor no usar withData: true a menos que sea necesario 
        // para ahorrar memoria, pero en Web es obligatorio.
      );

      if (result != null) {
        String content;

        // CONDICIONAL DE LECTURA
        if (kIsWeb) {
          // Si algún día lo llevas a Web
          content = utf8.decode(result.files.single.bytes!);
        } else {
          // MÓVIL Y ESCRITORIO
          final file = File(result.files.single.path!);
          content = await file.readAsString();
        }

        final List<dynamic> jsonData = jsonDecode(content);
        final List<Player> importedPlayers = jsonData.map((p) => Player.fromMap(p)).toList();

        // Actualizar el provider
        provider.setPlayers(importedPlayers);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Importación exitosa!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al importar: Archivo no válido")),
      );
    }
  }

  // --- ELIMINAR Todo ---
  void _deleteAll(BuildContext context, PlayersProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar todos los datos?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              provider.clearAllPlayers();
              Navigator.pop(ctx);
            }, 
            child: const Text("Eliminar", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayersProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Icon(Icons.settings, size: 80, color: Colors.grey),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Color.fromARGB(255, 233, 233, 233)),
            title: const Text("Exportar Jugadores (JSON)"),
            onTap: () => _exportData(context, provider.players),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Color.fromARGB(255, 233, 233, 233)),
            title: const Text("Importar Jugadores (JSON)"),
            onTap: () => _importData(context, provider),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Color.fromARGB(255, 233, 233, 233)),
            title: const Text("Eliminar todos los datos"),
            onTap: () => _deleteAll(context, provider),
          ),
        ],
      ),
    );
  }
}