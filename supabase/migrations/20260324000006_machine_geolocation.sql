-- Add machine geolocation fields for 3D globe visualization

ALTER TABLE IF EXISTS public.machines
ADD COLUMN IF NOT EXISTS country TEXT;

ALTER TABLE IF EXISTS public.machines
ADD COLUMN IF NOT EXISTS city TEXT;

ALTER TABLE IF EXISTS public.machines
ADD COLUMN IF NOT EXISTS address TEXT;

ALTER TABLE IF EXISTS public.machines
ADD COLUMN IF NOT EXISTS latitude NUMERIC(9,6);

ALTER TABLE IF EXISTS public.machines
ADD COLUMN IF NOT EXISTS longitude NUMERIC(9,6);

CREATE INDEX IF NOT EXISTS idx_machines_coordinates ON public.machines(latitude, longitude);
