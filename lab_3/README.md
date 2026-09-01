# icesi_beats

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Reflexión

Cada vez que Flutter reconstruye un widget se vuelve a ejecutar el método build().
El TextEditingController estaba creado dentro de build(), por eso también se creaba otra vez.
En el Paso 2, al seleccionar un mood usamos setState(), lo que reconstruía la página.
Por eso el campo del artista perdía el texto que ya habíamos escrito.
En Login y Paso 1 no ocurría porque no había un setState() que reconstruyera esos campos mientras escribíamos.
Un campo que necesita conservar un controller puede usar StatefulWidget para mantener ese estado.
El controller se crea en el State y así sobrevive a las reconstrucciones de build().
Finalmente usamos dispose() para liberar el controller cuando el widget deja de existir.