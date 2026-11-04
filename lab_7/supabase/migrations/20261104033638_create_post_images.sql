-- Laboratorio 7 - Parte 2
-- Agregar imágenes a las publicaciones

alter table public.posts
add column if not exists image_path text;

-- Permitir operaciones en el bucket privado
-- para usuarios autenticados.

create policy "post-images: usuarios autenticados"
on storage.objects
for all to authenticated
using (bucket_id = 'post-images')
with check (bucket_id = 'post-images');