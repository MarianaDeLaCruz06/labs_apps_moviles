# Spec 04 — Feature: ProfilePage

## Objetivo

Mostrar los datos del perfil del usuario autenticado (nombre y email leídos desde la tabla `profiles` de Supabase) y permitirle cerrar sesión.

---

## User Stories

- **Como** usuario autenticado, **quiero** ver mi perfil **para** confirmar mis datos.
- **Como** usuario autenticado, **quiero** cerrar sesión **para** salir de la app de forma segura.

---

## Modelo de Dominio

```dart
class Profile {
  final String id;     // UID de Supabase Auth
  final String name;
  final String email;
}
```

---

## Esquema Supabase

```sql
create table profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text not null,
  email      text not null,
  created_at timestamp with time zone default now()
);
```

---

## Estructura de Archivos

```
lib/features/profile/
  domain/
    model/profile.dart
    repository/profile_repository.dart        # abstract: getProfile, logout
  data/
    source/profile_data_source.dart
    repository/profile_repository_impl.dart
  ui/
    bloc/profile_bloc.dart                    # eventos: LoadProfile, Logout
    pages/profile_page.dart
```

---

## Acceptance Criteria

- [x] `ProfilePage` muestra nombre y email del usuario autenticado.
- [x] Botón funcional de "Cerrar Sesión" dispara `LogoutUsecase` vía `ProfileBloc`.
- [x] Navega a `/login` tras cerrar sesión exitosamente.
- [x] Muestra indicador de carga mientras carga el perfil.

---

## Manifest de Tareas

| Sub-tarea | Estado | Notas |
|-----------|:------:|-------|
| Modelo Profile (id, name, email) | ✅ | Dart puro sin nulleables |
| Repo abstracto — ProfileRepository | ✅ | Contrato en domain/repository |
| DataSource — ProfileDataSource | ✅ | Lee de tabla profiles en Supabase |
| Repo impl — ProfileRepositoryImpl | ✅ | Instancia ProfileDataSource directamente |
| Usecase — LogoutUsecase | ✅ | En features/auth/domain/usecases |
| BLoC — ProfileBloc (LoadProfile / Logout) | ✅ | Estados: Loading/Loaded/Error |
| UI — ProfilePage con nombre y email | ✅ | Desde Supabase profiles table |
| Navegación a /login tras logout | ✅ | En ProfileBloc o BlocListener |
