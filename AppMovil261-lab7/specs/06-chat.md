# Spec 06 — Feature: Chat en Tiempo Real

## Objetivo

Permitir a los usuarios autenticados iniciar y mantener conversaciones 1-a-1 en tiempo real. El tab "Chat" muestra la lista de todos los usuarios registrados; al tocar uno se abre (o crea) la conversación y se navega a `ChatPage`.

---

## User Stories

- **Como** usuario autenticado, **quiero** ver todos los usuarios disponibles **para** elegir con quién chatear.
- **Como** usuario autenticado, **quiero** abrir una conversación con otro usuario **para** comunicarme en tiempo real.
- **Como** usuario autenticado, **quiero** que los mensajes nuevos aparezcan automáticamente **para** no tener que recargar.

---

## Esquema Supabase

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

---

## Modelos de Dominio

```dart
// Reutiliza Profile de lib/features/profile/domain/model/profile.dart

class Conversation {
  final String id;
  final String profile1Id;
  final String profile2Id;
  final DateTime createdAt;
  final String? otherUserName;  // nullable: nombre resuelto en UI
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
}
```

---

## Flujo de Interacción

1. Usuario entra al tab **Chat** → `UsersBloc` carga todos los perfiles excepto el suyo.
2. Ve la lista de usuarios con nombre e inicial en avatar.
3. Toca un usuario → `GetOrCreateConversationUsecase(currentUserId, otherUserId)`.
4. Si la conversación ya existe, la retorna; si no, la crea en Supabase.
5. Navega a `ChatPage(conversationId, otherUserName)`.
6. `ChatPage` suscribe en realtime los mensajes y permite enviar nuevos.

---

## Estructura de Archivos

```
lib/features/chat/
  domain/
    models/conversation.dart
    models/message.dart
    repository/chat_repository.dart
    usecases/get_profiles_usecase.dart
    usecases/get_or_create_conversation_usecase.dart
    usecases/send_message_usecase.dart
    usecases/watch_messages_usecase.dart
  data/
    sources/chat_data_source.dart
    repository/chat_repository_impl.dart
  ui/
    bloc/users_bloc.dart               # lista de usuarios (Loading/Loaded/Error)
    bloc/chat_bloc.dart                # mensajes realtime (Loading/Loaded/Error)
    pages/conversations_page.dart      # lista de usuarios para iniciar chat
    pages/chat_page.dart               # conversación en tiempo real
```

---

## Acceptance Criteria

- [x] `ChatDataSource.getProfiles(currentUserId)` retorna todos los perfiles excepto el propio, ordenados por nombre.
- [x] `GetProfilesUsecase` encapsula la llamada al repositorio.
- [x] `UsersBloc` gestiona estados `UsersLoadingState`, `UsersLoadedState(List<Profile>)`, `UsersErrorState`.
- [x] `ConversationsPage` muestra lista de usuarios con avatar (inicial del nombre) y nombre completo.
- [x] Al tocar un usuario se llama `GetOrCreateConversationUsecase` y navega a `ChatPage`.
- [x] `GetOrCreateConversationUsecase` busca conversación en ambas direcciones antes de crear una nueva.
- [x] `ChatPage` suscribe a mensajes en tiempo real con `watchMessages(conversationId)`.
- [x] `ChatBloc` gestiona estados `ChatLoadingState`, `ChatLoadedState`, `ChatErrorState`.
- [x] Mensajes propios alineados a la derecha (color primario); ajenos a la izquierda.
- [x] Envío de mensaje limpia el `TextField`.

---

## Manifest de Tareas

| Sub-tarea | Estado | Notas |
|-----------|:------:|-------|
| Modelos Conversation y Message (fromJson/toJson) | ✅ | Conversation.otherUserName es nullable (resuelto en UI) |
| ChatDataSource.getProfiles | ✅ | Todos excepto el propio, ORDER BY name |
| ChatDataSource.getOrCreateConversation | ✅ | Busca en ambas direcciones |
| ChatDataSource.sendMessage | ✅ | Insert en tabla messages |
| ChatDataSource.watchMessages | ✅ | Stream realtime via Supabase |
| ChatRepository (abstracto) + ChatRepositoryImpl | ✅ | Incluye getProfiles |
| GetProfilesUsecase | ✅ | Implementado |
| GetOrCreateConversationUsecase | ✅ | Evita duplicados buscando ambas direcciones |
| SendMessageUsecase | ✅ | Implementado |
| WatchMessagesUsecase | ✅ | Retorna Stream<List<Message>> |
| UsersBloc (Loading/Loaded/Error) | ✅ | Lista de perfiles para ConversationsPage |
| ConversationsPage — lista usuarios con avatar | ✅ | Inicial del nombre como avatar |
| ChatBloc — suscripción realtime | ✅ | Estados: Loading/Loaded/Error |
| ChatPage — mensajes diferenciados por alineación | ✅ | Derecha=propio (azul), Izquierda=ajeno (gris) |
| TextField limpiado tras envío | ✅ | Controller.clear() en SendMessage event |
