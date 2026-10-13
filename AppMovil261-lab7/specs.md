# Specifications Manifest (specs.md)

Este documento define las especificaciones técnicas y funcionales para las características clave de `appmovil261`. Sigue los principios de **Spec-Driven Development (SDD)** para asegurar que cada funcionalidad esté bien definida antes y durante su implementación.

---

## 1. Feature: Registro (Signup)

### Objetivo
Permitir a nuevos usuarios crear una cuenta en la aplicación utilizando su correo electrónico y una contraseña, integrándose con Supabase Auth.

### User Stories
- **Como** nuevo usuario, **quiero** registrarme con mi email y contraseña **para** poder acceder a las funcionalidades protegidas de la app.

### Requerimientos Funcionales
- **Entradas:** Correo electrónico (válido), Contraseña (mínimo 6 caracteres).
- **Acciones:** 
    - Validar formato de email.
    - Llamar al servicio de autenticación de Supabase.
    - Manejar estados de carga, éxito y error (ej. usuario ya existe).
- **Salidas:** Redirección a la pantalla de Inicio/Perfil en caso de éxito. Notificación (Snackbar) en caso de error.

### Acceptance Criteria
- [x] La UI tiene campos para Email y Password.
- [x] El botón "Registrar" dispara el `SignupBloc`.
- [x] Muestra un `CircularProgressIndicator` durante la carga.
- [x] Redirige a `/home` al completar con éxito.
- [x] Validación de campos en tiempo real (formato email, longitud password).

---

## 2. Feature: Login

### Objetivo
Permitir a usuarios existentes acceder a su cuenta mediante sus credenciales previamente registradas.

### User Stories
- **Como** usuario registrado, **quiero** iniciar sesión **para** retomar mi actividad en la aplicación.

### Requerimientos Funcionales
- **Entradas:** Correo electrónico y Contraseña.
- **Acciones:**
    - Verificar credenciales contra Supabase Auth.
    - Persistir la sesión del usuario.
- **Salidas:** Acceso a la pantalla de Perfil. Mensaje de error si las credenciales son incorrectas.

### Acceptance Criteria
- [x] Pantalla de Login dedicada.
- [x] BLoC para manejar el estado de autenticación de login.
- [x] Manejo de errores específicos (ej. "Invalid credentials").
- [x] Opción para navegar a la pantalla de Registro desde el Login.

---

## 3. Feature: MainScreen — Navegación Principal

### Objetivo
Pantalla principal post-login con `BottomNavigationBar` de 3 tabs: Perfil, Feed y Chat.

### Convención de nomenclatura
- `Screen` = página completa con scaffold/navegación propia.
- `Page` = sub-pantalla hosteada dentro de una Screen.

### Estructura de archivos
```
lib/core/navigation/
  main_screen.dart     # Scaffold con BottomNavigationBar (3 tabs)
lib/features/
  profile/ui/pages/profile_page.dart
  home/ui/pages/home_page.dart
  chat/ui/pages/conversations_page.dart
```

### User Stories
- **Como** usuario autenticado, **quiero** navegar entre secciones de la app **para** acceder a mis datos, el feed y chatear.

### Acceptance Criteria
- [x] `MainScreen` con `BottomNavigationBar` (Perfil / Feed / Chat).
- [x] Etiquetas visibles en ítems seleccionados y no seleccionados (`showUnselectedLabels: true`).
- [x] Colores explícitos: fondo blanco, seleccionado azul, no seleccionado gris.
- [x] Redirige a `/login` si no hay sesión activa al montar.

---

## 4. Feature: ProfilePage

### Objetivo
Mostrar los datos del perfil del usuario autenticado y permitirle cerrar sesión.

### Modelo `Profile`
```dart
class Profile {
  final String id;    // UID de Supabase Auth
  final String name;
  final String email;
}
```

### Estructura de archivos
```
lib/features/profile/
  domain/model/profile.dart
  domain/repository/profile_repository.dart
  data/source/profile_data_source.dart
  data/repository/profile_repository_impl.dart
  ui/bloc/profile_bloc.dart
  ui/pages/profile_page.dart
```

### Acceptance Criteria
- [x] `ProfilePage` muestra nombre y email del usuario actual.
- [x] Botón funcional de "Cerrar Sesión" (ProfileBloc + LogoutUsecase).
- [x] Navega a `/login` tras cerrar sesión.

---

## 5. Feature: Feed — Posts con Creación Modal

### Objetivo
Unificar el feed de posts y la creación de posts en una sola pantalla (`HomePage`). El tab "Feed" muestra la lista de posts por defecto; un FAB abre un modal para crear un nuevo post sin abandonar la pantalla.

### Relación de modelos
- `profiles` 1 ↔ N `posts` (columna `profile_id` en `posts` referencia `profiles.id` con `ON DELETE CASCADE`).

### Esquema Supabase (`posts`) — fuente de verdad
```sql
create table posts (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  content    text,
  created_at timestamp with time zone default now(),
  profile_id uuid references profiles(id) on delete cascade
);
```

