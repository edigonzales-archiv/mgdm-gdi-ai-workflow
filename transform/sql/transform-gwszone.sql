DELETE FROM afu_gewaesserschutz_export.gwszonen_gwszone;

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
    archive = 0 AND zone != 'SARE'
)
,
singlepolygon AS 
(
  SELECT
    ogc_fid,
    coalesce((((dump).path)[1]),0) as partindex,
    (dump).geom AS geo
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
zone_fields AS -- gwszone felder gemappt aus aww_gszoar
(
  SELECT 
    ogc_fid, 
    CASE
      WHEN trim(zone) = 'GZ1' THEN 'S1'
      WHEN trim(zone) = 'GZ2' THEN 'S2'
      WHEN trim(zone) = 'GZ2B' THEN 'S2'
      WHEN trim(zone) = 'GZ3' THEN 'S3'
      ELSE 'Umbauproblem: Nicht behandelte Codierung von Attibut [zone]'
    END AS typ,
    "zone" AS typ_kantonal, 
    CASE
      WHEN rrb_date < to_date('1999-01-01', 'YYYY-MM-DD') THEN true
      ELSE false
    END AS ist_altrechtlich,
    concat('RRB: ', rrbnr) AS bemerkungen,
    'inKraft' AS stat_rechtsstatus,
    rrb_date AS stat_rechtskraftsdatum
  FROM 
    afu_gszoar
)
,
gwszone AS
(
  SELECT 
    nextval('afu_gewaesserschutz_export.t_ili2db_seq') AS tid_gwszone,
    nextval('afu_gewaesserschutz_export.t_ili2db_seq') AS tid_status,
    concat(singlepolygon.ogc_fid,'-',partindex) AS identifier, 
    typ,
    typ_kantonal,
    ist_altrechtlich,
    bemerkungen,
    stat_rechtsstatus,
    stat_rechtskraftsdatum,
    geo as singlepoly
  FROM 
    zone_fields
    INNER JOIN singlepolygon 
    ON zone_fields.ogc_fid = singlepolygon.ogc_fid
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
    FROM gwszone
  )
)
INSERT INTO afu_gewaesserschutz_export.gwszonen_gwszone
(
  t_id, 
  identifikator, 
  typ, 
  istaltrechtlich, 
  status, 
  geometrie
)
(
  SELECT 
    tid_gwszone, 
    identifier, 
    typ, 
    ist_altrechtlich, 
    tid_status, 
    singlepoly 
  FROM 
    gwszone
);

