CREATE USER u1;
CREATE USER u2;
CREATE USER u3;

CREATE DATABASE d1;
CREATE DATABASE d2;

\c d1 u1
SELECT 'notlogged';
\c d2 u1
SELECT 'notlogged';


\c d1 u2
SELECT 'logged';
\c d2 u2
SELECT 'notlogged';
\c d1 u3
SELECT 'logged';
SELECT 'logged notthatquery';
CREATE TABLE notlogged();
