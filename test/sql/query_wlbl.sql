--logged
CREATE USER u1;
--logged
CREATE USER u2;
--logged
CREATE USER u3;
--logged
CREATE USER u4;
--logged
CREATE USER pasmoi;
--logged
CREATE DATABASE db1;
--logged
CREATE DATABASE db2;
--logged
CREATE DATABASE db3;
--logged
CREATE DATABASE db4;
\c db1 u1
SELECT 'db1 u1';
\c db2 u2
--logged
SELECT 'db2 u2';
\c db3 u3
--logged
SELECT 'db3 u3';
\c db4 u4
--logged
SELECT 'db4 u4';
\c postgres pasmoi
--logged
SELECT 'postgres pasmoi';
BEGIN;
COMMIT;
