# DBMSComparison
A comprehensive database system for managing educational enrollment data, featuring dual implementation in MySQL and PostgreSQL with optimized querying and migration utilities.

```
DBMSComparison/
├── docs/
│   ├── design/
│   │   ├── db_design_analysis.md
│   │   ├── initial_er_diagram.png
│   │   └── final_er_diagram.png
│   ├── mysql/
│   │   ├── optimization.md
│   │   └── queries.md
│   ├── postgresql/
│   │   ├── optimization.md
│   │   └── queries.md
│   └── performance/
│       ├── benchmarks.md
│       └── comparison_results.md
├── src/
│   ├── mysql/
│   │   ├── init/
│   │   │   ├── 01_create_databases.sql
│   │   │   ├── 02_create_users.sql
│   │   │   └── 03_create_tables.sql
│   │   ├── migrations/
│   │   │   └── raw_to_gestmat.sql
│   │   ├── queries/
│   │   │   └── analysis_queries.sql
│   │   └── optimizations/
│   │       └── indexes.sql
│   └── postgresql/
│       ├── init/
│       │   ├── 01_create_databases.sql
│       │   ├── 02_create_users.sql
│       │   └── 03_create_tables.sql
│       ├── migrations/
│       │   └── mysql_to_postgresql.sql
│       ├── queries/
│       │   └── analysis_queries.sql
│       └── optimizations/
│           └── indexes.sql
├── data/
│   ├── centers.csv
│   ├── students.zip
│   └── enrollments.zip
├── tests/
│   ├── mysql/
│   │   ├── migration_tests.sql
│   │   └── query_tests.sql
│   └── postgresql/
│       ├── migration_tests.sql
│       └── query_tests.sql
├── utils/
│   ├── performance_testing/
│   │   └── benchmark_script.py
│   └── scripts/
│       ├── setup_environment.sh
│       └── run_tests.sh
├── LICENSE
├── README.md
└── requirements.txt
```