# StatsPRO v2 ⚽📊

**StatsPRO v2** es una aplicación multiplataforma desarrollada con Flutter diseñada para el análisis, gestión y comparación detallada de estadísticas de jugadores de fútbol. Inspirada principalmente el juego DLS (Dream Ligue Soccer).

---

## ✨ Características Principales

- **Gestión Completa de Jugadores (CRUD):** Crea, edita y elimina perfiles de jugadores con información detallada.
- **Estadísticas Técnicas y Físicas:** Control de 8 métricas clave (Velocidad, Aceleración, Fondo, Potencia, Control, Pase, Disparo y Entrada) en una escala de 0 a 100.
- **Visualización mediante Gráficos de Radar:** Perfiles de rendimiento visuales generados dinámicamente con la librería `fl_chart`.
- **Sistema de Niveles por Color:** Clasificación automática basada en el total de estadísticas:
  - 🟠 **Élite (Dorado):** +740 puntos.
  - 🔵 **Destacado (Azul):** +725 puntos.
  - 🟢 **Promesa (Verde):** +715 puntos.
  - ⚪ **Estándar (Gris):** <715 puntos.
- **Búsqueda y Filtros Avanzados:** Filtra por posición (DFC, MC, DC, etc.) y busca por nombre en tiempo real.
- **Ordenamiento Inteligente:** Clasifica tu lista por nombre, promedio de stats o puntuación total.
- **Comparativa Avanzada:** Herramienta dedicada para comparar dos jugadores frente a frente, visualizando sus diferencias en el gráfico de radar y tablas de datos.
- **Persistencia y Portabilidad:** 
  - Almacenamiento local automático en formato JSON.
  - Exportación e importación de bases de datos para copias de seguridad o transferencia entre dispositivos.

---

## 🚀 Tecnologías Utilizadas

- **[Flutter](https://flutter.dev/):** Framework principal para el desarrollo multiplataforma.
- **[Provider](https://pub.dev/packages/provider):** Gestión del estado de la aplicación.
- **[FL Chart](https://pub.dev/packages/fl_chart):** Renderizado de gráficos estadísticos complejos.
- **[Path Provider](https://pub.dev/packages/path_provider) & [Path](https://pub.dev/packages/path):** Manejo del sistema de archivos local.
- **[UUID](https://pub.dev/packages/uuid):** Generación de identificadores únicos para los jugadores.
- **[Share Plus](https://pub.dev/packages/share_plus):** Funcionalidad para compartir archivos de backup.
- **[File Picker](https://pub.dev/packages/file_picker):** Selección de archivos para la importación de datos.

---

## 📂 Estructura del Proyecto

```text
lib/
├── main.dart                 # Punto de entrada y configuración de Providers
├── models/
│   └── player_model.dart     # Modelo de datos del jugador y lógica de colores
├── services/
│   ├── players_provider.dart # Lógica de negocio, filtrado y ordenamiento
│   └── storage_service.dart  # Persistencia de datos en JSON
└── views/
    ├── compare_view.dart     # Vista de comparación entre dos jugadores
    └── settings_view.dart    # Gestión de datos (Exportar/Importar/Borrar)
```

---

## 🛠️ Instalación y Configuración

### Requisitos Previos
- Flutter SDK (v3.11.0 o superior)
- Dart SDK
- Un emulador o dispositivo físico (Android/iOS/Windows)

### Pasos
1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/George71004/StatsPRO.git
   cd statsprov2
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

4. **(Opcional) Generar iconos de la app:**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

---

## 📖 Uso

1. **Crear:** Ve a la pestaña "Crear", ingresa los datos del jugador y ajusta los Sliders para definir sus estadísticas.
2. **Listado:** En la pantalla principal, usa la barra de búsqueda o el filtro de posición para encontrar jugadores. Puedes editar o eliminar directamente desde la lista.
3. **Comparar:** Selecciona dos jugadores de los menús desplegables en la sección "Comparar" para ver el gráfico comparativo.
4. **Backup:** Desde "Ajustes", puedes exportar tu base de datos actual a un archivo `.json` o importar uno existente.

---

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Si tienes ideas para mejorar los algoritmos de comparación o añadir nuevas métricas:
1. Haz un Fork del proyecto.
2. Crea una rama para tu funcionalidad (`git checkout -b feature/NuevaMejora`).
3. Haz commit de tus cambios (`git commit -m 'Añade nueva funcionalidad'`).
4. Haz Push a la rama (`git push origin feature/NuevaMejora`).
5. Abre un Pull Request.

