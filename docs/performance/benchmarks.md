# Database Performance Benchmarks

## Test Environment

### Hardware Specifications
- CPU: Intel i5 7200U
- RAM: 16GB
- Storage: SSD

### Dataset Characteristics
- Geographic Scope: Illes Baleares Autonomous Community
- Table Sizes:
  - Centers: 845 records
  - Students: 157,761 records
  - Enrollments: 1,399,925 records

## Performance Metrics

### Query Execution Times

#### Query A: Professional Training Enrollment Analysis
- MySQL: 0.66 seconds
- PostgreSQL: 0.034 seconds
- Improvement: 94.85% faster (19.41x speedup)

#### Query B: Center Saturation Analysis
- MySQL: 2.32 seconds
- PostgreSQL: 0.0007 seconds
- Improvement: 99.97% faster (3,314.29x speedup)

#### Query C: Low Enrollment Subjects
- MySQL: 15.81 seconds
- PostgreSQL: 0.001 seconds
- Improvement: 99.99% faster (15,810x speedup)

#### Query D: Unenrolled Student Identification
- MySQL: 14.65 seconds
- PostgreSQL: 0.030 seconds
- Improvement: 99.80% faster (488.33x speedup)

#### Query E: Unenrolled Student Count
- MySQL: 3.86 seconds
- PostgreSQL: 0.0006 seconds
- Improvement: 99.98% faster (6,433.33x speedup)

#### Query F: Center Recommendation System
- MySQL: 2 minutes 47.71 seconds (167.71 seconds)
- PostgreSQL: 0.100 seconds
- Improvement: 99.94% faster (1,677.1x speedup)

## Test Methodology
- Each query was executed after implementing respective database-specific optimizations
- Times recorded represent the execution duration after optimization implementation
- All queries were run against identical datasets in both systems
- Caches were cleared between runs to ensure consistent measurements