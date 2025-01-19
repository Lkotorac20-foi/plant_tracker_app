--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

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
-- Name: generate_reminders(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_reminders() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO reminders (plant_id, reminder_date, message, is_done)
    SELECT id, NOW() + INTERVAL '2 days', 'Podsjetnik: Zaliti biljku ' || name, FALSE
    FROM plants
    WHERE NOT EXISTS (
        SELECT 1 FROM reminders
        WHERE reminders.plant_id = plants.id AND is_done = FALSE
    );
END;
$$;


ALTER FUNCTION public.generate_reminders() OWNER TO postgres;

--
-- Name: mark_reminder_done(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mark_reminder_done() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE reminders
    SET is_done = TRUE
    WHERE plant_id = NEW.plant_id
      AND reminder_date <= NEW.event_date
      AND is_done = FALSE;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.mark_reminder_done() OWNER TO postgres;

--
-- Name: track_plant_changes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.track_plant_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO plants_history (plant_id, name, species, planting_date, description, action)
    VALUES (OLD.id, OLD.name, OLD.species, OLD.planting_date, OLD.description, TG_OP);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.track_plant_changes() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    id integer NOT NULL,
    plant_id integer,
    event_type character varying(50) NOT NULL,
    event_date timestamp without time zone DEFAULT now(),
    notes text
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.events_id_seq OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images (
    id integer NOT NULL,
    plant_id integer,
    image_path character varying(255) NOT NULL,
    upload_date timestamp without time zone DEFAULT now()
);


ALTER TABLE public.images OWNER TO postgres;

--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.images_id_seq OWNER TO postgres;

--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- Name: plants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plants (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    species character varying(255),
    planting_date date NOT NULL,
    description text
);


ALTER TABLE public.plants OWNER TO postgres;

--
-- Name: plants_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plants_history (
    id integer NOT NULL,
    plant_id integer,
    name text,
    species text,
    planting_date date,
    description text,
    changed_at timestamp without time zone DEFAULT now(),
    action text
);


ALTER TABLE public.plants_history OWNER TO postgres;

--
-- Name: plants_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plants_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plants_history_id_seq OWNER TO postgres;

--
-- Name: plants_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plants_history_id_seq OWNED BY public.plants_history.id;


--
-- Name: plants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plants_id_seq OWNER TO postgres;

--
-- Name: plants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plants_id_seq OWNED BY public.plants.id;


--
-- Name: reminders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reminders (
    id integer NOT NULL,
    plant_id integer,
    reminder_date timestamp without time zone NOT NULL,
    message text NOT NULL,
    is_done boolean DEFAULT false
);


ALTER TABLE public.reminders OWNER TO postgres;

--
-- Name: plants_with_pending_reminders; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.plants_with_pending_reminders AS
 SELECT plants.name AS plant_name,
    reminders.message AS reminder_message,
    reminders.reminder_date AS due_date
   FROM (public.plants
     JOIN public.reminders ON ((plants.id = reminders.plant_id)))
  WHERE (reminders.is_done = false);


ALTER VIEW public.plants_with_pending_reminders OWNER TO postgres;

--
-- Name: reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reminders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reminders_id_seq OWNER TO postgres;

--
-- Name: reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reminders_id_seq OWNED BY public.reminders.id;


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- Name: plants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plants ALTER COLUMN id SET DEFAULT nextval('public.plants_id_seq'::regclass);


--
-- Name: plants_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plants_history ALTER COLUMN id SET DEFAULT nextval('public.plants_history_id_seq'::regclass);


--
-- Name: reminders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reminders ALTER COLUMN id SET DEFAULT nextval('public.reminders_id_seq'::regclass);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: plants_history plants_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plants_history
    ADD CONSTRAINT plants_history_pkey PRIMARY KEY (id);


--
-- Name: plants plants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plants
    ADD CONSTRAINT plants_pkey PRIMARY KEY (id);


--
-- Name: reminders reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: events after_event_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_event_insert AFTER INSERT ON public.events FOR EACH ROW WHEN (((new.event_type)::text = 'zalijevanje'::text)) EXECUTE FUNCTION public.mark_reminder_done();


--
-- Name: plants before_plant_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_plant_update BEFORE DELETE OR UPDATE ON public.plants FOR EACH ROW EXECUTE FUNCTION public.track_plant_changes();


--
-- Name: events events_plant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_plant_id_fkey FOREIGN KEY (plant_id) REFERENCES public.plants(id) ON DELETE CASCADE;


--
-- Name: images images_plant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_plant_id_fkey FOREIGN KEY (plant_id) REFERENCES public.plants(id) ON DELETE CASCADE;


--
-- Name: reminders reminders_plant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reminders
    ADD CONSTRAINT reminders_plant_id_fkey FOREIGN KEY (plant_id) REFERENCES public.plants(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

