// RGBKart public configuration.
// These two values are SAFE to publish: the Supabase "anon / publishable" key only allows
// what the database's Row Level Security rules allow.
// NEVER put the service_role / secret key in this file or anywhere in the repository.
window.RGBKART_CONFIG = {
  SUPABASE_URL: "",        // e.g. "https://abcdefghijkl.supabase.co"  (Supabase → Project Settings → API)
  SUPABASE_ANON_KEY: "",   // the "anon" / "publishable" key
  BUILD_PHASE: "Phase 0 · Setup",
};
