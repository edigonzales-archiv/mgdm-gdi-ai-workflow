DELETE FROM afu_gewaesserschutz_export.gsbereiche_gsbereich;

WITH gszustr AS
(
  SELECT 
    ogc_fid, 
    wkb_geometry, 
    typ, 
    "name"
  FROM 
    afu_gewaesserschutz.aww_gszustr 
  WHERE 
    archive = 0 and im_kanton = 1
)
,
singlepoly_gszu AS 
(
  SELECT
    ogc_fid,
    coalesce((((dump).path)[1]),0) AS partindex,
    (dump).geom AS singlepoly
  FROM 
  (
    SELECT 
      ST_Dump(wkb_geometry) AS dump, 
      ogc_fid 
    FROM gszustr
  ) AS dump
)
,
fields_gszustr AS -- gwsbereich felder gemappt aus aww_gszoar
(
  SELECT 
    ogc_fid, 
    CASE
      WHEN trim(typ) = 'Zo' THEN 'Zo'
      WHEN trim(typ) = 'Zu' THEN 'Zu'
      ELSE 'Umbauproblem: Nicht behandelte Codierung von Attibut [typ]'
    END AS typ,
    concat('Name: ', name) AS bemerkungen,
    typ AS kantonale_bezeichnung    
  FROM 
    gszustr
)
,
gsab AS
(
  SELECT 
    ogc_fid, 
    wkb_geometry, 
    "zone", 
    erfasser
  FROM 
    afu_gewaesserschutz.aww_gsab 
  WHERE 
    archive = 0
)
,
singlepoly_gsab AS 
(
  SELECT
    ogc_fid,
    coalesce((((dump).path)[1]),0) AS partindex,
    (dump).geom AS singlepoly
  FROM 
  (
    SELECT 
      ST_Dump(wkb_geometry) AS dump, 
      ogc_fid 
    FROM 
      gsab
  ) AS dump
)
,
fields_gsab AS -- gwsbereich felder gemappt aus aww_gszoar
(
  SELECT 
    ogc_fid, 
    CASE
      WHEN trim(zone) = 'B' THEN 'UB'
      WHEN trim(zone) = 'O' THEN 'Ao'
      WHEN trim(zone) = 'U' THEN 'Au'
      ELSE 'Umbauproblem: Nicht behandelte Codierung von Attibut [zone]'
    END AS typ,
    concat('Erfasser: ', erfasser) AS bemerkungen,
    "zone" AS kantonale_bezeichnung   
  from gsab
)
,
unionall as
(
  SELECT 
    fields_gszustr.ogc_fid, 
    typ, 
    bemerkungen, 
    kantonale_bezeichnung,
    partindex, 
    singlepoly
  FROM 
    fields_gszustr
    INNER JOIN singlepoly_gszu  
    ON fields_gszustr.ogc_fid = singlepoly_gszu.ogc_fid
  UNION ALL 
  SELECT 
    fields_gsab.ogc_fid, 
    typ, 
    bemerkungen, 
    kantonale_bezeichnung, 
    partindex, 
    singlepoly
  FROM 
    fields_gsab
    INNER JOIN singlepoly_gsab 
    ON fields_gsab.ogc_fid = singlepoly_gsab.ogc_fid
)
,
gwsbereich AS
(
  SELECT
    nextval('afu_gewaesserschutz_export.t_ili2db_seq') as tid,
    concat(ogc_fid,'-',partindex) as identifier, 
    ogc_fid, 
    typ, 
    bemerkungen, 
    kantonale_bezeichnung,
    singlepoly
  FROM 
    unionall
)
INSERT INTO 
    afu_gewaesserschutz_export.gsbereiche_gsbereich(t_id, identifikator, typ, geometrie)
(
	SELECT 
		tid,
		identifier, 
		typ, 
		singlepoly
	FROM 
        gwsbereich
);