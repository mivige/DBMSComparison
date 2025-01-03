# Database Design Analysis

## 1. Entity Analysis

### 1.1 Centres (Centers)
**Primary Key:** `CODI`
**Attributes:**
- `CODI` (Code) - Unique identifier for each center
- `DENOMINACIÓ GENÈRICA` (Generic Denomination)
- `NOM` (Name)
- `CORREU ELECTRÒNIC 1` (Email 1)
- `CORREU ELECTRÒNIC 2` (Email 2)
- `PÀGINA WEB` (Website)
- `TITULAR` (Owner)
- `NIF` (Tax ID)
- `LOCALITAT` (Location)
- `MUNICIPI` (Municipality)
- `ADREÇA` (Address)
- `CP` (Postal Code)
- `ILLA` (Island)
- `TELEF1` (Phone 1)

**Constraints:**
- `CODI` must be unique and not null
- `NIF` should follow the Spanish tax ID format
- `CP` should be a valid postal code format
- At least one email address should be provided

### 1.2 Students
**Primary Key:** `dni`
**Attributes:**
- `dni` - National ID number
- `nom` (Name)
- `primer_cognom` (First Surname)
- `segon_cognom` (Second Surname)
- `correu_electronic` (Email)
- `codi_postal_i_districte` (Postal Code and District)
- `comunitat_autonoma` (Autonomous Community)
- `municipi` (Municipality)

**Constraints:**
- `dni` must be unique and not null
- `nom`, `primer_cognom` must not be null
- `correu_electronic` must be unique and follow email format
- `codi_postal_i_districte` must follow the special format mentioned

### 1.3 Enrollments (Matriculacions)
**Primary Key:** Composite (`dni`, `nom_assignatura`, `codi_centre`)
**Attributes:**
- `dni` - Student's National ID
- `tipus_ensenyament` (Education Type)
- `modalitat` (Modality)
- `curs` (Course)
- `nom_assignatura` (Subject Name)
- `grup_de_classe` (Class Group)
- `codi_centre` (Center Code)

**Constraints:**
- `dni` must exist in Students table (Foreign Key)
- `codi_centre` must exist in Centres table (Foreign Key)
- Combination of `dni`, `nom_assignatura`, and `codi_centre` must be unique
- All fields except `grup_de_classe` are mandatory

## 2. Relationships

