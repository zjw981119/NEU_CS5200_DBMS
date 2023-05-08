-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

/* Student, Jinwei Zhang -- CS5200.38915.202330, Spring 2023 */

# 1. Find the distinct number of workers who work in the HR department 
# and who earn more than ₹250,000.
SELECT COUNT(*) FROM Worker
  WHERE department = 'HR'
  AND salary > 250000;

# 2. Find the last name and title of all workers 
# and the department they work in who earn less than the average salary.
SELECT w.last_name, t.worker_title, w.department, w.salary
  FROM Worker AS w
  INNER JOIN Title AS t ON w.worker_id = t.WORKER_REF_ID
  WHERE w.salary < (SELECT AVG(salary) FROM Worker);

# 3. What is the average salary paid for all workers in each department? 
# List the department, the average salary for the department, and the number of workers in each department. 
# Name the average column 'AvgSal' and the number of workers column to 'Num'.
SELECT department, AVG(salary) AS Avgsal, COUNT(*) AS NUM
  FROM Worker
  GROUP BY department;

# 4. What is the total compensation for each worker (salary and bonus) on a per monthly basis? 
# List the name of the worker, their title, 
# and the their monthly compensation (annual compensation divided by 12).
# Change the header for compensation to 'MonthlyComp' and round it to the nearest whole number.
SELECT w.WORKER_ID, w.first_name, w.last_name, t.worker_title, 
	(w.salary + IFNULL(b.bonus, 0)) / 12 AS MonthlyComp 
    FROM Worker AS w
    INNER JOIN Title AS t ON w.WORKER_ID = t.WORKER_REF_ID
    LEFT JOIN (SELECT SUM(bonus_amount) AS bonus, worker_ref_id FROM Bonus
              	GROUP BY worker_ref_id) AS b ON w.WORKER_ID = b.worker_ref_id;
    
# 5. List the full names of all workers in all capital letters who did not get a bonus.
SELECT UPPER(last_name || " " || first_name) AS FULLNAME FROM Worker
	WHERE worker_id NOT IN(SELECT worker_ref_id FROM Bonus);

# 6. What are the full names of all workers who have 'Manager' in their title. 
# Do not "hard code" the titles; use string searching. 
SELECT UPPER(last_name || " " || first_name) AS FULLNAME, t.WORKER_TITLE AS TITLE
	FROM Worker AS w
	INNER JOIN Title AS t ON w.WORKER_ID = t.WORKER_REF_ID
	WHERE t.WORKER_TITLE LIKE '%Manager%';