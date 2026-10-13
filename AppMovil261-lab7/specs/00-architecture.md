# Spec 00 — Arquitectura: Clean Architecture

## Objetivo

Definir las responsabilidades de cada capa del proyecto `appmovil261` bajo los principios de **Clean Architecture**, asegurando separación de concerns, testeabilidad y mantenibilidad.

---

## Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| UI / State | Flutter + flutter_bloc |
| Backend / Auth / Realtime | Supabase (supabase_flutter) |
| Routing | MaterialApp named routes |
| Generación de IDs | paquete `uuid` |

---

## Estructura de Capas

```
lib/
├── core/
│   ├── navigation/    # Scaffolds globales (MainScreen)
│   └── widgets/       # Widgets reutilizables transversales
└── features/
    └── <feature>/
        ├── domain/
        │   ├── models/        # Entidades puras de dominio
        │   ├── repository/    # Contratos abstractos (interfaces)
        │   └── usecases/      # Casos de uso (1 acción = 1 clase)
        ├── data/
        │   ├── sources/       # Acceso directo a Supabase / APIs externas
        │   └── repository/    # Implementaciones concretas de los contratos
        └── ui/
            ├── bloc/          # BLoC: eventos, estados, lógica de presentación
            ├── screens/       # Pantallas completas con Scaffold propio
            ├── pages/         # Sub-pantallas hosteadas dentro de una Screen
            └── widgets/       # Widgets específicos de la feature
```

---

## Responsabilidades por Capa

### Domain — Núcleo independiente

**No depende de ninguna otra capa ni de Flutter/Supabase.**

| Artefacto | Responsabilidad |
|-----------|----------------|
| `models/` | Entidades de negocio. Sin nulleables. Sin dependencias externas. Solo Dart puro. |
| `repository/` | Contratos abstractos (`abstract class`). Define QUÉ se puede hacer, no cómo. |
| `usecases/` | Una clase por acción de negocio. Depende del contrato del repositorio, nunca de la implementación. |

**Reglas:**
- Los modelos de dominio no tienen campos nulleables. Los valores opcionales se expresan con valores por defecto.
- Los `id` y `createdAt` se generan en el cliente (uuid + DateTime.now()), no en la BD.
- Los usecases tienen un solo método público (`call` o `execute`).

---

### Data — Adaptadores de infraestructura

**Depende de Domain (implementa sus contratos). No depende de UI.**

| Artefacto | Responsabilidad |
|-----------|----------------|
| `sources/` | Llamadas directas a Supabase (insert, select, realtime). Devuelve tipos de Supabase o mapea a modelos de dominio. |
| `repository/impl` | Implementa el contrato abstracto del dominio. Delega a la DataSource. Convierte errores en excepciones tipadas del dominio. |

**Reglas:**
- Las `DataSource` solo conocen Supabase; no exponen tipos de Supabase hacia afuera: mapean a modelos de dominio antes de retornar.
- Los `RepositoryImpl` instancian su `DataSource` directamente (sin parámetros de constructor).
- No hay lógica de negocio en esta capa, solo traducción de datos.

---

### UI — Presentación y estado

**Depende de Domain (usecases). No depende de Data.**

| Artefacto | Responsabilidad |
|-----------|----------------|
| `bloc/` | Recibe eventos de la UI. Llama al usecase correspondiente. Emite estados. Instancia el usecase y el repositoryImpl directamente. |
| `screens/` | Pantalla completa con su propio `Scaffold`. Registrada como ruta en `MaterialApp`. |
| `pages/` | Sub-pantalla sin Scaffold propio, hosteada dentro de una Screen (ej. tabs de MainScreen). |
| `widgets/` | Componentes visuales reutilizables dentro de la feature. Sin lógica de negocio. |

**Reglas:**
- El BLoC instancia sus dependencias directamente: `UseCase()` → `RepositoryImpl()` → `DataSource()`.
- Los BLoCs **no** se pasan entre pantallas; se proveen con `BlocProvider` en el árbol de widgets.
- Para compartir un BLoC entre widgets se usa `BlocProvider.value`.
- `Screen` = página con Scaffold/navegación propia. `Page` = sub-pantalla dentro de una Screen.

---

## Flujo de Datos (Request/Response)

```
UI Event
  └─► BLoC
        └─► UseCase.execute()
              └─► RepositoryImpl.método()
                    └─► DataSource.llamadaSupabase()
                          └─► Supabase SDK
                                └─► [respuesta]
                          ◄── Map a modelo de dominio
                    ◄── modelo de dominio
              ◄── modelo de dominio
        ◄── emite Estado (Loading / Success / Error)
  ◄── BlocBuilder reconstruye UI
```

---

## Convenciones de Nomenclatura

| Concepto | Convención | Ejemplo |
|---------|------------|---------|
| Feature folder | snake_case | `features/post/` |
| Modelo | PascalCase | `Post`, `Profile`, `Message` |
| Repositorio abstracto | `<Entity>Repository` | `PostRepository` |
| Implementación | `<Entity>RepositoryImpl` | `PostRepositoryImpl` |
| Data source | `<Entity>DataSource` | `PostDataSource` |
| UseCase | `<Verbo><Entity>Usecase` | `CreatePostUsecase`, `FetchPostsUsecase` |
| BLoC | `<Feature>Bloc` | `PostBloc`, `PostsListBloc` |
| Screen (ruta propia) | `<Feature>Screen` | `LoginScreen`, `SignupScreen` |
| Page (tab/sub-pantalla) | `<Feature>Page` | `HomePage`, `ProfilePage`, `ChatPage` |

---

## Routing

Las rutas se registran en `main.dart` dentro de `MaterialApp.routes`. Cada ruta envuelve su Screen con un `BlocProvider`.

| Ruta | Widget | BLoC proveído |
|------|--------|--------------|
| `/login` | `LoginScreen` | `LoginBloc` |
| `/signup` | `SignupScreen` | `SignupBloc` |
| `/home` | `MainScreen` | `ProfileBloc` |

---

## Manifest de Tareas

| Tarea | Estado | Notas |
|-------|:------:|-------|
| Definir estructura de carpetas por feature | ✅ | Aplicada en auth, profile, post, chat |
| Separar Domain de Data en todas las features | ✅ | Contratos abstractos en `domain/repository/` |
| Eliminar dependencias de Supabase en Domain | ✅ | Domain es Dart puro |
| Instanciación directa BLoC→Usecase→RepoImpl→DataSource | ✅ | Sin DI framework |
| Routing centralizado en main.dart | ✅ | Named routes con BlocProvider |
| Convención Screen vs Page documentada | ✅ | Ver spec-03 MainScreen |
| Documentar flujo de datos completo | ✅ | Diagrama en este spec |
