# 📊 DBMSComparison

**🚀 Built for:**  
*Database Management Systems (Sistemes de Gestiò de Bases de Dades) – University of the Balearic Islands (UIB)*  
📚 **Course Year:** 2024/25  
🧑‍💻 **Author:** Michele Vincenzo Gentile 

---

A comparative analysis of MySQL and PostgreSQL database management systems for handling academic enrollment data, designed as part of a university project. This repository includes scripts, documentation, and benchmarks to explore and optimize database design, migration, and query performance.

---

## 🌟 Project Features

- **Database Design**: Normalized schema creation based on CSV input files.
- **MySQL Implementation**: 
  - Database creation, optimization, and query handling.
  - Performance tuning and benchmarking.
- **PostgreSQL Implementation**: 
  - Data migration using `pgloader`.
  - Schema setup, optimizations, and query handling.
- **Performance Comparison**: Detailed analysis of query performance between MySQL and PostgreSQL.

---

## 📁 Directory Structure

```plaintext
DBMSComparison/
├── docs/                  # Documentation and design materials
│   ├── design/            # Database design details
│   │   ├── db_design_analysis.md
│   │   ├── initial_er_diagram.png
│   │   └── final_er_diagram.png
│   ├── mysql/             # MySQL-specific documentation
│   │   ├── optimization.md
│   │   └── queries.md
│   ├── postgresql/        # PostgreSQL-specific documentation
│   │   ├── optimization.md
│   │   └── queries.md
│   └── performance/       # Performance evaluation
│       ├── benchmarks.md
│       └── results_comparison.md
├── src/                   # SQL scripts
│   ├── mysql/             # MySQL implementation
│   │   ├── init/          # Initial setup scripts
│   │   ├── migrations/    # Data migration scripts
│   │   ├── queries/       # Query examples
│   │   └── optimizations/ # Optimization scripts
│   └── postgresql/        # PostgreSQL implementation
│       ├── init/          # Initial setup scripts
│       ├── migrations/    # Data migration scripts
│       ├── queries/       # Query examples
│       └── optimizations/ # Optimization scripts
├── data/                  # Data files
│   ├── centers.csv
│   ├── students.zip
│   └── enrollments.zip
├── tests/                 # Test scripts for validation
│   ├── mysql/             # MySQL-specific tests
│   └── postgresql/        # PostgreSQL-specific tests
├── assignment/            # Assignment documentation
│   ├── Pràctica 2024-25.pdf
│   └── 
├── LICENSE                # Project license
└── README.md              # Project readme (this file)
```

---

## 🛠️ Getting Started

### Prerequisites

- **MySQL** (v8.0 or higher)
- **PostgreSQL** (v14 or higher)
- **pgloader** for data migration

### Setup Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/mivige/DBMSComparison.git
   cd DBMSComparison
   ```
2. Extract data files:
   ```bash
   cd data/
   unzip students.zip
   unzip enrollments.zip
   ```
3. Follow the `docs/design/db_design_analysis.md` for schema setup guidance.

---

## 🚀 How to Use

### MySQL

1. Import all the files following the order:
   ```bash
   mysql < src/mysql/init/01_raw_import_setup.sql
   ```
   ```bash
   mysql < src/mysql/init/02_gestmat_setup.sql
   ```
   ```bash
   mysql < src/mysql/migrations/03_raw_to_gestmat.sql
   ```
2. Execute queries:
   ```bash
   mysql < src/mysql/queries/04_questions.sql
   ```

### PostgreSQL

1. Set up the database:
   ```bash
   psql -f src/postgresql/init/06_gestmat_setup.sql
   ```
2. Migrate data from MySQL:
   ```bash
   pgloader src/postgresql/init/07_mysql_to_pg.load
   ```
3. Migrate data to Prod DB:
   ```bash
   psql -f src/postgresql/init/08_prod_setup.sql
   ```
   ```bash
   psql -f src/postgresql/migrations/09_old_to_prod.sql
   ```
4. Execute queries:
   ```bash
   psql -f src/postgresql/queries/10_questions.sql
   ```

---

## 📈 Performance Evaluation

Performance benchmarks and comparison results are documented in:
- `docs/performance/benchmarks.md`
- `docs/performance/results_comparison.md`

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).