1. **Student-Enrollment Relationship**
   - One-to-Many: A student can have multiple enrollments
   - Mandatory for Enrollment (can't exist without a student)
   - Optional for Student (can exist without enrollments)

2. **Centre-Enrollment Relationship**
   - One-to-Many: A center can have multiple enrollments
   - Mandatory for Enrollment (can't exist without a center)
   - Optional for Centre (can exist without enrollments)

## 3. Additional Considerations

1. **Postal Code and District Format**
   - Special handling needed for `codi_postal_i_districte` in Students table
   - Should be stored in a way that allows efficient querying for proximity-based searches

2. **Academic Year Handling**
   - Although not explicitly in the structure, enrollments are regenerated each academic year
   - Consider adding academic year field for historical tracking

3. **Contact Information**
   - Multiple email addresses for centers
   - Single email for students
   - Phone number format standardization

## 4. Actual ER Diagram

[Mermaid](https://mermaid.live/) code to generate the ER Diagram:

```
erDiagram
    CENTRES {
        string CODI PK
        string DENOMINACIO_GENERICA
        string NOM
        string CORREU_ELECTRONIC_1
        string CORREU_ELECTRONIC_2
        string PAGINA_WEB
        string TITULAR
        string NIF
        string LOCALITAT
        string MUNICIPI
        string ADRECA
        string CP
        string ILLA
        string TELEF1
    }

    STUDENTS {
        string dni PK
        string nom
        string primer_cognom
        string segon_cognom
        string correu_electronic
        string codi_postal_i_districte
        string comunitat_autonoma
        string municipi
    }

    ENROLLMENTS {
        string dni PK, FK
        string tipus_ensenyament
        string modalitat
        string curs
        string nom_assignatura
        string grup_de_classe
        string codi_centre PK, FK
    }

    STUDENTS ||--o{ ENROLLMENTS : "has"
    CENTRES ||--o{ ENROLLMENTS : "hosts"
```

![er-diagram](initial_er_diagram.png)

# Database Normalization

## Current Normalization Issues

1. **In CENTRES table:**
   - Location data (`MUNICIPI`, `CP`, `ILLA`) represents a potential multivalued dependency
   - In some cases one `TITULAR` is the owner of multiple centers
   - Different centers have the same `DENOMINACIO' GENERICA`

2. **In STUDENTS table:**
   - Location data (`comunitat_autonoma`, `municipi`, `codi_postal_i_districte`) represents a potential multivalued dependency

3. **In ENROLLMENTS table:**
   - Academic information (`tipus_ensenyament`, `modalitat`, `curs`, `nom_assignatura`) shows potential partial dependencies

## Normalized Structure

### 1NF (Already Satisfied):
- All attributes are atomic
- No repeating groups
- Primary keys identified

### 2NF and 3NF Normalized Structure:

1. **LOCATION** (Extracted from both CENTRES and STUDENTS)
```sql
Primary Key: (ID)
- ID
- CP
- MUNICIPI
- comunitat_autonoma
Unique (CP, MUNICIPI, comunitat_autonoma)
```

2. **CENTRES**
```sql
Primary Key: CODI
- CODI
- centre_type_id (FK to CENTRE_TYPES)
- NOM
- CORREU_ELECTRÒNIC_1
- CORREU_ELECTRÒNIC_2
- PÀGINA_WEB
- owner_id (FK to OWNERS)
- NIF
- LOCALITAT
- ADREÇA
- location_id (FK to LOCATION)
- island_id (FK to ISLANDS)
- TELEF1
```

3. **STUDENTS**
```sql
Primary Key: dni
- dni
- nom
- primer_cognom
- segon_cognom
- correu_electronic
- districte (split during data insertion to match LOCATION and leave here district)
- location_id (FK to LOCATION)
```

4. **SUBJECTS**
```sql
Primary Key: (id)
- id
- nom_assignatura
- tipus_ensenyament
- modalitat
- curs_year_id (FK to COURSE_YEARS)
Unique (nom_assignatura, tipus_ensenyament, modalitat, curs_year_id)
```

5. **ENROLLMENTS**
```sql
Primary Key: (dni, subject_id, codi_centre)
- dni (FK to STUDENTS)
- subject_id (FK to SUBJECTS)
- codi_centre (FK to CENTRES)
- grup_de_classe
```

6. **ISLANDS**
```sql
Primary Key: (id)
- id
- illa
```

7. **COURSE_YEARS**
```sql
Primary Key: (id)
- id
- curs
```

8. **CENTRE_TYPES**
```sql
Primary Key: (id)
- id
- denominacio_generica
```

6. **OWNERS**
```sql
Primary Key: (id)
- id
- titular
```

## Final ER Diagram

[Mermaid](https://mermaid.live/) code to generate the ER Diagram:

```
erDiagram
    LOCATION {
        int id PK
        string CP
        string MUNICIPI
        string comunitat_autonoma
    }

    ISLANDS {
        int id PK
        string illa
    }

    COURSE_YEARS {
        int id PK
        string curs
    }

    CENTRE_TYPES {
        int id PK
        string DENOMINACIO_GENERICA
    }

    OWNERS {
        int id PK
        string TITULAR
    }

    CENTRES {
        string CODI PK
        int type_id FK
        string NOM
        string CORREU_ELECTRONIC_1
        string CORREU_ELECTRONIC_2
        string PAGINA_WEB
        int owner_id FK
        string NIF
        string LOCALITAT
        string ADRECA
        int location_id FK
        int island_id FK
        string TELEF1
    }

    STUDENTS {
        string dni PK
        string nom
        string primer_cognom
        string segon_cognom
        string correu_electronic
        string districte
        int location_id FK
    }

    SUBJECTS {
        int id PK
        string nom_assignatura
        string tipus_ensenyament
        string modalitat
        int course_year_id FK
    }

    ENROLLMENTS {
        string dni PK, FK
        int subject_id PK, FK
        string codi_centre PK, FK
        string grup_de_classe
    }

    LOCATION ||--o{ CENTRES : "located_in"
    LOCATION ||--o{ STUDENTS : "lives_in"
    ISLANDS ||--o{ CENTRES : "belongs_to"
    CENTRE_TYPES ||--o{ CENTRES : "categorizes"
    OWNERS ||--o{ CENTRES : "owns"
    COURSE_YEARS ||--o{ SUBJECTS : "belongs_to"
    STUDENTS ||--o{ ENROLLMENTS : "has"
    CENTRES ||--o{ ENROLLMENTS : "hosts"
    SUBJECTS ||--o{ ENROLLMENTS : "included_in"
```

![er-diagram](final_er_diagram.png)

## Validation of Normalization:

1. **1NF Compliance:**
   - All attributes are atomic, and there are no repeating groups. ✅

2. **2NF Compliance:**
   - All non-key attributes in each table depend entirely on the primary key. ✅

3. **3NF Compliance:**
   - Transitive dependencies are resolved. ✅

4. **Composite Primary Keys:**
   - The `ENROLLMENTS` table uses a composite primary key (`dni`, `subject_id`, `codi_centre`) to uniquely identify enrollments. ✅

5. **Foreign Key Relationships:**
   - Appropriate relationships are established between normalized tables, such as `location_id` linking `CENTRES` and `STUDENTS` to `LOCATION`. ✅

6. **Handling Multivalued Attributes:**
   - Attributes like `DENOMINACIÓ GENÈRICA` and `TITULAR` are extracted into separate tables (`CENTRE_TYPES` and `OWNERS`). ✅

7. **Redundancy and Consistency:**
   - Separation of `ISLANDS` and `LOCATION` reduces redundancy and improves data integrity. ✅

# SQL Code 
SQL code to generate the final normalized tables:

```sql
-- Create table for LOCATION
CREATE TABLE LOCATION (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cp VARCHAR(10) NOT NULL,
    municipi VARCHAR(100) NOT NULL,
    comunitat_autonoma VARCHAR(100),
    UNIQUE(cp, municipi, comunitat_autonoma)
);

-- Create table for ISLANDS
CREATE TABLE ISLANDS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    illa VARCHAR(100) NOT NULL UNIQUE
);

-- Create table for COURSE_YEARS
CREATE TABLE COURSE_YEARS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    curs VARCHAR(50) NOT NULL UNIQUE
);

-- Create table for CENTRE_TYPES
CREATE TABLE CENTRE_TYPES (
    id INT AUTO_INCREMENT PRIMARY KEY,
    denominacio_generica VARCHAR(100) NOT NULL UNIQUE
);

-- Create table for OWNERS
CREATE TABLE OWNERS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titular VARCHAR(100) NOT NULL UNIQUE
);

-- Create table for CENTRES
CREATE TABLE CENTRES (
    codi VARCHAR(20) PRIMARY KEY,
    type_id INT NOT NULL,
    nom VARCHAR(100) NOT NULL,
    correu_electronic_1 VARCHAR(100) NOT NULL,
    correu_electronic_2 VARCHAR(100),
    pagina_web VARCHAR(255),
    owner_id INT NOT NULL,
    nif VARCHAR(20),
    localitat VARCHAR(100),
    adreca VARCHAR(255),
    location_id INT NOT NULL,
    island_id INT NOT NULL,
    telef1 VARCHAR(20),
    FOREIGN KEY (type_id) REFERENCES CENTRE_TYPES(id),
    FOREIGN KEY (owner_id) REFERENCES OWNERS(id),
    FOREIGN KEY (location_id) REFERENCES LOCATION(id),
    FOREIGN KEY (island_id) REFERENCES ISLANDS(id)
);

-- Create table for STUDENTS
CREATE TABLE STUDENTS (
    dni VARCHAR(20) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    primer_cognom VARCHAR(100) NOT NULL,
    segon_cognom VARCHAR(100),
    correu_electronic VARCHAR(100) UNIQUE NOT NULL,
    districte VARCHAR(50),
    location_id INT NOT NULL,
    FOREIGN KEY (location_id) REFERENCES LOCATION(id)
);

-- Create table for SUBJECTS
CREATE TABLE SUBJECTS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom_assignatura VARCHAR(100) NOT NULL,
    tipus_ensenyament VARCHAR(50) NOT NULL,
    modalitat VARCHAR(50) NOT NULL,
    course_year_id INT NOT NULL,
    UNIQUE(nom_assignatura, tipus_ensenyament, modalitat, course_year_id),
    FOREIGN KEY (course_year_id) REFERENCES COURSE_YEARS(id)
);

-- Create table for ENROLLMENTS
CREATE TABLE ENROLLMENTS (
    dni VARCHAR(20) NOT NULL,
    subject_id INT NOT NULL,
    codi_centre VARCHAR(20) NOT NULL,
    grup_de_classe VARCHAR(50),
    PRIMARY KEY (dni, subject_id, codi_centre),
    FOREIGN KEY (dni) REFERENCES STUDENTS(dni),
    FOREIGN KEY (subject_id) REFERENCES SUBJECTS(id),
    FOREIGN KEY (codi_centre) REFERENCES CENTRES(CODI)
);
```