### Modelo `Post` (dominio — sin nulleables)
```dart
class Post {
  final String id;          // UUID generado en el cliente
  final String title;
  final String content;
  final String profileId;   // FK → profiles.id
  final DateTime createdAt; // generado en el cliente con DateTime.now()
}
```

> **Regla:** el dominio no expone nulleables. El `id` y `createdAt` se generan en el cliente
> antes del insert, usando el paquete `uuid` y `DateTime.now()` respectivamente.
> `content` se valida como no vacío en el formulario aunque la columna DB admita null.

### Flujo de interacción
1. El usuario está en el tab **Feed** y ve la lista de posts.
2. Toca el **FAB (+)**.
3. Se abre un `ModalBottomSheet` con el formulario (título + contenido).
4. Al tocar "Publicar": el `PostBloc` crea el post en Supabase.
5. En `PostSuccessState`: el modal se cierra y el `PostsListBloc` recarga el feed automáticamente.

### Estructura de archivos
```
lib/features/post/
  domain/models/post.dart
  domain/repository/post_repository.dart
  domain/usecases/create_post_usecase.dart
  domain/usecases/fetch_posts_usecase.dart
  data/sources/post_data_source.dart
  data/repository/post_repository_impl.dart
  ui/bloc/post_bloc.dart
  ui/bloc/posts_list_bloc.dart
  ui/widgets/post_card.dart
lib/features/home/
  ui/pages/home_page.dart    # feed + FAB + modal _CreatePostModal
```

### Providers en `HomePage`
- `PostsListBloc` — instanciado en `_HomePageState`, vive mientras el tab está montado.
- `PostBloc` — creado dentro del `_CreatePostModal` (por `BlocProvider`), se descarta al cerrarse.
- El `_CreatePostModal` recibe `PostsListBloc` vía `BlocProvider.value` para poder recargar el feed al publicar.

### Acceptance Criteria
- [x] Modelo `Post` sin campos nulleables, con `toJson` / `fromJson`.
- [x] `toJson` serializa `createdAt` como ISO 8601 string para Supabase.
- [x] `PostDataSource.createPost` inserta con `id`, `profile_id` y `created_at` generados en cliente.
- [x] `PostDataSource.fetchAllPosts()` retorna `List<Post>` ordenada por `created_at DESC`.
- [x] `PostsListBloc` gestiona estados `PostsListLoadingState`, `PostsListLoadedState`, `PostsListErrorState`.
- [x] `PostBloc` gestiona estados `PostLoadingState`, `PostSuccessState`, `PostErrorState`.
- [x] `HomePage` muestra un `ListView` de `PostCard` con título, contenido y fecha.
- [x] FAB abre `ModalBottomSheet` (`isScrollControlled: true`) con el formulario.
- [x] El modal se ajusta al teclado vía `MediaQuery.of(context).viewInsets.bottom`.
- [x] En `PostSuccessState`: el modal se cierra y el feed se recarga.
- [x] Si la lista está vacía se muestra "No hay posts aún".
- [x] Sin paginación en esta iteración.

---

## 7. Feature: Chat en Tiempo Real

### Objetivo
Permitir a los usuarios autenticados iniciar y mantener conversaciones 1-a-1 en tiempo real. El tab "Chat" muestra la lista de todos los usuarios registrados; al tocar uno se abre (o crea) la conversación y se navega a `ChatPage`.

### Esquema Supabase — fuente de verdad
```sql
create table profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text not null,
  email      text not null,
  created_at timestamp with time zone default now()
);

create table conversations (
  id          uuid primary key default gen_random_uuid(),
  profile1_id uuid references profiles(id) on delete cascade,
  profile2_id uuid references profiles(id) on delete cascade,
  created_at  timestamp with time zone default now()
);

create table messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid references conversations(id) on delete cascade,
  sender_id       uuid references profiles(id) on delete cascade,
  content         text not null,
  created_at      timestamp with time zone default now()
);
```

### Modelos de dominio
```dart
// Reutiliza Profile de lib/features/profile/domain/model/profile.dart

class Conversation {
  final String id;
  final String profile1Id;
  final String profile2Id;
  final DateTime createdAt;
  final String? otherUserName;
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
}
```

### Flujo de interacción
1. El usuario entra al tab **Chat** → `UsersBloc` carga todos los perfiles excepto el suyo.
2. Ve la lista de usuarios con nombre e inicial en avatar.
3. Toca un usuario → se llama `GetOrCreateConversationUsecase(currentUserId, otherUserId)`.
4. Si la conversación ya existe, la retorna; si no, la crea en Supabase.
5. Se navega a `ChatPage(conversationId, otherUserName)`.
6. `ChatPage` suscribe en realtime los mensajes y permite enviar nuevos.

### Estructura de archivos
```
lib/features/chat/
  domain/models/conversation.dart
  domain/models/message.dart
  domain/repository/chat_repository.dart          # +getProfiles
  domain/usecases/get_profiles_usecase.dart        # NUEVO
  domain/usecases/get_or_create_conversation_usecase.dart
  domain/usecases/send_message_usecase.dart
  domain/usecases/watch_messages_usecase.dart
  data/sources/chat_data_source.dart               # +getProfiles
  data/repository/chat_repository_impl.dart        # +getProfiles
  ui/bloc/users_bloc.dart                          # NUEVO — lista usuarios
  ui/bloc/chat_bloc.dart
  ui/pages/conversations_page.dart                 # reescrito — lista usuarios
  ui/pages/chat_page.dart
```

