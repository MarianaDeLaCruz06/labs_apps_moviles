# Spec 02 — Feature: Login

## Objetivo

Permitir a usuarios existentes acceder a su cuenta mediante sus credenciales previamente registradas, persistiendo la sesión con Supabase Auth.

---

## User Stories

- **Como** usuario registrado, **quiero** iniciar sesión **para** retomar mi actividad en la aplicación.

---

## Requerimientos Funcionales

- **Entradas:** Correo electrónico y Contraseña.
- **Acciones:**
  - Verificar credenciales contra Supabase Auth.
  - Persistir la sesión del usuario (Supabase la maneja automáticamente).
- **Salidas:** Navegación a `/home` en caso de éxito. Mensaje de error específico si las credenciales son incorrectas.

---

## Estructura de Archivos

```
lib/features/
  auth/
    domain/
      repo/auth_repo.dart                    # abstract: login
      usecases/login_usecase.dart
    data/
      sources/auth_data_source.dart          # compartida con signup/logout
      repo/auth_repo_impl.dart
  login/
    ui/
      bloc/login_bloc.dart                   # eventos: LoginEvent / estados: LoginState
      screens/login_screen.dart
```

---

## Acceptance Criteria

- [x] Pantalla de Login dedicada con campos email y password.
- [x] BLoC (`LoginBloc`) maneja el estado de autenticación de login.
- [x] Manejo de errores específicos (ej. "Invalid credentials").
- [x] Opción para navegar a la pantalla de Registro (`/signup`) desde el Login.
- [x] Muestra `CircularProgressIndicator` durante la llamada a Supabase.
- [x] Redirige a `/home` en caso de éxito.

---

## Manifest de Tareas

| Sub-tarea | Estado | Notas |
|-----------|:------:|-------|
| UI — LoginScreen con campos email/password | ✅ | Pantalla creada con navegación a Signup |
| Lógica — LoginBloc (estados Loading/Success/Error) | ✅ | Implementada con manejo de estados |
| Usecase — LoginUsecase | ✅ | Implementado y conectado al Repo |
| Repo abstracto — AuthRepo.login | ✅ | Mismo contrato que signup |
| Repo impl — AuthRepoImpl.login | ✅ | Llama a AuthDataSource.login |
| DataSource — AuthDataSource.login | ✅ | Usa supabase signInWithPassword |
| Manejo de error "Invalid credentials" | ✅ | Snackbar con mensaje del error |
| Navegación a /signup | ✅ | Link en pantalla de login |
