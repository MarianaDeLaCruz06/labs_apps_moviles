-- Laboratorio 7 - Reto 5
-- Solo el autor autenticado puede eliminar sus publicaciones.
-- La FK de likes del esquema base debe conservar ON DELETE CASCADE.

DROP POLICY IF EXISTS "posts_delete_own" ON public.posts;

CREATE POLICY "posts_delete_own"
ON public.posts
FOR DELETE TO authenticated
USING (profile_id = (SELECT auth.uid()));
