# Spec 03 — Feature: MainScreen — Navegación Principal

## Objetivo

Pantalla principal post-login con `BottomNavigationBar` de 3 tabs: Perfil, Feed y Chat. Actúa como contenedor (`Screen`) que hostea las sub-pantallas (`Page`) de cada sección.

---

## Convención Screen vs Page

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| `Screen` | Página completa con `Scaffold` propio y ruta nombrada en `MaterialApp`. | `LoginScreen`, `SignupScreen` |
| `Page` | Sub-pantalla sin `Scaffold` propio, hosteada dentro de una `Screen`. | `ProfilePage`, `HomePage`, `ConversationsPage` |

---

## User Stories

- **Como** usuario autenticado, **quiero** navegar entre secciones de la app **para** acceder a mis datos, el feed y chatear.

---

## Requerimientos Funcionales

- `MainScreen` provee el `BottomNavigationBar` con 3 items: Perfil, Feed, Chat.
- Al montar, verifica si hay sesión activa; si no, redirige a `/login`.
- Cada tab renderiza su `Page` correspondiente sin recrear estado al cambiar de tab.

---

## Estructura de Archivos

```
lib/
  core/
    navigation/
      main_screen.dart           # Scaffold + BottomNavigationBar (3 tabs)
  features/
    profile/ui/pages/profile_page.dart
    home/ui/pages/home_page.dart
    chat/ui/pages/conversations_page.dart
```

---

## Acceptance Criteria

- [x] `MainScreen` con `BottomNavigationBar` (Perfil / Feed / Chat).
- [x] Etiquetas visibles en ítems seleccionados y no seleccionados (`showUnselectedLabels: true`).
- [x] Colores explícitos: fondo blanco, seleccionado azul, no seleccionado gris.
- [x] Redirige a `/login` si no hay sesión activa al montar.
- [x] Navegación entre tabs sin pérdida de estado.

---

## Manifest de Tareas

| Sub-tarea | Estado | Notas |
|-----------|:------:|-------|
| MainScreen con BottomNavigationBar (3 tabs) | ✅ | Perfil / Feed / Chat |
| Etiquetas visibles (seleccionadas y no) | ✅ | showUnselectedLabels: true |
| Colores explícitos | ✅ | Fondo blanco, azul seleccionado, gris no-seleccionado |
| Guard de sesión al montar | ✅ | Redirige a /login si Supabase.auth.currentUser == null |
| Registro de ruta /home en main.dart | ✅ | BlocProvider(ProfileBloc) wrapping MainScreen |
