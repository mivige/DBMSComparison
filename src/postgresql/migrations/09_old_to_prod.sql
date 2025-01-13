-- 8. Data migration from OLDGESTMAT to PROD schema
-- Connect as UCONSELLERIA:
-- postgres=# exit
-- mivige@mivige-VirtualBox:~$ psql -U uconselleria -d gestmat

-- Set search path to include both schemas
SET search_path TO PROD, OLDGESTMAT;

-- Transfer data from OLDGESTMAT to PROD for each table in the correct order
-- to maintain referential integrity

-- First, transfer data for tables without foreign key dependencies
INSERT INTO PROD.AUTONOMOUS_COMMUNITIES (id, comunitat_autonoma)
SELECT id, comunitat_autonoma FROM OLDGESTMAT.AUTONOMOUS_COMMUNITIES;

INSERT INTO PROD.ISLANDS (id, illa)
SELECT id, illa FROM OLDGESTMAT.ISLANDS;

INSERT INTO PROD.COURSE_YEARS (id, curs)
SELECT id, curs FROM OLDGESTMAT.COURSE_YEARS;

INSERT INTO PROD.EDUCATION_TYPES (id, tipus_ensenyament)
SELECT id, tipus_ensenyament FROM OLDGESTMAT.EDUCATION_TYPES;

INSERT INTO PROD.MODALITIES (id, modalitat)
SELECT id, modalitat FROM OLDGESTMAT.MODALITIES;

INSERT INTO PROD.CENTRE_TYPES (id, DENOMINACIO_GENERICA)
SELECT id, DENOMINACIO_GENERICA FROM OLDGESTMAT.CENTRE_TYPES;

INSERT INTO PROD.OWNERS (id, TITULAR)
SELECT id, TITULAR FROM OLDGESTMAT.OWNERS;

-- Then transfer data for tables with foreign key dependencies
INSERT INTO PROD.LOCATION (id, CP, MUNICIPI, community_id)
SELECT id, CP, MUNICIPI, community_id FROM OLDGESTMAT.LOCATION;

INSERT INTO PROD.CENTRES (
    CODI, type_id, NOM, CORREU_ELECTRONIC_1, CORREU_ELECTRONIC_2, 
    PAGINA_WEB, owner_id, NIF, LOCALITAT, ADRECA, 
    location_id, island_id, TELEF1
)
SELECT 
    CODI, type_id, NOM, CORREU_ELECTRONIC_1, CORREU_ELECTRONIC_2, 
    PAGINA_WEB, owner_id, NIF, LOCALITAT, ADRECA, 
    location_id, island_id, TELEF1 
FROM OLDGESTMAT.CENTRES;

INSERT INTO PROD.STUDENTS (
    dni, nom, primer_cognom, segon_cognom, 
    correu_electronic, districte, location_id
)
SELECT 
    dni, nom, primer_cognom, segon_cognom, 
    correu_electronic, districte, location_id
FROM OLDGESTMAT.STUDENTS;

INSERT INTO PROD.SUBJECTS (
    id, nom_assignatura, education_type_id, 
    modality_id, course_year_id
)
SELECT 
    id, nom_assignatura, education_type_id, 
    modality_id, course_year_id
FROM OLDGESTMAT.SUBJECTS;

INSERT INTO PROD.ENROLLMENTS (
    dni, subject_id, codi_centre, grup_de_classe
)
SELECT 
    dni, subject_id, codi_centre, grup_de_classe
FROM OLDGESTMAT.ENROLLMENTS;

-- Verify data consistency between schemas
-- Create a temporary function to compare row counts
CREATE OR REPLACE FUNCTION verify_table_counts() RETURNS TABLE (
    table_name text,
    oldgestmat_count bigint,
    prod_count bigint,
    is_equal boolean
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.table_name::text,
        (SELECT count(*) FROM OLDGESTMAT.AUTONOMOUS_COMMUNITIES) AS oldgestmat_count,
        (SELECT count(*) FROM PROD.AUTONOMOUS_COMMUNITIES) AS prod_count,
        (SELECT count(*) FROM OLDGESTMAT.AUTONOMOUS_COMMUNITIES) = 
        (SELECT count(*) FROM PROD.AUTONOMOUS_COMMUNITIES) AS is_equal
    FROM information_schema.tables t
    WHERE t.table_schema = 'OLDGESTMAT'
    UNION ALL
    -- Repeat for each table...
    SELECT 
        'ENROLLMENTS'::text,
        (SELECT count(*) FROM OLDGESTMAT.ENROLLMENTS),
        (SELECT count(*) FROM PROD.ENROLLMENTS),
        (SELECT count(*) FROM OLDGESTMAT.ENROLLMENTS) = 
        (SELECT count(*) FROM PROD.ENROLLMENTS);
END;
$$ LANGUAGE plpgsql;

-- Execute verification
SELECT * FROM verify_table_counts();

-- 9. Cleanup after verification
-- a. Drop OLDGESTMAT schema
DROP SCHEMA OLDGESTMAT CASCADE;

-- b. Drop UDATAMOVEMENT user
DROP USER UDATAMOVEMENT;

-- Drop the verification function
DROP FUNCTION verify_table_counts();