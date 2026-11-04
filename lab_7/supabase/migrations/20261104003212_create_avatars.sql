-- Laboratorio 7 - Parte 1
-- Agregar fotografías de perfil.

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS avatar_path TEXT;

-- Permitir operaciones en el bucket avatars
-- a los usuarios autenticados.

CREATE POLICY "avatars: usuarios autenticados"
ON storage.objects
FOR ALL
TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');