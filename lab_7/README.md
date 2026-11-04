# Laboratorio 7 · Fotos en el muro

Aplicación Flutter con arquitectura por capas, Flutter BLoC y Supabase. Extiende el Laboratorio 6 con fotos de perfil, publicaciones con imágenes y los seis retos opcionales del Laboratorio 7.

## Ejecución

Requisitos: Flutter compatible con Dart 3.12, Chrome o un dispositivo/emulador compatible y conexión al proyecto Supabase configurado.

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Para usar cámara en Android, ejecute `flutter devices` y después `flutter run -d <device-id>`. El navegador puede solicitar permisos y su soporte depende de la cámara y de la configuración del sitio.

## Dependencias principales

- `flutter_bloc`: eventos y estados de autenticación, composer y muro.
- `supabase_flutter`: Auth, PostgreSQL y Storage.
- `image_picker`: galería y cámara (solo en la capa de datos).
- `uuid`: nombres únicos para objetos de Storage.
- `cached_network_image`: carga, caché, indicadores y errores de imágenes remotas.

## Supabase

La URL y la publishable key pública están en `lib/main.dart`. La aplicación no necesita ni debe usar una clave `service_role`. El esquema requiere `profiles`, `posts`, `likes`, `profiles.avatar_path` y `posts.image_path`, además de RLS habilitado.

| Bucket | Acceso | Límite | MIME |
|---|---|---:|---|
| `avatars` | público | 2 MiB | JPEG, PNG, WebP |
| `post-images` | privado | 2 MiB | JPEG, PNG, WebP |

Los objetos usan la ruta `<uuid-del-usuario>/<archivo>`. Las políticas de Storage restringen `INSERT`, `UPDATE` y `DELETE` a esa carpeta. Los usuarios autenticados pueden leer `post-images` para solicitar URLs firmadas. Las migraciones están en `supabase/migrations`; el esquema previo de los laboratorios 5 y 6 sigue siendo necesario al reconstruir un proyecto desde cero.

## Funcionalidades principales

- Registro, inicio y cierre de sesión, perfil y muro paginado.
- Likes y publicaciones de hasta 280 caracteres.
- Avatar desde galería o cámara, indicador de carga, reemplazo seguro e inicial como fallback.
- Posts solo con texto, solo con imagen o con ambos.
- Vista previa proporcional, cancelación y eliminación de la selección antes de publicar.
- Carga de la imagen antes de insertar el post.
- Imágenes privadas del muro mediante URLs firmadas por 3600 segundos.
- Visualización proporcional de las fotos del muro, sin alto rígido ni recorte `BoxFit.cover`.

## Retos opcionales

1. **Propiedad de Storage:** cada cuenta escribe, actualiza y elimina únicamente dentro de su UUID.
2. **Galería o cámara:** `PhotoSource` permanece en dominio y su conversión a `ImageSource` ocurre en `DevicePhotoDataSource`. Cerrar el selector no cambia el estado.
3. **Quitar avatar:** primero escribe `profiles.avatar_path = NULL`, confirma la fila y luego elimina el objeto propio. Perfil y muro se recargan.
4. **Caché:** avatares y posts usan `CachedNetworkImage` con progreso y fallback.
5. **Eliminar posts:** la opción solo aparece en posts propios, requiere confirmación, elimina primero la fila y después su imagen, y refresca muro y perfil.
6. **Firma en lote:** cada página agrupa las rutas y usa `createSignedUrlsResult(paths, 3600)` en una sola petición; conserva orden, duplicados y posts sin imagen.

## Caché y privacidad

Los avatares tienen URLs públicas estables y se benefician directamente de la caché. Las imágenes privadas usan como clave predeterminada la URL firmada completa. Al renovarse la firma puede cambiar la URL y producir otra entrada de caché; no se usa una clave estable basada en la ruta porque podría reutilizar bytes privados entre sesiones. Una URL expirada puede seguir mostrando bytes ya almacenados localmente bajo esa URL exacta, pero otra sesión no recibe esa clave desde la aplicación.

En Android, `cached_network_image` usa el gestor de caché del dispositivo. En Flutter Web el comportamiento depende principalmente de la caché HTTP del navegador y ofrece menos control persistente; además deben respetarse CORS y la expiración de la URL firmada.

## Eliminaciones y consistencia

PostgreSQL y Storage no comparten una transacción. Para evitar referencias visibles a archivos borrados, primero se desvincula/elimina la fila y después se borra el objeto. Si el segundo paso falla, la aplicación informa que puede quedar un archivo huérfano y recarga los datos. Nunca se intenta borrar una ruta de avatar ajena y RLS vuelve a validar la propiedad en el servidor. La FK de `likes` del esquema base debe usar `ON DELETE CASCADE` para que al eliminar un post desaparezcan sus relaciones.

## Pruebas

`test/wall_test.dart` cubre entidades, estados y widgets principales. `test/optional_challenges_test.dart` cubre la asignación de firmas en lote, orden, duplicados, posts sin imagen, rechazo de borrado ajeno y escritura de `NULL` antes de borrar un avatar.

Las pruebas automatizadas no sustituyen una sesión real: galería/cámara, permisos del dispositivo, límites efectivos de Storage, RLS entre dos cuentas y limpieza física de archivos deben verificarse contra Supabase sin eliminar datos existentes.
