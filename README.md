# StatsPRO v2 ⚽📊

**StatsPRO** es una aplicación móvil desarrollada con Flutter diseñada para el análisis y comparación de estadísticas de jugadores. Permite a los usuarios gestionar su propia base de datos local, visualizar el rendimiento mediante gráficos de radar y realizar comparativas detalladas entre dos atletas.



## ✨ Características

- **Gestión de Jugadores:** Crea, edita y elimina jugadores con estadísticas personalizadas (Velocidad, Aceleración, Potencia, etc.).
- **Gráficos de Radar:** Visualización intuitiva del perfil del jugador utilizando la librería `fl_chart`.
- **Comparativa Avanzada:** Selecciona dos jugadores y visualiza sus diferencias tanto gráficamente como en una tabla detallada.
- **Persistencia de Datos:** Los datos se guardan localmente en el dispositivo en formato JSON (compatible con Android, iOS y Escritorio).
- **Importar/Exportar:** Sistema de backup para mover tus datos entre dispositivos mediante archivos `.json`.
- **Diseño Adaptativo:** Interfaz optimizada para móviles para evitar desbordamientos y asegurar una buena experiencia de usuario.

## 🚀 Tecnologías Utilizadas

* [Flutter](https://flutter.dev/) - Framework de UI.
* [Provider](https://pub.dev/packages/provider) - Gestión de estado.
* [FL Chart](https://pub.dev/packages/fl_chart) - Gráficos de radar dinámicos.
* [Path Provider](https://pub.dev/packages/path_provider) - Acceso al sistema de archivos.
* [Share Plus](https://pub.dev/packages/share_plus) - Compartir backups.
* [File Picker](https://pub.dev/packages/file_picker) - Selector de archivos para importación.

## 🛠️ Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/tu-usuario/statsprov2.git](https://github.com/tu-usuario/statsprov2.git)