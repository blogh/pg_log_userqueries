CREATE USER u1;
CREATE USER u2;
CREATE USER u3;
CREATE USER u4;
CREATE USER pasmoi;
CREATE DATABASE db1;
CREATE DATABASE db2;
CREATE DATABASE db3;
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
SELECT 'postgres pasmoi';
BEGIN;
COMMIT;
