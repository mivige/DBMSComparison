-- First, let's create the views that were in MySQL as they're useful for optimization and weren't transferred by pgloader

-- Create materialized views instead of regular views for better performance
CREATE MATERIALIZED VIEW mv_unenrolled_students AS
SELECT DISTINCT
    s.dni,
    s.nom,
    s.primer_cognom,
    s.segon_cognom,
    l.MUNICIPI,
    l.CP,
    CAST(REPLACE(l.CP, ' ', '') AS INTEGER) as cp_num
FROM STUDENTS s
LEFT JOIN ENROLLMENTS e ON s.dni = e.dni
JOIN LOCATION l ON s.location_id = l.id
WHERE e.dni IS NULL
WITH DATA;

CREATE MATERIALIZED VIEW mv_centre_locations AS
SELECT 
    c.CODI,
    c.NOM,
    l.MUNICIPI,
    l.CP,
    CAST(REPLACE(l.CP, ' ', '') AS INTEGER) as cp_num
FROM CENTRES c
JOIN LOCATION l ON c.location_id = l.id
WITH DATA;

-- Create indexes on materialized views
CREATE INDEX idx_mv_unenrolled_cp_num ON mv_unenrolled_students(cp_num);
CREATE INDEX idx_mv_centre_cp_num ON mv_centre_locations(cp_num);

-- PostgreSQL-specific optimizations for the queries:

SET max_parallel_workers_per_gather = 4;

-- d. Which students are not enrolled in any subject?
SELECT 
    s.dni,
    s.nom,
    s.primer_cognom,
    s.segon_cognom,
    s.MUNICIPI,
    s.CP,
    s.cp_num
FROM mv_unenrolled_students s
ORDER BY s.primer_cognom, s.nom;

-- e. Based on the previous query, extract the total number.
SELECT COUNT(*) as total_unenrolled_students
FROM mv_unenrolled_students;

-- f. Center recommendations optimization
-- Use PostgreSQL-specific distance calculation and partitioning
WITH RECURSIVE closest_centers AS MATERIALIZED (
    SELECT 
        us.dni,
        us.nom,
        us.primer_cognom,
        us.segon_cognom,
        us.MUNICIPI as student_municipi,
        us.CP as student_cp,
        cl.CODI as centre_code,
        cl.NOM as centre_name,
        cl.MUNICIPI as centre_municipi,
        cl.CP as centre_cp,
        us.MUNICIPI = cl.MUNICIPI as same_municipality,
        ABS(us.cp_num - cl.cp_num) as cp_distance,
        ROW_NUMBER() OVER (
            PARTITION BY us.dni
            ORDER BY 
                (us.MUNICIPI = cl.MUNICIPI) DESC,
                ABS(us.cp_num - cl.cp_num)
        ) as rn
    FROM mv_unenrolled_students us
    CROSS JOIN LATERAL (
        SELECT *
        FROM mv_centre_locations cl
        WHERE ABS(us.cp_num - cl.cp_num) < 5000
        ORDER BY (us.MUNICIPI = cl.MUNICIPI) DESC,
                ABS(us.cp_num - cl.cp_num)
        LIMIT 1
    ) cl
)
SELECT 
    dni,
    nom,
    primer_cognom,
    segon_cognom,
    student_municipi,
    student_cp,
    centre_code,
    centre_name,
    centre_municipi,
    centre_cp,
    CASE 
        WHEN same_municipality THEN 'Same Municipality'
        ELSE 'Different Municipality'
    END as location_type,
    cp_distance
FROM closest_centers;

-- Refresh materialized view function
CREATE OR REPLACE FUNCTION refresh_materialized_views() 
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_unenrolled_students;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_centre_locations;
END;
$$ LANGUAGE plpgsql;