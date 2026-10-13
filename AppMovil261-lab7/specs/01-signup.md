# Spec 01 — Feature: Registro (Signup)

## Objetivo

Permitir a nuevos usuarios crear una cuenta en la aplicación utilizando su correo electrónico y una contraseña, integrándose con Supabase Auth.

---

## User Stories

- **Como** nuevo usuario, **quiero** registrarme con mi email y contraseña **para** poder acceder a las funcionalidades protegidas de la app.

---

## Requerimientos Funcionales

- **Entradas:** Correo electrónico (válido), Contraseña (mínimo 6 caracteres).
- **Acciones:**
  - Validar formato de email.
  - Llamar al servicio de autenticación de Supabase (`AuthDataSource.signup`).
  - Manejar estados: carga, éxito y error (ej. usuario ya existe).
- **Salidas:** Redirección a `/home` en caso de éxito. Snackbar de error en caso de fallo.

---

## Estructura de Archivos

```
lib/features/
  auth/
    domain/
      repo/auth_repo.dart                    # abstract: signup, login, logout
      usecases/signup_usecase.dart
    data/
      sources/auth_data_source.dart
      repo/auth_repo_impl.dart
  signup/
    ui/
      bloc/signup_bloc.dart                  # eventos: SignupEvent / estados: SignupState
      screens/signup_screen.dart
```

---

## Acceptance Criteria

- [x] La UI tiene campos para Email y Password.
- [x] El botón "Registrar" dispara el `SignupBloc`.
- [x] Muestra un `CircularProgressIndicator` durante la carga.
- [x] Redirige a `/home` al completar con éxito.
- [x] Validación de campos en tiempo real (`AutovalidateMode.onUserInteraction`).
- [x] Navega a `/login` desde la pantalla de signup.

---

## Manifest de Tareas

| Sub-tarea | Estado | Notas |
|-----------|:------:|-------|
| UI — SignupScreen con campos email/password | ✅ | Form + TextFormField con validadores |
| Lógica — SignupBloc (estados Loading/Success/Error) | ✅ | Integrado con SignupUsecase |
| Usecase — SignupUsecase | ✅ | Delega a AuthRepo |
| Repo abstracto — AuthRepo.signup | ✅ | Contrato en domain/repo |
| Repo impl — AuthRepoImpl.signup | ✅ | Llama a AuthDataSource |
| DataSource — AuthDataSource.signup | ✅ | Usa supabase_flutter AuthResponse |
| Validación de formulario en tiempo real | ✅ | AutovalidateMode.onUserInteraction |
| Integración Supabase Auth | ✅ | Proyecto: pmijmrkaucdwadmnnvbo |
