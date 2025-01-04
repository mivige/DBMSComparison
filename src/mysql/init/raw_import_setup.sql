-- A. 
-- Create the tablespace DADES_TEMPORALS
CREATE TABLESPACE DADES_TEMPORALS
    ADD DATAFILE 'DADES_TEMPORALS.ibd'
    ENGINE = InnoDB;

-- Create database RAW_IMPORT
CREATE DATABASE RAW_IMPORT
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
-- In MySQL it isn't possible to set a default tablespace. Any tables created in RAW_IMPORT will need to specify the tablespace explicitly.

-- B.
-- Create user IMPORTADOR_1 and grant necessary privileges
CREATE USER 'IMPORTADOR_1'@'localhost' IDENTIFIED BY 'password';

-- Grant privileges to create and insert data in RAW_IMPORT database
GRANT CREATE, INSERT ON RAW_IMPORT.* TO 'IMPORTADOR_1'@'localhost';

-- Apply the privileges
FLUSH PRIVILEGES;

-- Grant files privileges to import from the csv files.
GRANT FILE ON *.* TO 'IMPORTADOR_1'@'localhost';
FLUSH PRIVILEGES;


-- Now exit and enter with the new created account:
-- mysql> exit
-- C:\Program Files\MySQL\MySQL Server 8.0\bin>mysql -u IMPORTADOR_1 -p

USE RAW_IMPORT;

-- C. Create the three tables matching the original file structure
CREATE TABLE centers (
    CODI VARCHAR(20) PRIMARY KEY,
    DENOMINACIO_GENERICA VARCHAR(100),
    NOM VARCHAR(256),
    CORREU_ELECTRONIC_1 VARCHAR(100),
    CORREU_ELECTRONIC_2 VARCHAR(100),
    PAGINA_WEB VARCHAR(255),
    TITULAR VARCHAR(100),
    NIF VARCHAR(20),
    LOCALITAT VARCHAR(100),
    MUNICIPI VARCHAR(100),
    ADRECA VARCHAR(255),
    CP VARCHAR(10),
    ILLA VARCHAR(100),
    TELEF1 VARCHAR(20)
) TABLESPACE DADES_TEMPORALS;

CREATE TABLE students (
    dni VARCHAR(20) PRIMARY KEY,
    nom VARCHAR(100),
    primer_cognom VARCHAR(100),
    segon_cognom VARCHAR(100),
    correu_electronic VARCHAR(100),
    codi_postal_i_districte VARCHAR(50),
    comunitat_autonoma VARCHAR(100),
    municipi VARCHAR(100)
) TABLESPACE DADES_TEMPORALS;

CREATE TABLE enrollments (
    dni VARCHAR(20),
    tipus_ensenyament VARCHAR(50),
    modalitat VARCHAR(50),
    curs VARCHAR(50),
    nom_assignatura VARCHAR(100),
    grup_de_classe VARCHAR(50),
    codi_centre VARCHAR(20),
    PRIMARY KEY (dni, tipus_ensenyament, modalitat, curs, nom_assignatura, grup_de_classe, codi_centre)
) TABLESPACE DADES_TEMPORALS;

-- D. Import data from files
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/centres.csv'
INTO TABLE centers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/estudiants.csv'
INTO TABLE students
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/matricules_202425.csv'
IGNORE INTO TABLE enrollments -- Some duplicates exist in the csv, with the IGNORE option we ignore duplicates.
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 