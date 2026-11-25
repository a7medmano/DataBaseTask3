-- 1. Create a new database named "CompanyDB."  (named company DB 2 here)
CREATE DATABASE companyDB2;
GO
USE companyDB2;
GO

-- 2. Create a schema named "Sales" within the database.
CREATE SCHEMA Sales;
GO

-- 3. Create a table named "employees" with columns:
--    employee_id (INT) - use sequence instead of identity,
--    first_name (VARCHAR), last_name (VARCHAR), salary (DECIMAL)
--    Within the "Sales" schema.
CREATE SEQUENCE Sales.seq_employee_id AS INT START WITH 1 INCREMENT BY 1;
GO

CREATE TABLE Sales.employees (
    employee_id INT NOT NULL
        CONSTRAINT PK_employees PRIMARY KEY
        CONSTRAINT DF_employees_id DEFAULT (NEXT VALUE FOR Sales.seq_employee_id),
    first_name  VARCHAR(100)  NOT NULL,
    last_name   VARCHAR(100)  NOT NULL,
    salary      DECIMAL(10,2) NOT NULL
);
GO

-- 4. Alter the "employees" table to add a new column named "hire_date"

ALTER TABLE Sales.employees ADD hire_date DATE NULL;
GO

--   SLIDE 4 - DATA MANIPULATION EXERCISES 

-- Q1: Select all columns from the "employees" table.
SELECT * FROM Sales.employees;

-- Q2: Retrieve only the "first_name" and "last_name" columns from the "employees" table
SELECT first_name, last_name FROM Sales.employees;

-- Q3: Retrieve "full name" as a one column from "first_name" and "last_name" columns from the "employees" table
 
SELECT first_name + ' ' + last_name AS full_name FROM Sales.employees;

-- Q4: Show the average salary of all employees. (Use AVG() function)
SELECT AVG(salary) AS avg_salary FROM Sales.employees;

-- Q5: Select employees whose salary is greater than 50000.
SELECT * FROM Sales.employees WHERE salary > 50000;

-- Q6: Retrieve employees hired in the year 2020.
SELECT * FROM Sales.employees
WHERE hire_date >= '2020-01-01' AND hire_date < '2021-01-01';

-- Q7: List employees whose last names start with 'S'.
SELECT * FROM Sales.employees WHERE last_name LIKE 'S%';

-- Q8: Display the top 10 highest-paid employees.
SELECT TOP 10 * FROM Sales.employees ORDER BY salary DESC, employee_id;

-- Q9: Find employees with salaries between 40000 and 60000.
SELECT * FROM Sales.employees WHERE salary BETWEEN 40000 AND 60000;

-- Q10: Show employees with names containing the substring 'man'.
SELECT * FROM Sales.employees
WHERE first_name LIKE '%man%' OR last_name LIKE '%man%';

-- Q11: Display employees with a NULL value in the "hire_date" column.
SELECT * FROM Sales.employees WHERE hire_date IS NULL;

-- Q12: Select employees with a salary in the set (40000, 45000, 50000).
SELECT * FROM Sales.employees WHERE salary IN (40000, 45000, 50000);

-- Q13: Retrieve employees hired between '2020-01-01' and '2021-01-01'.
SELECT * FROM Sales.employees
WHERE hire_date BETWEEN '2020-01-01' AND '2021-01-01';

-- Q14: List employees with salaries in descending order.
SELECT * FROM Sales.employees ORDER BY salary DESC;

--   SLIDE 5 - DATA MANIPULATION EXERCISES
-- Q15: Show the first 5 employees ordered by "last_name" in ascending order.
SELECT TOP 5 * FROM Sales.employees ORDER BY last_name ASC, employee_id;

-- Q16: Display employees with a salary greater than 55000 and hired in 2020.
SELECT * FROM Sales.employees
WHERE salary > 55000
  AND hire_date >= '2020-01-01' AND hire_date < '2021-01-01';

-- Q17: Select employees whose first name is 'John' or 'Jane'.
SELECT * FROM Sales.employees WHERE first_name IN ('John', 'Jane');

-- Q18: List employees with a salary <= 55000 and a hire date after '2022-01-01'.
SELECT * FROM Sales.employees
WHERE salary <= 55000 AND hire_date > '2022-01-01';

-- Q19: Retrieve employees with a salary greater than the average salary.
SELECT * FROM Sales.employees
WHERE salary > (SELECT AVG(salary) FROM Sales.employees);

