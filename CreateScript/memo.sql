-- Table: public.memo

-- DROP TABLE IF EXISTS public.memo;

CREATE TABLE IF NOT EXISTS public.memo
(
    id integer NOT NULL DEFAULT nextval('memo_id_seq'::regclass),
    title character varying(400) COLLATE pg_catalog."default",
    body character varying(400) COLLATE pg_catalog."default"
)

TABLESPACE pg_default;
