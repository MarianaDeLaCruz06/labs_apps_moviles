# Laboratorio 7 · Fotos en el muro

**Desarrollo de Aplicaciones Móviles - Flutter y Supabase**

## Descripción

Este proyecto corresponde al Laboratorio 7, desarrollado a partir del proyecto base proporcionado por el profesor, que incluye las funcionalidades del Laboratorio 6 y la interfaz inicial para el manejo de fotografías.

El objetivo es integrar la selección, carga, almacenamiento y visualización de imágenes en una aplicación social utilizando Flutter, BLoC y Supabase.

El laboratorio se divide en dos partes:

- **Parte 1 - Foto de perfil:** permite seleccionar una fotografía desde la galería, subirla a Supabase Storage, actualizar el perfil y mostrarla junto a las publicaciones del usuario.
- **Parte 2 - Publicaciones con imágenes:** permite adjuntar una fotografía, visualizarla antes de publicar y mostrarla en el muro junto al texto de la publicación.

## Funcionalidades implementadas

### Autenticación y perfiles

- Registro de usuarios mediante Supabase Auth.
- Inicio y cierre de sesión.
- Consulta de la información del perfil.
- Selección y actualización de la fotografía de perfil.
- Visualización de la fotografía del autor en sus publicaciones.
- Visualización de la inicial del nombre cuando no existe una fotografía.

### Publicaciones

- Creación de publicaciones con texto.
- Creación de publicaciones con imágenes.
- Creación de publicaciones únicamente con imágenes.
- Vista previa de la fotografía antes de publicar.
- Opción para quitar una fotografía seleccionada.
- Muro de publicaciones con paginación.
- Visualización de publicaciones recientes en el perfil.
- Sistema de me gusta.
- Validación del máximo de 280 caracteres.

### Almacenamiento de imágenes

Se utilizan dos buckets de Supabase Storage:

| Bucket | Acceso | Uso |
|---|---|---|
| `avatars` | Público | Fotografías de perfil |
| `post-images` | Privado | Fotografías de publicaciones |

Ambos buckets tienen un límite de 2 MiB por archivo y admiten JPEG, PNG y WebP.

Las fotografías de perfil se muestran mediante URLs públicas. Las imágenes de las publicaciones se consultan mediante URLs firmadas con una duración de 3600 segundos.

## Tecnologías utilizadas

- Flutter y Dart.
- Supabase Authentication.
- Supabase Database (PostgreSQL).
- Supabase Storage.
- Flutter BLoC para la gestión de eventos y estados.
- `image_picker` para seleccionar fotografías.
- `uuid` para generar nombres únicos de archivos.

## Arquitectura

La aplicación mantiene una separación de responsabilidades mediante las capas de presentación, dominio y datos.

**Presentación:** pantallas, componentes, eventos, estados y BLoC.

**Dominio:** entidades, contratos de repositorios y casos de uso.

**Datos:** implementaciones de repositorios y fuentes de datos que se comunican con Supabase y la galería del dispositivo.

Los casos de uso coordinan las operaciones sin depender directamente de los widgets de Flutter.

## Configuración de Supabase

La aplicación utiliza el proyecto de Supabase configurado para los laboratorios.

Los valores de conexión se encuentran en `lib/main.dart`:

- Project URL.
- Publishable key.

La publishable key es una clave pública de cliente. No se requiere ninguna clave `service_role` ni clave secreta para ejecutar la aplicación.

La base de datos debe contener las tablas:

- `profiles`
- `posts`
- `likes`

Además de las columnas `avatar_path` en `profiles` e `image_path` en `posts`.

Las políticas de Row Level Security (RLS) y Storage deben permitir las operaciones correspondientes a los usuarios autenticados.

Las migraciones SQL del laboratorio se encuentran en `supabase/migrations/`. Para reconstruir la base de datos en otro proyecto también se necesita el esquema previo de los laboratorios 5 y 6 y sus políticas correspondientes.

## Cómo ejecutar la aplicación

### Requisitos

- Flutter SDK instalado.
- Dart SDK.
- Visual Studio Code o un entorno compatible con Flutter.
- Google Chrome o un emulador Android.
- Conexión a Internet.
- Acceso al proyecto Supabase configurado.

### Ejecución

Desde la raíz del repositorio:

```bash
cd lab_7
flutter pub get
flutter analyze
flutter run -d chrome
```

Para ejecutar la aplicación en Android, iniciar un emulador y consultar los dispositivos disponibles:

```bash
flutter devices
flutter run
```

Seleccionar el dispositivo Android correspondiente.

No es necesario ejecutar `supabase init` para utilizar el proyecto existente, ya que la configuración se encuentra incluida en la carpeta `supabase/`.

## Pruebas funcionales

El flujo principal permite:

1. Registrar un usuario o iniciar sesión.
2. Consultar el perfil.
3. Seleccionar y subir una fotografía de perfil.
4. Visualizar la fotografía actualizada.
5. Crear una publicación con texto e imagen.
6. Crear una publicación únicamente con imagen.
7. Consultar el muro y las publicaciones del perfil.
8. Dar y quitar me gusta.
9. Cerrar sesión.

## Consideraciones

- La aplicación necesita conectarse a un proyecto Supabase activo.
- Las imágenes de los posts se almacenan en un bucket privado y requieren URLs firmadas para su visualización.
- Los archivos almacenados en Supabase no forman parte del repositorio Git.
- La eliminación de una publicación de la base de datos no elimina automáticamente su imagen de Storage.
- La aplicación conserva la arquitectura y las funcionalidades solicitadas en el Laboratorio 7.

## Proyecto base

Laboratorio 7 proporcionado por el profesor:

https://github.com/Domiciano/Apps262Lab7

El desarrollo completa las funcionalidades propuestas en el laboratorio y contiene ajustes visuales en las pantallas de autenticación, perfil y publicaciones.