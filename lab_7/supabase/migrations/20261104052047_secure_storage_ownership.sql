
-- LABORATORIO 7 - RETO 1
-- Seguridad de archivos por usuario.

-- Eliminar políticas generales anteriores.
DROP POLICY IF EXISTS "avatars: usuarios autenticados"
ON storage.objects;

DROP POLICY IF EXISTS "post-images: usuarios autenticados"
ON storage.objects;

-- AVATARS

-- Leer objetos del bucket avatars.
CREATE POLICY "avatars_select"
ON storage.objects
FOR SELECT TO authenticated
USING (bucket_id = 'avatars');

-- Subir fotos solamente a la carpeta propia.
CREATE POLICY "avatars_insert_own"
ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] =
      (SELECT auth.uid()::text)
);

-- Actualizar archivos solamente de la carpeta propia.
CREATE POLICY "avatars_update_own"
ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] =
      (SELECT auth.uid()::text)
)
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] =
      (SELECT auth.uid()::text)
);

-- Eliminar solamente fotos propias.
CREATE POLICY "avatars_delete_own"
ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] =
      (SELECT auth.uid()::text)
);

-- POST-IMAGES

-- Leer imágenes privadas con sesión iniciada.
CREATE POLICY "post_images_select"
ON storage.objects
FOR SELECT TO authenticated
USING (bucket_id = 'post-images');

-- Subir imágenes únicamente a la carpeta propia.
CREATE POLICY "post_images_insert_own"
ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'post-images'
  AND (storage.foldername(name))[1] =
      (SELECT auth.uid()::text)
);

-- Actualizar archivos propios.
CREATE POLICY "post_images_update_own"
ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'post-images'
  AND (storage.foldername(name))[1] =
      (SELECT auth.uid()::text)
)
WITH CHECK (
  bucket_id = 'post-images'
  AND (storage.foldername(name))[1] =
      (SELECT auth.uid()::text)
);

-- Eliminar imágenes propias.
CREATE POLICY "post_images_delete_own"
ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'post-images'
  AND (storage.foldername(name))[1] =
      (SELECT auth.uid()::text)
);
