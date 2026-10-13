# Laboratorio 4 — Deezer Ain't the Best Option

Aplicación Flutter para buscar canciones reales en Deezer y guardar canciones favoritas en Firebase Realtime Database. La interfaz funciona en Chrome y se adapta también a pantallas móviles.

## Tecnologías

- Flutter y Dart
- Material Design 3
- `flutter_bloc` para manejo de estado
- `http` para las peticiones REST
- API proxy de Deezer suministrada por el profesor
- Firebase Realtime Database mediante su API REST

## Arquitectura

El proyecto aplica Clean Architecture con inyección por constructores:

```text
UI → BLoC → UseCase → MusicRepository → MusicRepositoryImpl → DataSource → API
```

La UI solamente envía eventos y representa estados. `SearchBloc` y `LikedBloc` utilizan una clase de estado única, un enum de estado y `copyWith`. Los casos de uso dependen del contrato `MusicRepository`; únicamente `DeezerDataSource` y `LikesDataSource` realizan solicitudes HTTP.

## Estructura principal

```text
lib/
  main.dart
  features/search/
    domain/
      models/track.dart
      repository/music_repository.dart
      usecases/
    data/
      sources/deezer_data_source.dart
      sources/likes_data_source.dart
      repository/music_repository_impl.dart
    ui/
      bloc/search_bloc.dart
      bloc/liked_bloc.dart
      screens/search_screen.dart
      screens/liked_songs_screen.dart
      widgets/track_tile.dart
```

## Cómo ejecutar

Requisitos: Flutter instalado y Chrome disponible.

```bash
flutter pub get
flutter run -d chrome
```

Para revisar el proyecto:

```bash
flutter analyze
flutter test
```

## Uso

1. Escribe un artista o canción, por ejemplo `Queen` o `Bohemian Rhapsody`.
2. Presiona **Buscar** o Enter. Se mostrarán carátula, título y artista.
3. Presiona el corazón vacío para guardarla en Firebase. El corazón relleno permite quitarla y la aplicación muestra una confirmación o el error real recibido.
4. Presiona el corazón del AppBar para abrir **Mis canciones favoritas**.
5. Usa el botón de actualizar para volver a consultar Firebase.

## Servicios configurados

- Deezer: `https://i2thub.icesi.edu.co:5443/deezer/search?q=...`
- Firebase: `https://facelogprueba.firebaseio.com/playlist/marianadelacruz06.json`

## Limitaciones conocidas

- La disponibilidad depende de la red, del proxy académico de Deezer y de las reglas de seguridad de la base Firebase compartida.
- Firebase genera una clave por cada `POST`. La aplicación evita duplicados por ID de Deezer dentro de la sesión, agrupa duplicados históricos al consultar y elimina todas sus claves al quitar la canción. Como el backend compartido usa `POST`, dos dispositivos concurrentes aún podrían crear duplicados; se deduplicarán en la siguiente consulta.
- No se implementan autenticación, eliminación ni reproducción de audio porque están fuera del alcance del laboratorio.
- En Flutter Web, los servidores externos deben permitir solicitudes CORS desde el origen de la aplicación.
