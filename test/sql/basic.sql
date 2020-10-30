-- logged
CREATE USER displayed_user;
-- logged
CREATE USER undisplayed_user;
-- logged
CREATE DATABASE test_loguq WITH OWNER displayed_user;

\c test_loguq displayed_user
-- logged
CREATE TABLE test_table(i int);
-- logged
INSERT INTO test_table(i) SELECT x FROM generate_series(1, 1000000) AS F(x);
--logged
VACUUM test_table;
--logged
ANALYZE test_table;
--logged
VACUUM FULL test_table;
-- logged
SET parallel_setup_cost TO '0.0001';
-- logged
SET parallel_tuple_cost TO '0.0001';
-- logged
SELECT avg(i) FROM test_table;
-- logged
EXPLAIN SELECT 1;
-- logged
EXPLAIN ANALYZE SELECT 1;
-- logged
EXPLAIN ANALYZE SELECT avg(i) FROM test_table; 
-- logged
ALTER TABLE test_table ADD CONSTRAINT pk_test_table PRIMARY KEY (i);
-- logged
DROP TABLE test_table;

\c postgres undisplayed_user
-- not logged
SELECT 1;

\c test_loguq undisplayed_user
-- logged
SELECT 1;

\c postgres postgres
-- logged
DROP DATABASE test_loguq;
-- logged
DROP USER displayed_user;
-- logged
DROP USER undisplayed_user;
