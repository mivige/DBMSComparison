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