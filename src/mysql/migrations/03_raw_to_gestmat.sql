-- H. Data transfer from RAW_IMPORT to GESTMAT
USE GESTMAT;

-- First, populate all lookup tables
-- Autonomous Communities (The centers don't specify the community but they're all in Illes Balears)
INSERT INTO AUTONOMOUS_COMMUNITIES (comunitat_autonoma)
VALUES ('Illes Balears');

-- Import unique communities from students
INSERT IGNORE INTO AUTONOMOUS_COMMUNITIES (comunitat_autonoma)
SELECT DISTINCT comunitat_autonoma 
FROM RAW_IMPORT.students 
WHERE comunitat_autonoma IS NOT NULL;

-- Populate ISLANDS from centers
INSERT INTO ISLANDS (illa)
SELECT DISTINCT ILLA 
FROM RAW_IMPORT.centers 
WHERE ILLA IS NOT NULL;

-- Populate CENTRE_TYPES from centers
INSERT INTO CENTRE_TYPES (DENOMINACIO_GENERICA)
SELECT DISTINCT DENOMINACIO_GENERICA 
FROM RAW_IMPORT.centers 
WHERE DENOMINACIO_GENERICA IS NOT NULL;

-- Populate OWNERS from centers
INSERT INTO OWNERS (TITULAR)
SELECT DISTINCT TITULAR 
FROM RAW_IMPORT.centers 
WHERE TITULAR IS NOT NULL;

-- Populate EDUCATION_TYPES from enrollments
INSERT INTO EDUCATION_TYPES (tipus_ensenyament)
SELECT DISTINCT tipus_ensenyament 
FROM RAW_IMPORT.enrollments 
WHERE tipus_ensenyament IS NOT NULL;

-- Populate MODALITIES from enrollments
INSERT INTO MODALITIES (modalitat)
SELECT DISTINCT modalitat 
FROM RAW_IMPORT.enrollments 
WHERE modalitat IS NOT NULL;

-- Populate COURSE_YEARS from enrollments
INSERT INTO COURSE_YEARS (curs)
SELECT DISTINCT curs 
FROM RAW_IMPORT.enrollments 
WHERE curs IS NOT NULL;

-- Populate LOCATION table
-- First from centers
INSERT INTO LOCATION (CP, MUNICIPI, community_id)
SELECT DISTINCT c.CP, c.MUNICIPI, ac.id
FROM RAW_IMPORT.centers c
CROSS JOIN AUTONOMOUS_COMMUNITIES ac 
WHERE ac.comunitat_autonoma = 'Illes Balears'
AND c.CP IS NOT NULL 
AND c.MUNICIPI IS NOT NULL;

-- Then from students
INSERT IGNORE INTO LOCATION (CP, MUNICIPI, community_id)
SELECT DISTINCT 
    SUBSTRING(s.codi_postal_i_districte, 1, 5),
    s.municipi,
    ac.id
FROM RAW_IMPORT.students s
JOIN AUTONOMOUS_COMMUNITIES ac ON ac.comunitat_autonoma = s.comunitat_autonoma
WHERE s.codi_postal_i_districte IS NOT NULL 
AND s.municipi IS NOT NULL;

-- Populate CENTRES
INSERT INTO CENTRES
SELECT 
    TRIM(LEADING '0' FROM c.CODI) as CODI,
    ct.id as type_id,
    c.NOM,
    c.CORREU_ELECTRONIC_1,
    c.CORREU_ELECTRONIC_2,
    c.PAGINA_WEB,
    o.id as owner_id,
    c.NIF,
    c.LOCALITAT,
    c.ADRECA,
    l.id as location_id,
    i.id as island_id,
    c.TELEF1
FROM RAW_IMPORT.centers c
JOIN CENTRE_TYPES ct ON ct.DENOMINACIO_GENERICA = c.DENOMINACIO_GENERICA
JOIN OWNERS o ON o.TITULAR = c.TITULAR
JOIN LOCATION l ON l.CP = c.CP AND l.MUNICIPI = c.MUNICIPI
JOIN ISLANDS i ON i.illa = c.ILLA;

-- Populate STUDENTS
INSERT INTO STUDENTS
SELECT 
    s.dni,
    s.nom,
    s.primer_cognom,
    s.segon_cognom,
    s.correu_electronic,
    SUBSTRING(s.codi_postal_i_districte, 6, 2) as districte,
    l.id as location_id
FROM RAW_IMPORT.students s
JOIN LOCATION l ON l.CP = SUBSTRING(s.codi_postal_i_districte, 1, 5) 
    AND l.MUNICIPI = s.municipi;

-- Populate SUBJECTS
INSERT INTO SUBJECTS (nom_assignatura, education_type_id, modality_id, course_year_id)
SELECT DISTINCT
    e.nom_assignatura,
    et.id as education_type_id,
    m.id as modality_id,
    cy.id as course_year_id
FROM RAW_IMPORT.enrollments e
JOIN EDUCATION_TYPES et ON et.tipus_ensenyament = e.tipus_ensenyament
JOIN MODALITIES m ON m.modalitat = e.modalitat
JOIN COURSE_YEARS cy ON cy.curs = e.curs;

-- Finally, populate ENROLLMENTS
INSERT INTO ENROLLMENTS
SELECT 
    e.dni,
    s.id as subject_id,
    e.codi_centre,
    e.grup_de_classe
FROM RAW_IMPORT.enrollments e
JOIN SUBJECTS s ON s.nom_assignatura = e.nom_assignatura
JOIN EDUCATION_TYPES et ON et.tipus_ensenyament = e.tipus_ensenyament 
    AND et.id = s.education_type_id
JOIN MODALITIES m ON m.modalitat = e.modalitat 
    AND m.id = s.modality_id
JOIN COURSE_YEARS cy ON cy.curs = e.curs 
    AND cy.id = s.course_year_id;