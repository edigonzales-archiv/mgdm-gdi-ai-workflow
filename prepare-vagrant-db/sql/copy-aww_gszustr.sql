SELECT
	ogc_fid,
	ST_Multi(wkb_geometry) AS wkb_geometry,
	"name",
	im_kanton,
	typ,
	"archive",
	archive_date,
	new_date
FROM 
    public.aww_gszustr
;