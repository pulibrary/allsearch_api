SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: unaccented_dict; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public.unaccented_dict (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR word WITH public.unaccent, simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR hword_part WITH public.unaccent, simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR hword WITH public.unaccent, simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.unaccented_dict
    ADD MAPPING FOR uint WITH simple;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: banners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.banners (
    id bigint NOT NULL,
    text text DEFAULT ''::text,
    display_banner boolean DEFAULT false,
    alert_status integer DEFAULT 1,
    dismissible boolean DEFAULT true,
    autoclear boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: banners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.banners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: banners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.banners_id_seq OWNED BY public.banners.id;


--
-- Name: best_bet_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.best_bet_records (
    id bigint NOT NULL,
    title character varying,
    description character varying,
    url character varying,
    search_terms character varying[],
    last_update date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: best_bet_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.best_bet_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: best_bet_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.best_bet_records_id_seq OWNED BY public.best_bet_records.id;


--
-- Name: flipper_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_features (
    id bigint NOT NULL,
    key character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: flipper_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_features_id_seq OWNED BY public.flipper_features.id;


--
-- Name: flipper_gates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_gates (
    id bigint NOT NULL,
    feature_key character varying NOT NULL,
    key character varying NOT NULL,
    value text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_gates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_gates_id_seq OWNED BY public.flipper_gates.id;


--
-- Name: library_database_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.library_database_records (
    id bigint NOT NULL,
    libguides_id bigint NOT NULL,
    name character varying NOT NULL,
    description character varying,
    alt_names character varying[],
    alt_names_concat character varying,
    url character varying,
    friendly_url character varying,
    subjects character varying[],
    subjects_concat character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    searchable tsvector GENERATED ALWAYS AS ((((setweight(to_tsvector('public.unaccented_dict'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.unaccented_dict'::regconfig, (COALESCE(alt_names_concat, ''::character varying))::text), 'B'::"char")) || setweight(to_tsvector('public.unaccented_dict'::regconfig, (COALESCE(description, ''::character varying))::text), 'C'::"char")) || setweight(to_tsvector('public.unaccented_dict'::regconfig, (COALESCE(subjects_concat, ''::character varying))::text), 'D'::"char"))) STORED
);


--
-- Name: library_database_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.library_database_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: library_database_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.library_database_records_id_seq OWNED BY public.library_database_records.id;


--
-- Name: library_staff_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.library_staff_records (
    id bigint NOT NULL,
    puid bigint NOT NULL,
    netid character varying NOT NULL,
    phone character varying,
    name character varying NOT NULL,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    title character varying NOT NULL,
    library_title character varying NOT NULL,
    email character varying NOT NULL,
    team character varying,
    division character varying,
    department character varying,
    unit character varying,
    office character varying,
    building character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    areas_of_study character varying,
    other_entities character varying,
    my_scheduler_link character varying,
    searchable tsvector GENERATED ALWAYS AS (to_tsvector('english'::regconfig, (((((((((((((((((((((((((((COALESCE(title, ''::character varying))::text || ' '::text) || (COALESCE(first_name, ''::character varying))::text) || ' '::text) || (COALESCE(middle_name, ''::character varying))::text) || ' '::text) || (COALESCE(last_name, ''::character varying))::text) || ' '::text) || (COALESCE(title, ''::character varying))::text) || ' '::text) || (COALESCE(email, ''::character varying))::text) || ' '::text) || (COALESCE(department, ''::character varying))::text) || ' '::text) || (COALESCE(office, ''::character varying))::text) || ' '::text) || (COALESCE(building, ''::character varying))::text) || ' '::text) || (COALESCE(team, ''::character varying))::text) || ' '::text) || (COALESCE(division, ''::character varying))::text) || ' '::text) || (COALESCE(unit, ''::character varying))::text) || ' '::text) || (COALESCE(areas_of_study, ''::character varying))::text) || ' '::text) || (COALESCE(other_entities, ''::character varying))::text))) STORED,
    pronouns character varying
);


--
-- Name: library_staff_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.library_staff_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: library_staff_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.library_staff_records_id_seq OWNED BY public.library_staff_records.id;


--
-- Name: oauth_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_tokens (
    id bigint NOT NULL,
    service character varying NOT NULL,
    endpoint character varying NOT NULL,
    token character varying,
    expiration_time timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: oauth_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_tokens_id_seq OWNED BY public.oauth_tokens.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: banners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banners ALTER COLUMN id SET DEFAULT nextval('public.banners_id_seq'::regclass);


--
-- Name: best_bet_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.best_bet_records ALTER COLUMN id SET DEFAULT nextval('public.best_bet_records_id_seq'::regclass);


--
-- Name: flipper_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features ALTER COLUMN id SET DEFAULT nextval('public.flipper_features_id_seq'::regclass);


--
-- Name: flipper_gates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates ALTER COLUMN id SET DEFAULT nextval('public.flipper_gates_id_seq'::regclass);


--
-- Name: library_database_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_database_records ALTER COLUMN id SET DEFAULT nextval('public.library_database_records_id_seq'::regclass);


--
-- Name: library_staff_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_staff_records ALTER COLUMN id SET DEFAULT nextval('public.library_staff_records_id_seq'::regclass);


--
-- Name: oauth_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_tokens_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: banners banners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banners
    ADD CONSTRAINT banners_pkey PRIMARY KEY (id);


--
-- Name: best_bet_records best_bet_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.best_bet_records
    ADD CONSTRAINT best_bet_records_pkey PRIMARY KEY (id);


--
-- Name: flipper_features flipper_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features
    ADD CONSTRAINT flipper_features_pkey PRIMARY KEY (id);


--
-- Name: flipper_gates flipper_gates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates
    ADD CONSTRAINT flipper_gates_pkey PRIMARY KEY (id);


--
-- Name: library_database_records library_database_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_database_records
    ADD CONSTRAINT library_database_records_pkey PRIMARY KEY (id);


--
-- Name: library_staff_records library_staff_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_staff_records
    ADD CONSTRAINT library_staff_records_pkey PRIMARY KEY (id);


--
-- Name: oauth_tokens oauth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_tokens
    ADD CONSTRAINT oauth_tokens_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_flipper_features_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_features_on_key ON public.flipper_features USING btree (key);


--
-- Name: index_flipper_gates_on_feature_key_and_key_and_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_gates_on_feature_key_and_key_and_value ON public.flipper_gates USING btree (feature_key, key, value);


--
-- Name: index_oauth_tokens_on_endpoint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_tokens_on_endpoint ON public.oauth_tokens USING btree (endpoint);


--
-- Name: index_oauth_tokens_on_service; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_tokens_on_service ON public.oauth_tokens USING btree (service);


--
-- Name: searchable_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX searchable_idx ON public.library_database_records USING gin (searchable);


--
-- Name: staff_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_search_idx ON public.library_staff_records USING gin (searchable);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240819150118'),
('20240819142401'),
('20240815164656'),
('20240813174823'),
('20240717173433'),
('20240717164314'),
('20240716214838'),
('20240716210532'),
('20240710210913'),
('20231121205208'),
('20231120153410'),
('20230921193904'),
('20230920214343'),
('20230919194551'),
('20230919194126'),
('20230918230048'),
('20230918174143');

