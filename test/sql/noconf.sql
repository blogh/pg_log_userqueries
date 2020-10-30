-- logged
CREATE USER normal WITH LOGIN;
--logged
CREATE USER su WITH LOGIN SUPERUSER;
--logged
SELECT 1;
\c postgres normal
--notloggeed
SELECT 2;
\c postgres su
--logged
SELECT 3;
