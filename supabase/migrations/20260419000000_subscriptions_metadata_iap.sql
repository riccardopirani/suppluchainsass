-- JSON metadata on subscriptions (plan key, IAP source, etc.)
ALTER TABLE public.subscriptions
  ADD COLUMN IF NOT EXISTS metadata JSONB NOT NULL DEFAULT '{}'::jsonb;
