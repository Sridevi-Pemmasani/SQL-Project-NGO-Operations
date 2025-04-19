/* Additional DDL Statements */
-- Q26: Add a new column Status to the projects table, verify and remove the new column after testing
ALTER TABLE projects ADD Status1 VARCHAR(50);
SELECT * from projects LIMIT 5;
ALTER TABLE projects DROP COLUMN Status1;
SELECT * from projects LIMIT 5;

-- Q27: Create a new table based on other and Drop after testing.
CREATE TABLE staffCopy LIKE staff;
SELECT * FROM staffCopy;
DROP TABLE staffCopy;