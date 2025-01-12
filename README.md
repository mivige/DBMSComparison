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
│   │   │   ├── 01_raw_import_setup.sql
│   │   │   └── 02_gestmat_setup.sql
│   │   ├── migrations/
│   │   │   └── 03_raw_to_gestmat.sql
│   │   ├── queries/
│   │   │   └── 04_questions.sql
│   │   └── optimizations/
│   │       └── 05_optimizations.sql
│   └── postgresql/
│       ├── init/
│       │   ├── 06_gestmat_setup.sql
│       │   ├── 07_mysql_to_pg.load     -- Setup file for pgloader
│       │   └── 08_prod_setup.sql
│       ├── migrations/
│       │   └── 
│       ├── queries/
│       │   └── 
│       └── optimizations/
│           └── 
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
├── assignment/
│   ├── Pràctica 2024-25.pdf            -- Assignment requests
│   └── 
├── LICENSE
└── README.md
```