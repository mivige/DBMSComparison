# SQL Queries Documentation

## Overview
This SQL file contains a series of analytical queries focused on educational institution data, specifically examining student enrollments, center capacity, and student distribution. The queries analyze relationships between students, educational centers, subjects, and geographical locations.

## Database Schema Context
The queries operate on a database with the following main tables:
- CENTRES: Educational centers/schools information
- STUDENTS: Student personal and contact information
- ENROLLMENTS: Student enrollment records
- SUBJECTS: Course/subject information
- EDUCATION_TYPES: Categories of education offered
- LOCATION: Geographical location data

## Query Details

### Professional Training Enrollment Analysis
```sql
-- Query a: Center-wise Professional Training enrollment count
```
This query analyzes the distribution of students across centers specifically for Professional Training courses (FPA). It provides:
- Center identification (code and name)
- Count of unique students enrolled in Professional Training
- Results ordered by number of students in descending order

### Center Saturation Analysis
```sql
-- Query b: Center saturation metrics
```
This query evaluates center capacity utilization through multiple metrics:
- Total unique students per center
- Total enrollment records
- Average subjects per student
- Limited to top 10 most saturated centers
The saturation is measured by both total student count and enrollment density.

### Low Enrollment Subject Analysis
```sql
-- Query c: Subjects with fewer than 4 enrolled students
```
This query identifies potentially underutilized courses by:
- Listing subjects with less than 4 enrolled students
- Including associated center information
- Ordered by student count and subject name

### Unenrolled Student Analysis
```sql
-- Queries d and e: Unenrolled student identification and count
```
These complementary queries:
- Identify students not enrolled in any subjects
- Provide detailed student information including contact details and location
- Calculate the total count of unenrolled students

### Center Assignment Recommendation
```sql
-- Query f: Suggested center assignment for unenrolled students
```
This complex query implements a center recommendation system based on:
- Geographic proximity using postal codes
- Municipality matching
- Uses Common Table Expressions (CTEs) for better organization
- Implements a ranking system prioritizing:
  1. Same municipality matches
  2. Closest postal code when municipality differs

## Usage Notes
1. All queries are optimized for analysis and reporting purposes
2. The queries heavily rely on JOIN operations, ensuring referential integrity
3. Geographic proximity calculations are performed using postal code comparisons
4. The results can be used for:
   - Capacity planning
   - Enrollment optimization
   - Geographic distribution analysis
   - Student outreach programs

## Performance Considerations
- The center assignment recommendation query (f) uses a CROSS JOIN operation, which should be monitored for performance with large datasets
- Queries include appropriate grouping and filtering to minimize data processing overhead
- Indexes on dni, codi_centre, and location-related columns would optimize performance