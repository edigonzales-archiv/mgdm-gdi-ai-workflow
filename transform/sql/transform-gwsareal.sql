DELETE FROM afu_gewaesserschutz_export.gwszonen_gwsareal;

WITH afu_gszoar AS
(
  SELECT 
    ogc_fid, 
    "zone", 
    rrbnr, 
    rrb_date, 
    wkb_geometry
  FROM 
    afu_gewaesserschutz.aww_gszoar
  WHERE 
    archive = 0 AND zone = 'SARE'
)
,
singlepolygon as 
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
      afu_gszoar
  ) AS dump
)
,
areal_fields AS -- gwsareal felder gemappt aus aww_gszoar
(
  SELECT 
    ogc_fid, 
    'Areal' AS typ, 
    CASE
      WHEN rrb_date < to_date('1999-01-01', 'YYYY-MM-DD') THEN true
      ELSE false
    END AS ist_altrechtlich,
    concat('RRB: ', rrbnr) as bemerkungen,
    'inKraft' AS stat_rechtsstatus,
    rrb_date AS stat_rechtskraftsdatum
  FROM
  afu_gszoar
)
,
gwsareal AS
(
  SELECT 
    nextval('afu_gewaesserschutz_export.t_ili2db_seq') AS tid_gwsareal,
    nextval('afu_gewaesserschutz_export.t_ili2db_seq') AS tid_status,
    concat(singlepolygon.ogc_fid,'-', partindex) AS identifier, 
    typ, 
    ist_altrechtlich, 
    bemerkungen,
    stat_rechtsstatus,
    stat_rechtskraftsdatum,
    singlepoly
  FROM 
    areal_fields
    INNER JOIN singlepolygon 
    ON areal_fields.ogc_fid = singlepolygon.ogc_fid
)
,
insert_status AS
(
  INSERT INTO afu_gewaesserschutz_export.gwszonen_status 
  (
    t_id, 
    rechtsstatus, 
    rechtskraftdatum
  )
  (
    SELECT 
      tid_status, 
      stat_rechtsstatus, 
      stat_rechtskraftsdatum 
    FROM 
      gwsareal
  )
)
INSERT INTO afu_gewaesserschutz_export.gwszonen_gwsareal
(
  t_id, identifikator, 
  typ, 
  istaltrechtlich, 
  status, 
  geometrie
)
(
  SELECT
    tid_gwsareal, 
    identifier, 
    typ, 
    ist_altrechtlich, 
    tid_status, 
    singlepoly 
  FROM 
    gwsareal
);
