# Specs — Índice

Directorio de especificaciones técnicas de `appmovil261`.  
Sigue **Spec-Driven Development (SDD)**: cada feature está definida antes y durante su implementación.

| # | Archivo | Feature | Estado |
|---|---------|---------|:------:|
| 00 | [00-architecture.md](00-architecture.md) | Clean Architecture — capas, responsabilidades, convenciones | ✅ |
| 01 | [01-signup.md](01-signup.md) | Registro (Signup) con Supabase Auth | ✅ |
| 02 | [02-login.md](02-login.md) | Login con Supabase Auth | ✅ |
| 03 | [03-main-screen.md](03-main-screen.md) | MainScreen — BottomNavigationBar 3 tabs | ✅ |
| 04 | [04-profile.md](04-profile.md) | ProfilePage — datos del usuario + logout | ✅ |
| 05 | [05-feed-posts.md](05-feed-posts.md) | Feed — Posts con creación modal (FAB) | ✅ |
| 06 | [06-chat.md](06-chat.md) | Chat en tiempo real 1-a-1 con Supabase realtime | ✅ |

---

## Inventario del Proyecto vs Specs

| Feature implementada en código | Spec | Archivos clave |
|--------------------------------|------|----------------|
| Auth (signup/login/logout) | [01](01-signup.md), [02](02-login.md) | `lib/features/auth/`, `lib/features/signup/`, `lib/features/login/` |
| MainScreen (tabs) | [03](03-main-screen.md) | `lib/core/navigation/main_screen.dart` |
| Profile + Logout | [04](04-profile.md) | `lib/features/profile/` |
| Posts / Feed | [05](05-feed-posts.md) | `lib/features/post/`, `lib/features/home/` |
| Chat realtime | [06](06-chat.md) | `lib/features/chat/` |
| Clean Architecture (transversal) | [00](00-architecture.md) | Toda la estructura `lib/` |

---

*Última actualización: 11 de Mayo, 2026*
