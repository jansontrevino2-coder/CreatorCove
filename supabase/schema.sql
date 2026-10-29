-- Run this entire file in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (char_length(username) between 2 and 30),
  avatar_url text,
  created_at timestamptz not null default now()
);
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 80),
  description text default '' check (char_length(description) <= 500),
  type text not null check (type in ('art','animation','music','game')),
  file_url text not null,
  file_path text not null,
  created_at timestamptz not null default now()
);
create table if not exists public.likes (
  post_id uuid references public.posts(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(post_id,user_id)
);

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,username) values(new.id,coalesce(nullif(new.raw_user_meta_data->>'username',''),'creator_'||substr(new.id::text,1,8))); return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.likes enable row level security;
create policy "profiles public read" on public.profiles for select using(true);
create policy "profiles own update" on public.profiles for update using(auth.uid()=id);
create policy "posts public read" on public.posts for select using(true);
create policy "posts authenticated insert" on public.posts for insert to authenticated with check(auth.uid()=user_id);
create policy "posts owner delete" on public.posts for delete to authenticated using(auth.uid()=user_id);
create policy "likes public read" on public.likes for select using(true);
create policy "likes own insert" on public.likes for insert to authenticated with check(auth.uid()=user_id);
create policy "likes own delete" on public.likes for delete to authenticated using(auth.uid()=user_id);

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('creations','creations',true,52428800,array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm','audio/mpeg','audio/wav','audio/ogg','text/html'])
on conflict(id) do update set public=true;
create policy "creation files public read" on storage.objects for select using(bucket_id='creations');
create policy "creation files user upload" on storage.objects for insert to authenticated with check(bucket_id='creations' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "creation files owner delete" on storage.objects for delete to authenticated using(bucket_id='creations' and owner_id=auth.uid()::text);
