-- 8. Data migration from OLDGESTMAT to PROD schema
-- Connect as UCONSELLERIA:
-- postgres=# exit
-- mivige@mivige-VirtualBox:~$ psql -U uconselleria -d gestmat

-- Set search path to include both schemas
SET search_path TO PROD, OLDGESTMAT;

-- Transfer data from OLDGESTMAT to PROD for each table in the correct order to maintain referential integrity

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
-- Create a comprehensive verification function that checks all tables
CREATE OR REPLACE FUNCTION verify_table_counts() RETURNS TABLE (
    table_name text,
    oldgestmat_count bigint,
    prod_count bigint,
    is_equal boolean
) AS $$
BEGIN
    RETURN QUERY

    -- AUTONOMOUS_COMMUNITIES verification
    SELECT 
        'AUTONOMOUS_COMMUNITIES'::text,
        (SELECT count(*) FROM OLDGESTMAT.AUTONOMOUS_COMMUNITIES),
        (SELECT count(*) FROM PROD.AUTONOMOUS_COMMUNITIES),
        (SELECT count(*) FROM OLDGESTMAT.AUTONOMOUS_COMMUNITIES) = 
        (SELECT count(*) FROM PROD.AUTONOMOUS_COMMUNITIES)
    
    UNION ALL
    
    -- LOCATION verification
    SELECT 
        'LOCATION'::text,
        (SELECT count(*) FROM OLDGESTMAT.LOCATION),
        (SELECT count(*) FROM PROD.LOCATION),
        (SELECT count(*) FROM OLDGESTMAT.LOCATION) = 
        (SELECT count(*) FROM PROD.LOCATION)
    
    UNION ALL
    
    -- ISLANDS verification
    SELECT 
        'ISLANDS'::text,
        (SELECT count(*) FROM OLDGESTMAT.ISLANDS),
        (SELECT count(*) FROM PROD.ISLANDS),
        (SELECT count(*) FROM OLDGESTMAT.ISLANDS) = 
        (SELECT count(*) FROM PROD.ISLANDS)
    
    UNION ALL
    
    -- COURSE_YEARS verification
    SELECT 
        'COURSE_YEARS'::text,
        (SELECT count(*) FROM OLDGESTMAT.COURSE_YEARS),
        (SELECT count(*) FROM PROD.COURSE_YEARS),
        (SELECT count(*) FROM OLDGESTMAT.COURSE_YEARS) = 
        (SELECT count(*) FROM PROD.COURSE_YEARS)
    
    UNION ALL
    
    -- EDUCATION_TYPES verification
    SELECT 
        'EDUCATION_TYPES'::text,
        (SELECT count(*) FROM OLDGESTMAT.EDUCATION_TYPES),
        (SELECT count(*) FROM PROD.EDUCATION_TYPES),
        (SELECT count(*) FROM OLDGESTMAT.EDUCATION_TYPES) = 
        (SELECT count(*) FROM PROD.EDUCATION_TYPES)
    
    UNION ALL
    
    -- MODALITIES verification
    SELECT 
        'MODALITIES'::text,
        (SELECT count(*) FROM OLDGESTMAT.MODALITIES),
        (SELECT count(*) FROM PROD.MODALITIES),
        (SELECT count(*) FROM OLDGESTMAT.MODALITIES) = 
        (SELECT count(*) FROM PROD.MODALITIES)
    
    UNION ALL
    
    -- CENTRE_TYPES verification
    SELECT 
        'CENTRE_TYPES'::text,
        (SELECT count(*) FROM OLDGESTMAT.CENTRE_TYPES),
        (SELECT count(*) FROM PROD.CENTRE_TYPES),
        (SELECT count(*) FROM OLDGESTMAT.CENTRE_TYPES) = 
        (SELECT count(*) FROM PROD.CENTRE_TYPES)
    
    UNION ALL
    
    -- OWNERS verification
    SELECT 
        'OWNERS'::text,
        (SELECT count(*) FROM OLDGESTMAT.OWNERS),
        (SELECT count(*) FROM PROD.OWNERS),
        (SELECT count(*) FROM OLDGESTMAT.OWNERS) = 
        (SELECT count(*) FROM PROD.OWNERS)
    
    UNION ALL
    
    -- CENTRES verification
    SELECT 
        'CENTRES'::text,
        (SELECT count(*) FROM OLDGESTMAT.CENTRES),
        (SELECT count(*) FROM PROD.CENTRES),
        (SELECT count(*) FROM OLDGESTMAT.CENTRES) = 
        (SELECT count(*) FROM PROD.CENTRES)
    
    UNION ALL
    
    -- STUDENTS verification
    SELECT 
        'STUDENTS'::text,
        (SELECT count(*) FROM OLDGESTMAT.STUDENTS),
        (SELECT count(*) FROM PROD.STUDENTS),
        (SELECT count(*) FROM OLDGESTMAT.STUDENTS) = 
        (SELECT count(*) FROM PROD.STUDENTS)
    
    UNION ALL
    
    -- SUBJECTS verification
    SELECT 
        'SUBJECTS'::text,
        (SELECT count(*) FROM OLDGESTMAT.SUBJECTS),
        (SELECT count(*) FROM PROD.SUBJECTS),
        (SELECT count(*) FROM OLDGESTMAT.SUBJECTS) = 
        (SELECT count(*) FROM PROD.SUBJECTS)
    
    UNION ALL
    
    -- ENROLLMENTS verification
    SELECT 
        'ENROLLMENTS'::text,
        (SELECT count(*) FROM OLDGESTMAT.ENROLLMENTS),
        (SELECT count(*) FROM PROD.ENROLLMENTS),
        (SELECT count(*) FROM OLDGESTMAT.ENROLLMENTS) = 
        (SELECT count(*) FROM PROD.ENROLLMENTS);
END;
$$ LANGUAGE plpgsql;

-- Example of how to use the verification function:
SELECT 
    table_name,
    oldgestmat_count,
    prod_count,
    CASE 
        WHEN is_equal THEN 'OK'
        ELSE 'MISMATCH!'
    END as status
FROM verify_table_counts()
ORDER BY table_name;

-- 9. Cleanup after verification
-- Drop the verification function
DROP FUNCTION verify_table_counts();

-- Connect as admin:
-- gestmat=> exit
-- mivige@mivige-VirtualBox:~$ sudo -u postgres psql

-- a. Drop OLDGESTMAT schema
DROP SCHEMA OLDGESTMAT CASCADE;
ALTER DATABASE GESTMAT SET search_path TO prod, public;

-- b. Drop UDATAMOVEMENT user
REVOKE ALL ON DATABASE GESTMAT FROM UDATAMOVEMENT;
DROP USER UDATAMOVEMENT;