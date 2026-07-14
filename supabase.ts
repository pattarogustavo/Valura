import 'react-native-url-polyfill/auto';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';
import type { Database } from '../types';

const SUPABASE_URL  = process.env.EXPO_PUBLIC_SUPABASE_URL!;
const SUPABASE_ANON = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;

if (!SUPABASE_URL || !SUPABASE_ANON) {
  throw new Error(
    'Missing Supabase environment variables.\n' +
    'Ensure EXPO_PUBLIC_SUPABASE_URL and EXPO_PUBLIC_SUPABASE_ANON_KEY are set in .env'
  );
}

export const supabase = createClient<Database>(SUPABASE_URL, SUPABASE_ANON, {
  auth: {
    storage:            AsyncStorage,
    autoRefreshToken:   true,
    persistSession:     true,
    detectSessionInUrl: false,   // required for React Native
  },
});

// ─── HELPERS ─────────────────────────────────────────────────────────────────

/** Returns the currently authenticated user's ID, or throws if not logged in */
export function requireUserId(): string {
  // This is called synchronously — only use after the auth state is known
  throw new Error('Call supabase.auth.getUser() asynchronously instead');
}

/** Uploads a file to Supabase Storage and returns its public URL */
export async function uploadAvatar(
  userId: string,
  uri: string,
  mimeType: string = 'image/jpeg'
): Promise<string> {
  const ext  = mimeType.split('/')[1] ?? 'jpg';
  const path = `${userId}/avatar.${ext}`;
  const body = await uriToBlob(uri);

  const { error } = await supabase.storage
    .from('avatars')
    .upload(path, body, { upsert: true, contentType: mimeType });

  if (error) throw error;

  const { data } = supabase.storage.from('avatars').getPublicUrl(path);
  return data.publicUrl;
}

async function uriToBlob(uri: string): Promise<Blob> {
  const res  = await fetch(uri);
  return res.blob();
}
