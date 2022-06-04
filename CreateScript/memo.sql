-- Table: public.memo

-- DROP TABLE IF EXISTS public.memo;

CREATE TABLE IF NOT EXISTS public.memo
(
    id serial PRIMARY KEY NOT NULL,
    title character varying(400),
    body character varying(400)
);

