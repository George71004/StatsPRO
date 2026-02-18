import 'package:flutter/material.dart';

class Player {
  final String id;
  String name;
  String position; // Nueva propiedad
  int vel, acc, fon, pot, con, pas, dis, ent;

  Color getPlayerColor(int totalStats) {
    if (totalStats >= 740) return const Color.fromARGB(255, 255, 139, 7); // Dorado
    if (totalStats >= 725) return Colors.blueAccent; // Azul
    if (totalStats >= 715) return Colors.greenAccent; // Verde
  return Colors.grey; // Gris
  }

  Player({
    required this.id,
    required this.name,
    required this.position,
    this.vel = 50, this.acc = 50, this.fon = 50, this.pot = 50,
    this.con = 50, this.pas = 50, this.dis = 50, this.ent = 50,
  });

  int get totalStats => vel + acc + fon + pot + con + pas + dis + ent;
  int get promedio => (totalStats / 8).round();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'position': position,
    'vel': vel, 'acc': acc, 'fon': fon, 'pot': pot,
    'con': con, 'pas': pas, 'dis': dis, 'ent': ent,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      position: json['position'] ?? 'MC',
      vel: json['vel'], acc: json['acc'], fon: json['fon'], pot: json['pot'],
      con: json['con'], pas: json['pas'], dis: json['dis'], ent: json['ent'],
    );
  }

  // Convertir Mapa a Objeto (Para IMPORTAR)
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      position: map['position'],
      vel: map['vel'], acc: map['acc'], fon: map['fon'], 
      pot: map['pot'], con: map['con'], pas: map['pas'], 
      dis: map['dis'], ent: map['ent'],
    );
  }

  // Convertir Objeto a Mapa (Para EXPORTAR)
  Map<String, dynamic> toMap() {
    return {
      'id': id, 'name': name, 'position': position,
      'vel': vel, 'acc': acc, 'fon': fon, 'pot': pot,
      'con': con, 'pas': pas, 'dis': dis, 'ent': ent,
    };
  }
}