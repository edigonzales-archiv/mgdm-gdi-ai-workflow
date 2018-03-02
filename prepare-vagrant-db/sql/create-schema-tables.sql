DROP SCHEMA IF EXISTS afu_gewaesserschutz CASCADE;
CREATE SCHEMA IF NOT EXISTS afu_gewaesserschutz;

DROP TABLE IF EXISTS afu_gewaesserschutz.aww_gszustr;
CREATE TABLE IF NOT EXISTS afu_gewaesserschutz.aww_gszustr (
	ogc_fid serial NOT NULL,
	wkb_geometry geometry(MULTIPOLYGON, 2056) NULL,
	name varchar NULL,
	im_kanton float8 NULL,
	typ varchar NULL,
	"archive" int2 NULL DEFAULT 0,
	archive_date date NULL DEFAULT '9999-01-01'::date,
	new_date date NULL DEFAULT 'now'::text::date,
	CONSTRAINT aww_gszustr_pkey PRIMARY KEY (ogc_fid)
)
WITH (
	OIDS=FALSE
);
CREATE INDEX aww_gszustr_idx ON afu_gewaesserschutz.aww_gszustr USING gist (wkb_geometry) ;
CREATE UNIQUE INDEX aww_gszustr_ogc_fid_key ON afu_gewaesserschutz.aww_gszustr USING btree (ogc_fid) ;

DROP TABLE IF EXISTS afu_gewaesserschutz.aww_gszoar;
CREATE TABLE IF NOT EXISTS afu_gewaesserschutz.aww_gszoar (
	ogc_fid serial NOT NULL,
	wkb_geometry geometry(MULTIPOLYGON, 2056) NULL,
	"zone" varchar NULL,
	new_date date NULL DEFAULT 'now'::text::date,
	archive_date date NULL DEFAULT '9999-01-01'::date,
	"archive" int2 NULL DEFAULT 0,
	rrbnr int4 NULL,
	rrb_date date NULL,
	CONSTRAINT aww_gszoar_pkey PRIMARY KEY (ogc_fid)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX aww_gszoar_idx ON afu_gewaesserschutz.aww_gszoar USING gist (wkb_geometry) ;
CREATE INDEX aww_gszoar_ogc_fid_key ON afu_gewaesserschutz.aww_gszoar USING btree (ogc_fid) ;

DROP TABLE IF EXISTS afu_gewaesserschutz.aww_gsab;
CREATE TABLE IF NOT EXISTS afu_gewaesserschutz.aww_gsab (
	ogc_fid serial NOT NULL,
	wkb_geometry geometry(MULTIPOLYGON, 2056) NULL,
	erf_datum int4 NULL,
	"zone" varchar NULL,
	erfasser varchar NULL,
	symbol int4 NULL,
	new_date date NULL DEFAULT 'now'::text::date,
	archive_date date NULL DEFAULT '9999-01-01'::date,
	"archive" int2 NULL DEFAULT 0,
	CONSTRAINT aww_gsab_pkey PRIMARY KEY (ogc_fid)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX aww_gsab_idx ON afu_gewaesserschutz.aww_gsab USING gist (wkb_geometry) ;
CREATE UNIQUE INDEX aww_gsab_ogc_fid_key ON afu_gewaesserschutz.aww_gsab USING btree (ogc_fid) ;
