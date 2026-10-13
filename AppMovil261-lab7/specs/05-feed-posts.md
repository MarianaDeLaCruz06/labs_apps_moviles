# Spec 05 — Feature: Feed — Posts con Creación Modal

## Objetivo

Unificar el feed de posts y la creación de posts en `HomePage`. El tab "Feed" muestra la lista de posts por defecto; un FAB abre un `ModalBottomSheet` para crear un nuevo post sin abandonar la pantalla.

---

## User Stories

- **Como** usuario autenticado, **quiero** ver todos los posts publicados **para** estar al día con la comunidad.
- **Como** usuario autenticado, **quiero** crear un post desde un modal **para** publicar sin perder el contexto del feed.

---

## Relación de Modelos

`profiles` 1 ↔ N `posts` (columna `profile_id` en `posts` referencia `profiles.id` con `ON DELETE CASCADE`).

---

## Esquema Supabase

```sql
create table posts (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  content    text,
  created_at timestamp with time zone default now(),
  profile_id uuid references profiles(id) on delete cascade
);
```

---

## Modelo de Dominio

```dart
class Post {
  final String id;          // UUID generado en el cliente (paquete uuid)
  final String title;
  final String content;
  final String profileId;   // FK → profiles.id
  final DateTime createdAt; // DateTime.now() en el cliente
}
```

> El dominio no expone nulleables. `id` y `createdAt` se generan en el cliente antes del insert.
> `content` se valida como no vacío en el formulario aunque la columna DB admita null.

---

## Flujo de Interacción

1. Usuario en tab **Feed** → ve la lista de posts (`PostsListBloc`).
2. Toca el **FAB (+)** → se abre `ModalBottomSheet` con el formulario.
3. Completa título y contenido → toca "Publicar".
4. `PostBloc` crea el post en Supabase.
5. En `PostSuccessState`: el modal se cierra y `PostsListBloc` recarga el feed.

---

## Estructura de Archivos

```
lib/features/post/
  domain/
    models/post.dart
    repository/post_repository.dart
    usecases/create_post_usecase.dart
    usecases/fetch_posts_usecase.dart
  data/
    sources/post_data_source.dart
    repository/post_repository_impl.dart
  ui/
    bloc/post_bloc.dart           # maneja creación (Loading/Success/Error)
    bloc/posts_list_bloc.dart     # maneja feed (Loading/Loaded/Error)
    widgets/post_card.dart
lib/features/home/
  ui/pages/home_page.dart         # feed + FAB + _CreatePostModal
```

---

## Providers en HomePage

| BLoC | Ciclo de vida | Nota |
|------|--------------|------|
| `PostsListBloc` | Instanciado en `_HomePageState`, vive mientras el tab está montado | Provee el feed |
| `PostBloc` | Creado dentro de `_CreatePostModal` via `BlocProvider` | Se descarta al cerrar el modal |

El `_CreatePostModal` recibe `PostsListBloc` vía `BlocProvider.value` para recargar el feed al publicar.

---

## Acceptance Criteria

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

## Manifest de Tareas

| Sub-tarea | Estado | Notas |
|-----------|:------:|-------|
| Modelo Post sin nulleables + toJson/fromJson | ✅ | id y createdAt generados en cliente |
| PostDataSource.createPost | ✅ | Insert con id/createdAt del cliente y profile_id |
| PostDataSource.fetchAllPosts | ✅ | SELECT * ORDER BY created_at DESC |
| PostRepository (abstracto) + PostRepositoryImpl | ✅ | Instancia PostDataSource directamente |
| CreatePostUsecase | ✅ | Delega a PostRepository.createPost |
| FetchPostsUsecase | ✅ | Delega a PostRepository.fetchPosts |
| PostBloc — estados Loading/Success/Error | ✅ | Para creación de post |
| PostsListBloc — estados Loading/Loaded/Error | ✅ | Para feed de posts |
| PostCard widget (title, content, fecha) | ✅ | Muestra fecha local formateada |
| HomePage con ListView + FAB | ✅ | Feed sin paginación |
| _CreatePostModal (ModalBottomSheet) | ✅ | Cierra y recarga feed en PostSuccessState |
| Ajuste al teclado en modal | ✅ | viewInsets.bottom |
| Mensaje "No hay posts aún" si lista vacía | ✅ | En PostsListLoadedState vacío |
