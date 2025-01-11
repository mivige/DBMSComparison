-- J. Implement improvements for previoue queries 

-- Query A: Centers with Professional Training enrollments
-- Current performance issues:
-- 1. Multiple JOINs without proper indexing
-- Improvements:
CREATE INDEX idx_education_type ON EDUCATION_TYPES(tipus_ensenyament);
CREATE INDEX idx_enrollments_composite ON ENROLLMENTS(codi_centre, dni);
CREATE INDEX idx_subjects_education ON SUBJECTS(education_type_id);

-- Optimized query:
SELECT 
    c.CODI,
    c.NOM as centre_name,
    COUNT(DISTINCT e.dni) as num_students
FROM CENTRES c
JOIN (
    SELECT DISTINCT codi_centre, dni 
    FROM ENROLLMENTS e2
    JOIN SUBJECTS s ON e2.subject_id = s.id
    JOIN EDUCATION_TYPES et ON s.education_type_id = et.id
    WHERE et.tipus_ensenyament = 'FPA'
) e ON c.CODI = e.codi_centre
GROUP BY c.CODI, c.NOM
ORDER BY num_students DESC;

-- Query B: Saturated centers
-- Current performance issues:
-- 1. Counting operations on large JOIN results
-- 2. No limiting of initial dataset before aggregation
-- Improvements:
CREATE INDEX idx_enrollments_centre ON ENROLLMENTS(codi_centre);
CREATE INDEX idx_enrollments_composite2 ON ENROLLMENTS(codi_centre, dni, subject_id);

-- Optimized query:
WITH StudentCounts AS (
    SELECT 
        codi_centre,
        COUNT(DISTINCT dni) as total_students,
        COUNT(*) as total_enrollments
    FROM ENROLLMENTS
    GROUP BY codi_centre
    HAVING total_students > 100  -- Add threshold to filter early
)
SELECT 
    c.CODI,
    c.NOM as centre_name,
    sc.total_students,
    sc.total_enrollments,
    (sc.total_enrollments * 1.0 / sc.total_students) as avg_subjects_per_student
FROM StudentCounts sc
JOIN CENTRES c ON c.CODI = sc.codi_centre
ORDER BY sc.total_students DESC, sc.total_enrollments DESC
LIMIT 10;

-- Query C: Subjects with < 4 users
-- Current performance issues:
-- 1. Multiple JOINs before grouping
-- 2. No early filtering
-- Improvements:
CREATE INDEX idx_enrollments_subject ON ENROLLMENTS(subject_id);

-- Optimized query:
WITH SubjectCounts AS (
    SELECT 
        subject_id,
        codi_centre,
        COUNT(DISTINCT dni) as num_students
    FROM ENROLLMENTS
    GROUP BY subject_id, codi_centre
    HAVING num_students < 4
)
SELECT 
    s.nom_assignatura,
    c.CODI as centre_code,
    c.NOM as centre_name,
    sc.num_students
FROM SubjectCounts sc
JOIN SUBJECTS s ON s.id = sc.subject_id
JOIN CENTRES c ON c.CODI = sc.codi_centre
ORDER BY sc.num_students, s.nom_assignatura;

-- Query D & E: Unenrolled students
-- Current performance issues:
-- 1. LEFT JOIN without proper indexing
-- 2. Potential full table scan
-- Improvements:
CREATE INDEX idx_students_enrollment ON STUDENTS(dni);
CREATE INDEX idx_location_student ON LOCATION(id);

-- Query F: Center recommendations
-- Current performance issues:
-- 1. CROSS JOIN creates huge result set
-- 2. Complex calculations in ORDER BY
-- 3. String to number conversions in ordering
-- Improvements:
CREATE INDEX idx_location_municipi ON LOCATION(MUNICIPI);
CREATE INDEX idx_location_cp ON LOCATION(CP);
CREATE INDEX idx_centres_location ON CENTRES(location_id);
CREATE INDEX idx_location_municipi_cp ON LOCATION(MUNICIPI, CP);
CREATE INDEX idx_centres_location_composite ON CENTRES(location_id, CODI);
CREATE INDEX idx_enrollments_student ON ENROLLMENTS(dni);


-- Base view for unenrolled students with their location data
CREATE VIEW v_unenrolled_students AS
SELECT DISTINCT
    s.dni,
    s.nom,
    s.primer_cognom,
    s.segon_cognom,
    l.MUNICIPI,
    l.CP,
    CAST(REPLACE(l.CP, ' ', '') AS SIGNED) as cp_num
FROM STUDENTS s
LEFT JOIN ENROLLMENTS e ON s.dni = e.dni
JOIN LOCATION l ON s.location_id = l.id
WHERE e.dni IS NULL;

-- Base view for centres with their location data
CREATE VIEW v_centre_locations AS
SELECT 
    c.CODI,
    c.NOM,
    l.MUNICIPI,
    l.CP,
    CAST(REPLACE(l.CP, ' ', '') AS SIGNED) as cp_num
FROM CENTRES c
JOIN LOCATION l ON c.location_id = l.id;

-- View that contains all possible student-centre matches with their distances
CREATE VIEW v_student_centre_distances AS
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
    (us.MUNICIPI = cl.MUNICIPI) as same_municipality,
    ABS(us.cp_num - cl.cp_num) as cp_distance
FROM v_unenrolled_students us
CROSS JOIN v_centre_locations cl
WHERE ABS(us.cp_num - cl.cp_num) <= 5000;  -- Distance limit to reduce rows

-- View with the final ranked results
CREATE VIEW v_recommended_centres AS
SELECT 
    *,
    ROW_NUMBER() OVER (
        PARTITION BY dni
        ORDER BY 
            same_municipality DESC,
            cp_distance
    ) as rn
FROM v_student_centre_distances;

-- Final simple query
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
    CASE WHEN same_municipality THEN 'Same Municipality'
         ELSE 'Different Municipality'
    END as location_type,
    cp_distance
FROM v_recommended_centres
WHERE rn = 1;