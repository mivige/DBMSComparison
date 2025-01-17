-- I. SQL Queries
USE GESTMAT;

-- a. Which centers have users enrolled in Professional Training courses, and how many?
-- (Quins centres tenen usuaris matriculats a assignatures de Formació Professional, i quina quantitat?)
SELECT 
    c.CODI,
    c.NOM as centre_name,
    COUNT(DISTINCT e.dni) as num_students
FROM CENTRES c
JOIN ENROLLMENTS e ON c.CODI = e.codi_centre
JOIN SUBJECTS s ON e.subject_id = s.id
JOIN EDUCATION_TYPES et ON s.education_type_id = et.id
WHERE et.tipus_ensenyament = 'FPA'
GROUP BY c.CODI, c.NOM
ORDER BY num_students DESC;

-- b. Show the most saturated centers. Demonstrate with data.
-- (Mostreu els centres més saturats. Demostreu-ho amb dades. Per saturació s’entén com el cúmul d’estudiants que van al centre.)
SELECT 
    c.CODI,
    c.NOM as centre_name,
    COUNT(DISTINCT e.dni) as total_students,
    COUNT(e.subject_id) as total_enrollments,
    COUNT(e.subject_id) / COUNT(DISTINCT e.dni) as avg_subjects_per_student
FROM CENTRES c
JOIN ENROLLMENTS e ON c.CODI = e.codi_centre
GROUP BY c.CODI
ORDER BY total_students DESC, total_enrollments DESC
LIMIT 10;

-- c. Which subjects have less than 4 enrolled users? Also extract the center data where the subject is taught.
-- (Quines assignatures tenen menys de 4 usuaris matriculats? Extreure també les dades del centre on es dóna l'assignatura.)
SELECT 
    s.nom_assignatura,
    c.CODI as centre_code,
    c.NOM as centre_name,
    COUNT(DISTINCT e.dni) as num_students
FROM SUBJECTS s
JOIN ENROLLMENTS e ON s.id = e.subject_id
JOIN CENTRES c ON e.codi_centre = c.CODI
GROUP BY s.id, s.nom_assignatura, c.CODI, c.NOM
HAVING num_students < 4
ORDER BY num_students, s.nom_assignatura;

-- d. Which students are not enrolled in any subject?
-- (Quins estudiants no estan matriculats a cap assignatura?)
SELECT 
    s.dni,
    s.nom,
    s.primer_cognom,
    s.segon_cognom,
    s.correu_electronic,
    l.MUNICIPI,
    l.CP,
    s.districte
FROM STUDENTS s
LEFT JOIN ENROLLMENTS e ON s.dni = e.dni
LEFT JOIN LOCATION l ON s.location_id = l.id
WHERE e.dni IS NULL
ORDER BY s.primer_cognom, s.nom;

-- e. Based on the previous query, extract the total number.
-- (Basant-t'he amb la sentència anterior, extreure el número total.)
SELECT COUNT(*) as total_unenrolled_students
FROM STUDENTS s
LEFT JOIN ENROLLMENTS e ON s.dni = e.dni
WHERE e.dni IS NULL;

-- f. Which center should each unenrolled student attend? The premise will be based on the proximity of the center to the student's place of residence.
-- (En quin centre hauria d'anar cada un dels estudiants que no estan matriculats?)
WITH UnenrolledStudents AS (
    SELECT 
        s.dni,
        s.nom,
        s.primer_cognom,
        s.segon_cognom,
        l.MUNICIPI as student_municipi,
        l.CP as student_cp
    FROM STUDENTS s
    LEFT JOIN ENROLLMENTS e ON s.dni = e.dni
    LEFT JOIN LOCATION l ON s.location_id = l.id
    WHERE e.dni IS NULL
),
RankedCenters AS (
    SELECT 
        us.dni,
        us.nom,
        us.primer_cognom,
        us.segon_cognom,
        us.student_municipi,
        us.student_cp,
        c.CODI as centre_code,
        c.NOM as centre_name,
        c.LOCALITAT as centre_locality,
        l.CP as centre_cp,
        ROW_NUMBER() OVER (
            PARTITION BY us.dni 
            ORDER BY 
                CASE WHEN us.student_municipi = l.municipi THEN 1 ELSE 2 END,  -- Priority: Same municipality
                ABS(CAST(us.student_cp AS SIGNED) - CAST(l.CP AS SIGNED))      -- Fallback: Closest postal code
        ) as row_num
    FROM UnenrolledStudents us
    CROSS JOIN CENTRES c
    JOIN LOCATION l ON c.location_id = l.id
)
SELECT 
    rc.dni,
    rc.nom,
    rc.primer_cognom,
    rc.segon_cognom,
    rc.student_municipi,
    rc.student_cp,
    rc.centre_code,
    rc.centre_name,
    rc.centre_locality,
    rc.centre_cp
FROM RankedCenters rc
WHERE rc.row_num = 1; -- Select only the top-ranked center for each student
