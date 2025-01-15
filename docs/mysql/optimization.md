# SQL Performance Optimization Documentation

## Overview
This documentation covers performance improvements made to a set of analytical queries focused on educational data. The optimizations include strategic indexing, view creation, and query restructuring to enhance execution efficiency while maintaining accurate results.

## Index Optimizations

### Global Index Strategy
Several composite and single-column indexes have been created to support efficient query execution:

```sql
-- Enrollment Related
CREATE INDEX idx_enrollments_composite ON ENROLLMENTS(codi_centre, dni);
CREATE INDEX idx_enrollments_composite2 ON ENROLLMENTS(codi_centre, dni, subject_id);
CREATE INDEX idx_enrollments_centre ON ENROLLMENTS(codi_centre);
CREATE INDEX idx_enrollments_subject ON ENROLLMENTS(subject_id);
CREATE INDEX idx_enrollments_student ON ENROLLMENTS(dni);

-- Location Related
CREATE INDEX idx_location_municipi ON LOCATION(MUNICIPI);
CREATE INDEX idx_location_cp ON LOCATION(CP);
CREATE INDEX idx_location_municipi_cp ON LOCATION(MUNICIPI, CP);
CREATE INDEX idx_location_student ON LOCATION(id);

-- Education Related
CREATE INDEX idx_education_type ON EDUCATION_TYPES(tipus_ensenyament);
CREATE INDEX idx_subjects_education ON SUBJECTS(education_type_id);

-- Centre Related
CREATE INDEX idx_centres_location ON CENTRES(location_id);
CREATE INDEX idx_centres_location_composite ON CENTRES(location_id, CODI);

-- Student Related
CREATE INDEX idx_students_enrollment ON STUDENTS(dni);
```

## Query-Specific Optimizations

### Professional Training Enrollment Query
The optimization focuses on reducing the JOIN overhead by:
- Using a subquery to pre-filter relevant enrollments
- Leveraging composite indexes for efficient data access
- Maintaining only necessary columns in the result set

### Saturated Centers Analysis
Performance improvements include:
- Implementation of a CTE for better query organization
- Early filtering using a student threshold
- Optimized aggregation through proper indexing
- Reduced data volume before final calculations

### Low Enrollment Subjects
Enhancements made through:
- Pre-aggregation in a CTE to reduce data volume
- Filtering before joining with larger tables
- Optimized join order based on data selectivity

### Center Recommendation System
Major architectural improvements include:

#### Base Views Creation
```sql
CREATE VIEW v_unenrolled_students AS
-- Pre-filtered student data with location information

CREATE VIEW v_centre_locations AS
-- Centralized center location data

CREATE VIEW v_student_centre_distances AS
-- Distance calculations with early filtering

CREATE VIEW v_recommended_centres AS
-- Final ranking system with optimized sort criteria
```

#### Key Optimizations
- Implementation of materialized location data
- Pre-calculation of postal code numbers
- Distance-based filtering to reduce CROSS JOIN impact
- Efficient ranking system using window functions

## Performance Considerations

### Data Volume Management
- Early filtering implemented where possible
- Use of CTEs for better query optimization
- Strategic placement of WHERE clauses before JOIN operations

### Memory Usage
- Reduced duplicate data processing through views
- Optimized JOIN operations with proper indexes
- Limited result sets where appropriate

### Maintenance Requirements
Regular maintenance tasks should include:
- Index statistics updates
- View refresh scheduling
- Performance monitoring of materialized data
- Regular validation of distance calculation thresholds

## Usage Guidelines
To maintain optimal performance:
1. Ensure indexes are regularly maintained
2. Monitor view refresh performance
3. Adjust distance thresholds based on data distribution
4. Validate performance with varying data volumes

These optimizations significantly improve query performance while maintaining data accuracy and system reliability.