-- Run this file manually in the Supabase SQL Editor.
-- It is non-destructive: existing messages and tables are preserved.

alter table public.messages
  add column if not exists image_path text;

-- Keep content NOT NULL for compatibility. New messages may contain text,
-- an image, or both. NOT VALID avoids rejecting legacy rows during setup.
alter table public.messages
  drop constraint if exists messages_content_or_image_check;

alter table public.messages
  add constraint messages_content_or_image_check
  check (length(trim(content)) > 0 or image_path is not null) not valid;

-- Private bucket, limited to common image formats and 10 MB per object.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'chat-images',
  'chat-images',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Chat participants can read images" on storage.objects;
create policy "Chat participants can read images"
on storage.objects for select
to authenticated
using (
  bucket_id = 'chat-images'
  and exists (
    select 1
    from public.conversations c
    where c.id::text = (storage.foldername(name))[1]
      and (c.profile1_id = auth.uid() or c.profile2_id = auth.uid())
  )
);

drop policy if exists "Chat participants can upload own images" on storage.objects;
create policy "Chat participants can upload own images"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'chat-images'
  and (storage.foldername(name))[2] = auth.uid()::text
  and exists (
    select 1
    from public.conversations c
    where c.id::text = (storage.foldername(name))[1]
      and (c.profile1_id = auth.uid() or c.profile2_id = auth.uid())
  )
);

-- Used only to clean up an uploaded object if inserting its message fails.
drop policy if exists "Chat uploaders can delete own images" on storage.objects;
create policy "Chat uploaders can delete own images"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'chat-images'
  and owner_id = auth.uid()::text
  and exists (
    select 1
    from public.conversations c
    where c.id::text = (storage.foldername(name))[1]
      and (c.profile1_id = auth.uid() or c.profile2_id = auth.uid())
  )
);

-- Ensure Postgres Changes broadcasts INSERT/UPDATE/DELETE for messages.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'messages'
  ) then
    alter publication supabase_realtime add table public.messages;
  end if;
end
$$;
