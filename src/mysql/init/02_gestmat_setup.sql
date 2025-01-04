-- E.
-- Create the tablespace PANDORA
CREATE TABLESPACE PANDORA
    ADD DATAFILE 'PANDORA.ibd'
    ENGINE = InnoDB;

-- Create database GESTMAT
CREATE DATABASE GESTMAT
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
-- In MySQL it isn't possible to set a default tablespace. Any tables created in GESTMAT will need to specify the tablespace explicitly.

-- F. 
-- Create user TRANSFORMADOR_1 and grant necessary privileges
CREATE USER 'TRANSFORMADOR_1'@'localhost' IDENTIFIED BY 'password';

-- Grant privileges to create and insert data in RAW_IMPORT database
GRANT CREATE, INSERT ON GESTMAT.* TO 'TRANSFORMADOR_1'@'localhost';
GRANT SELECT ON RAW_IMPORT.* TO 'TRANSFORMADOR_1'@'localhost';

-- Apply the privileges
FLUSH PRIVILEGES;

-- Now exit and enter with the new created account:
-- mysql> exit
-- C:\Program Files\MySQL\MySQL Server 8.0\bin>mysql -u TRANSFORMADOR_1 -p

USE GESTMAT;
