--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6
-- Dumped by pg_dump version 10.10

-- Started on 2019-10-15 13:58:14 CDT

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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 334 (class 1259 OID 2346167)
-- Name: atd_txdot__veh_color_lkp; Type: TABLE; Schema: public; Owner: atd_vz_data
--

CREATE TABLE public.atd_txdot__veh_color_lkp (
    veh_color_id integer NOT NULL,
    veh_color_desc character varying(128),
    eff_beg_date character varying(32),
    eff_end_date character varying(32)
);


ALTER TABLE public.atd_txdot__veh_color_lkp OWNER TO atd_vz_data;

--
-- TOC entry 5618 (class 2606 OID 2346688)
-- Name: atd_txdot__veh_color_lkp atd_txdot__veh_color_lkp_pk; Type: CONSTRAINT; Schema: public; Owner: atd_vz_data
--

ALTER TABLE ONLY public.atd_txdot__veh_color_lkp
    ADD CONSTRAINT atd_txdot__veh_color_lkp_pk PRIMARY KEY (veh_color_id);


-- Completed on 2019-10-15 13:58:17 CDT

--
-- PostgreSQL database dump complete
--

