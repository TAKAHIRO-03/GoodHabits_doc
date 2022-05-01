DROP TABLE IF EXISTS public.accounts;

CREATE TABLE IF NOT EXISTS public.accounts (
  mail VARCHAR(256) PRIMARY KEY,
  password VARCHAR(60),
  created_date TIMESTAMP
);

ALTER TABLE public.accounts OWNER TO postgres;