-- Q20: Display the 3rd to 7th highest-paid employees. (Use OFFSET and FETCH)
SELECT * FROM Sales.employees
ORDER BY salary DESC, employee_id
OFFSET 2 ROWS FETCH NEXT 5 ROWS ONLY;

-- Q21: List employees hired after '2021-01-01' in alphabetical order.
SELECT * FROM Sales.employees
WHERE hire_date > '2021-01-01'
ORDER BY last_name, first_name;

-- Q22: Retrieve employees with a salary > 50000 and last name not starting
--      with 'A'.
SELECT * FROM Sales.employees
WHERE salary > 50000 AND last_name NOT LIKE 'A%';

-- Q23: Display employees with a salary that is not NULL.
SELECT * FROM Sales.employees WHERE salary IS NOT NULL;

-- Q24: Show employees with names containing 'e' or 'i' and a salary > 45000.
SELECT * FROM Sales.employees
WHERE (first_name LIKE '%e%' OR first_name LIKE '%i%'
    OR last_name  LIKE '%e%' OR last_name  LIKE '%i%')
  AND salary > 45000;
GO


--   SLIDE 6 - JOIN-RELATED EXERCISES 
-- Q25: Create a new table named "departments" with columns:
--      department_id (Primary Key, INT)
CREATE TABLE Sales.departments (
    department_id   INT NOT NULL CONSTRAINT PK_departments PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    manager_id      INT NULL,
    CONSTRAINT FK_departments_manager
        FOREIGN KEY (manager_id) REFERENCES Sales.employees(employee_id)
);
GO

-- Q26: Assign each employee to a department by creating a "department_id"
--      column in "employees" and making it a foreign key referencing "departments".department_id     
ALTER TABLE Sales.employees ADD department_id INT NULL;
GO
ALTER TABLE Sales.employees
    ADD CONSTRAINT FK_employees_department
    FOREIGN KEY (department_id) REFERENCES Sales.departments(department_id);
GO

-- (sample departments, my choice; every employee is assigned to one of them, so Q28 returns 0 rows)

INSERT INTO Sales.departments (department_id, department_name, manager_id)
VALUES (1, 'Operations', NULL), (2, 'Sales', NULL), (3, 'IT', NULL);
GO
WITH ranked AS (
    SELECT employee_id, ROW_NUMBER() OVER (ORDER BY employee_id) AS rn
    FROM Sales.employees
)
UPDATE e SET department_id = ((r.rn - 1) % 3) + 1
FROM Sales.employees e JOIN ranked r ON r.employee_id = e.employee_id;
GO

-- Q27: Retrieve all employees with their department names (Use INNER JOIN).
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM Sales.employees e
INNER JOIN Sales.departments d ON e.department_id = d.department_id;

-- Q28: Retrieve employees who don't belong to any department  (Use LEFT JOIN and check for NULL).

SELECT e.*
FROM Sales.employees e
LEFT JOIN Sales.departments d ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- Q29: Show all departments and their employee count (Use JOIN and GROUP BY).
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS employee_count
FROM Sales.departments d
LEFT JOIN Sales.employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- Q30: Retrieve the highest-paid employee in each department (Use JOIN and MAX(salary)).   
SELECT d.department_name, e.first_name, e.last_name, e.salary
FROM Sales.employees e
INNER JOIN Sales.departments d ON e.department_id = d.department_id
INNER JOIN (
    SELECT department_id, MAX(salary) AS max_salary
    FROM Sales.employees
    GROUP BY department_id
) m ON m.department_id = e.department_id AND m.max_salary = e.salary;
GO


--   SLIDE 2 - DATA MANIPULATION QUESTIONS

CREATE TABLE dbo.Employees (
    Id       INT NOT NULL PRIMARY KEY,
    Name     VARCHAR(201)  NOT NULL,
    Salary   DECIMAL(10,2) NOT NULL,
    DeptName VARCHAR(100)  NOT NULL
);
GO
INSERT INTO dbo.Employees (Id, Name, Salary, DeptName)
SELECT e.employee_id, e.first_name + ' ' + e.last_name, e.salary, d.department_name
FROM Sales.employees e
INNER JOIN Sales.departments d ON e.department_id = d.department_id;
GO

-- Q1: Select all columns from the "Employees" table.
SELECT * FROM dbo.Employees;

