# Creator Cove

A Vite + React social platform for sharing art, animation, music, and self-contained HTML games.

## Setup
1. Create a Supabase project.
2. Open **SQL Editor**, paste `supabase/schema.sql`, and run it.
3. Copy `.env.example` to `.env` and add your Supabase project URL and publishable/anon key.
4. Run `npm install`, then `npm run dev`.

## Deploy to Vercel
1. Push the folder to GitHub and import it into Vercel, or run `npx vercel` from this folder.
2. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in Vercel Project Settings > Environment Variables.
3. Redeploy.

## Features
- Email/password accounts
- Responsive discovery feed and filters
- Upload art, GIF/video animation, music, and single-file HTML games
- Sandboxed playable game embeds
- Likes and creator profiles
- Owner-only deletion with Row Level Security

## Important
Only the public Supabase publishable/anon key belongs in the browser. Never place the service-role key in this project.