### Acceptance Criteria
- [x] `ChatDataSource.getProfiles(currentUserId)` retorna todos los perfiles excepto el propio, ordenados por nombre.
- [x] `GetProfilesUsecase` encapsula la llamada al repositorio.
- [x] `UsersBloc` gestiona estados `UsersLoadingState`, `UsersLoadedState(List<Profile>)`, `UsersErrorState`.
- [x] `ConversationsPage` muestra lista de usuarios con avatar (inicial del nombre) y nombre completo.
- [x] Al tocar un usuario se llama `GetOrCreateConversationUsecase` y se navega a `ChatPage`.
- [x] `GetOrCreateConversationUsecase` busca conversación en ambas direcciones antes de crear una nueva.
- [x] `ChatPage` se suscribe a mensajes en tiempo real con `watchMessages(conversationId)`.
- [x] `ChatBloc` gestiona estados `ChatLoadingState`, `ChatLoadedState`, `ChatErrorState`.
- [x] Mensajes propios alineados a la derecha (color primario); ajenos a la izquierda.
- [x] Envío de mensaje limpia el `TextField`.

---

## Manifest de Implementación

| Feature | Sub-tarea | Estado | Notas |
| :--- | :--- | :---: | :--- |
| **Registro** | UI (SignupScreen) | ✅ | Funcional con campos básicos. |
| | Lógica (SignupBloc) | ✅ | Integrado con Usecase. |
| | Integración Supabase | ✅ | `AuthRepoImpl` usa `AuthDataSource`. |
| | Validaciones de Formulario | ✅ | `Form` + `TextFormField` con `AutovalidateMode.onUserInteraction`. |
| **Login** | UI (LoginScreen) | ✅ | Pantalla creada con navegación a Signup. |
| | Lógica (LoginBloc) | ✅ | Implementada con manejo de estados. |
| | Usecase (LoginUsecase) | ✅ | Implementado y conectado al Repo. |
| **MainScreen** | BottomNavigationBar (3 tabs) | ✅ | Perfil / Feed / Chat. |
| | Etiquetas visibles en todos los tabs | ✅ | `showUnselectedLabels: true`. |
| | Colores explícitos | ✅ | Fondo blanco, seleccionado azul, no seleccionado gris. |
| | Guard de sesión | ✅ | Redirige a `/login` si no hay sesión. |
| **ProfilePage** | Datos del usuario (nombre, email) | ✅ | Desde Supabase `profiles`. |
| | Logout | ✅ | ProfileBloc + LogoutUsecase; navega a `/login`. |
| **Feed — Posts con Creación Modal** | Modelo Post | ✅ | Sin nulleables; id y createdAt generados en cliente. |
| | PostDataSource.createPost | ✅ | Insert con id/createdAt del cliente y profile_id. |
| | PostDataSource.fetchAllPosts | ✅ | SELECT * ORDER BY created_at DESC. |
| | PostRepository + Impl | ✅ | Implementado. |
| | CreatePostUsecase / FetchPostsUsecase | ✅ | Implementados. |
| | PostBloc (create) | ✅ | Estados: Loading/Success/Error. |
| | PostsListBloc (feed) | ✅ | Estados: Loading/Loaded/Error. |
| | PostCard widget | ✅ | Muestra title, content, fecha local. |
| | HomePage con ListView + FAB | ✅ | Feed sin paginación; FAB abre modal. |
| | _CreatePostModal (ModalBottomSheet) | ✅ | Formulario en modal; cierra y recarga feed al publicar. |
| **Chat en Tiempo Real** | Modelos Conversation y Message | ✅ | Con `fromJson`/`toJson`. |
| | ChatDataSource.getProfiles | ✅ | Todos los perfiles excepto el propio, ordenados por nombre. |
| | ChatDataSource (resto) | ✅ | getOrCreateConversation, sendMessage, watchMessages. |
| | ChatRepository + Impl | ✅ | Incluye getProfiles. |
| | GetProfilesUsecase | ✅ | Implementado. |
| | GetOrCreateConversationUsecase | ✅ | Evita duplicados buscando en ambas direcciones. |
| | SendMessageUsecase | ✅ | Implementado. |
| | WatchMessagesUsecase | ✅ | Stream en tiempo real via Supabase. |
| | UsersBloc | ✅ | Estados: Loading/Loaded/Error con List<Profile>. |
| | ConversationsPage | ✅ | Lista usuarios; toca → getOrCreate → navega a ChatPage. |
| | ChatBloc | ✅ | Suscripción realtime; estados: Loading/Loaded/Error. |
| | ChatPage | ✅ | Mensajes diferenciados por alineación y color; barra de envío. |

---
*Última actualización: 4 de Mayo, 2026*
