-- ============================================================
-- Employee Attrition Analysis — SQL Queries
-- Tools: MySQL | Dataset: IBM HR Analytics Employee Attrition
-- ============================================================

-- Setup: create database and load employees, compensation,
-- and performance tables (imported via CSV, linked by EmployeeNumber)
CREATE DATABASE hr_attrition;

-- ------------------------------------------------------------
-- Sanity checks: confirm each table imported correctly
-- ------------------------------------------------------------
SELECT * FROM hr_attrition.employees LIMIT 5;
SELECT * FROM hr_attrition.compensation LIMIT 5;
SELECT * FROM hr_attrition.performance LIMIT 5;

-- Confirm the join across all 3 tables works with no NULLs
SELECT e.EmployeeNumber, e.Department, c.MonthlyIncome, p.JobSatisfaction, e.Attrition
FROM hr_attrition.employees e
JOIN hr_attrition.compensation c ON e.EmployeeNumber = c.EmployeeNumber
JOIN hr_attrition.performance p ON e.EmployeeNumber = p.EmployeeNumber
LIMIT 10;

-- ------------------------------------------------------------
-- Q1: Where is attrition happening?
-- Uses a CTE to stage department totals before calculating rate
-- ------------------------------------------------------------
WITH dept_attrition AS (
    SELECT Department, COUNT(*) AS total, SUM(Attrition) AS left_count
    FROM hr_attrition.employees
    GROUP BY Department
)
SELECT Department, total, left_count,
       ROUND(left_count * 100.0 / total, 2) AS attrition_rate_pct
FROM dept_attrition
ORDER BY attrition_rate_pct DESC;

-- Finding: Sales has the highest attrition rate (20.63%),
-- ahead of HR (19.05%) and R&D (13.84%)

-- ------------------------------------------------------------
-- Q2: Why is it happening? Is overtime a driver?
-- Splits attrition rate by Department AND OverTime
-- ------------------------------------------------------------
SELECT Department, OverTime,
       COUNT(*) AS total,
       SUM(Attrition) AS left_count,
       ROUND(SUM(Attrition) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition.employees
GROUP BY Department, OverTime
ORDER BY Department, attrition_rate_pct DESC;

-- Finding: in every department, employees working overtime
-- left at roughly 2-3x the rate of those who didn't
-- (Sales: 37.50% vs 13.84% | R&D: 27.31% vs 8.55% | HR: 29.41% vs 15.22%)

-- ------------------------------------------------------------
-- Q2 (continued): Is the overtime effect actually a pay problem?
-- Checks average income and satisfaction among employees who left
-- ------------------------------------------------------------
SELECT e.Department, e.OverTime,
       ROUND(AVG(c.MonthlyIncome), 0) AS avg_income,
       ROUND(AVG(p.JobSatisfaction), 2) AS avg_satisfaction
FROM hr_attrition.employees e
JOIN hr_attrition.compensation c ON e.EmployeeNumber = c.EmployeeNumber
JOIN hr_attrition.performance p ON e.EmployeeNumber = p.EmployeeNumber
WHERE e.Attrition = 1
GROUP BY e.Department, e.OverTime
ORDER BY e.Department, avg_income;

-- Finding: overtime leavers were NOT underpaid relative to
-- non-overtime leavers (in Sales, overtime leavers earned MORE
-- on average) — ruling out compensation as the primary driver
-- and pointing toward workload/burnout instead

-- ------------------------------------------------------------
-- Q3: Who is most at risk? (explored further in Power BI drill-down)
-- Department -> Job Role breakdown showed attrition within Sales
-- is concentrated in the Sales Representative role (39.8%)
-- vs. Sales Executive (17.5%)
-- ------------------------------------------------------------