-- Q2: Select only the "Name" and "Salary" columns from the "Employees" table.
SELECT Name, Salary FROM dbo.Employees;

-- Q3: Select distinct values of the "DeptName" column from the "Employees" table.
SELECT DISTINCT DeptName FROM dbo.Employees;

-- Q4: Select the top 5 records from the "Employees" table.
SELECT TOP 5 * FROM dbo.Employees;

-- Q5: Select all records from the "Employees" table, ordered by the "Salary" column in descending order.
SELECT * FROM dbo.Employees ORDER BY Salary DESC;

-- Q6: Select the first 10 records from the "Employees" table, starting from the third record.
SELECT * FROM dbo.Employees
ORDER BY Id
OFFSET 2 ROWS FETCH NEXT 10 ROWS ONLY;

-- Q7: Select the average salary from the "Employees" table. (search on it)
SELECT AVG(Salary) AS AverageSalary FROM dbo.Employees;

-- Q8: Select the maximum and minimum salaries from the "Employees" table.
 
SELECT MAX(Salary) AS MaxSalary, MIN(Salary) AS MinSalary FROM dbo.Employees;

-- Q9: Select the top 3 highest salaries from the "Employees" table.
SELECT TOP 3 Salary FROM dbo.Employees ORDER BY Salary DESC;

-- Q10: Select all records from the "Employees" table, ordered by "Name" in ascending order.
     
SELECT * FROM dbo.Employees ORDER BY Name ASC;

-- Q11: Select the first 5 records from the "Employees" table, starting from the second record, ordered by "Salary" in descending order.
    
SELECT * FROM dbo.Employees
ORDER BY Salary DESC
OFFSET 1 ROWS FETCH NEXT 5 ROWS ONLY;

-- Q12: Select the sum of all salaries from the "Employees" table. (search on it)
SELECT SUM(Salary) AS TotalSalaries FROM dbo.Employees;

-- Q13: Select records from the "Employees" table where the "Salary" is between 40000 and 60000, ordered by "Salary" in ascending order.
    
SELECT * FROM dbo.Employees
WHERE Salary BETWEEN 40000 AND 60000
ORDER BY Salary ASC;
GO


  -- SLIDE 7 - STORED PROCEDURES AND TRIGGER (own schema "Hr" so the tables do not clash with the ones above)

CREATE SCHEMA Hr;
GO

-- Part 1: Create a table Employees with columns: Id, FirstName, LastName, Salary.
CREATE TABLE Hr.Employees (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(100)  NOT NULL,
    LastName  VARCHAR(100)  NOT NULL,
    Salary    DECIMAL(10,2) NOT NULL
);
GO

-- Part 1 / 1-: Create a stored procedure named Get AllEmployees that selects  all rows from Employees.
CREATE PROCEDURE Hr.GetAllEmployees
AS
BEGIN
    SELECT * FROM Hr.Employees;
END;
GO

-- Part 1 / 2-: Create a stored procedure GetHighSalaryEmployees with one input
-- parameter @MinSalary which selects all employees with  Salary > @MinSalary.
CREATE PROCEDURE Hr.GetHighSalaryEmployees
    @MinSalary DECIMAL(10,2)
AS
BEGIN
    SELECT * FROM Hr.Employees WHERE Salary > @MinSalary;
END;
GO

-- Part 1 / 3-: Create AddEmployee SP with @FirstName, @LastName, @Salary which,inserts a new row into Employees.

CREATE PROCEDURE Hr.AddEmployee
    @FirstName VARCHAR(100),
    @LastName  VARCHAR(100),
    @Salary    DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Hr.Employees (FirstName, LastName, Salary)
    VALUES (@FirstName, @LastName, @Salary);
END;
GO

-- Part 2: Create a table EmployeeLog(Id, EmployeeId, Action, ActionDate).
CREATE TABLE Hr.EmployeeLog (
    Id         INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeId INT         NOT NULL,
    Action     VARCHAR(50) NOT NULL,
    ActionDate DATETIME    NOT NULL DEFAULT GETDATE()
);
GO

-- Part 2: Create AFTER INSERT Trigger which automatically logs when a newe mployee is added.
CREATE TRIGGER Hr.trg_Employees_AfterInsert
ON Hr.Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO Hr.EmployeeLog (EmployeeId, Action, ActionDate)
    SELECT Id, 'INSERT', GETDATE() FROM inserted;
END;
GO