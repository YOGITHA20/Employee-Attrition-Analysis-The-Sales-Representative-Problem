# Employee Attrition Analysis — The Sales Representative Problem

**Tools:** Python (Pandas) · MySQL (CTEs, Joins, Window Functions) · Power BI
**Dataset:** IBM HR Analytics Employee Attrition & Performance (Kaggle), 1,470 employees

## Overview
This project investigates why employees are leaving across a fictional company, moving from a broad department-level view down to a specific, actionable finding through data cleaning, SQL analysis, and an interactive Power BI dashboard.

## Business Questions
Before touching the data, the analysis was framed around these questions:

**Primary question:** Why are we losing employees, and where should retention efforts be focused first?

1. **Where is attrition happening?**
   - Which departments and roles have the highest attrition?
   - Is attrition evenly spread across the company, or concentrated in specific pockets?
2. **Why is it happening?**
   - Is attrition linked to compensation — are people who leave underpaid relative to peers?
   - Is attrition linked to workload — does overtime correlate with leaving?
   - Is attrition linked to job satisfaction or work-life balance?
3. **Who is most at risk?**
   - Are specific roles disproportionately affected, even within a department that looks "normal"?
4. **What should the business actually do?**
   - If the company could fix only one thing, what would have the biggest impact on retention?
   - Is this a company-wide policy issue, or specific to one team or role?

## 1. Data Cleaning (Python)
- Checked for missing values and duplicate rows — none found
- Removed 3 constant, non-informative columns: `EmployeeCount`, `StandardHours`, `Over18` (every row shared the same value, so they added no analytical signal)
- Confirmed `Attrition` is imbalanced (83.9% stayed vs. 16.1% left) — kept in mind when interpreting smaller subgroup percentages
- `MonthlyIncome` is right-skewed as expected for income data — used median/context rather than mean alone when comparing pay
- Split the single flat file into three relational tables (`employees`, `compensation`, `performance`) linked by `EmployeeNumber`, to practice and demonstrate proper relational structure

## 2. SQL Analysis (MySQL)
Used CTEs, joins, and window functions to answer the business questions above, rather than just demonstrate syntax:

- **CTEs** to stage department-level attrition rates before calculating percentages (answers Q1)
- **Joins** across `employees`, `compensation`, and `performance` to analyze attrition alongside pay and satisfaction (answers Q2)
- **Window functions** (`RANK() OVER`, `AVG() OVER (PARTITION BY ...)`) to compare individual employees against their department's average income and rank employees within their department (answers Q2, Q3)

### Key SQL Findings

| Question | Finding |
|---|---|
| Where is attrition happening? | Sales has the highest department-level attrition rate (20.63%), ahead of HR (19.05%) and R&D (13.84%) |
| Why is it happening? | Overtime is a stronger driver than department: in every department, employees working overtime left at roughly 2–3x the rate of those who didn't (Sales: 37.5% vs. 13.84%; R&D: 27.31% vs. 8.55%; HR: 29.41% vs. 15.22%) |
| Is it a pay problem? | No — among employees who left, overtime workers weren't underpaid relative to non-overtime peers (in Sales, overtime leavers earned *more* on average). This rules out compensation as the primary driver |

## 3. Power BI Dashboard
Built an interactive dashboard with:
- KPI cards for overall attrition rate and average income
- A bar chart showing department-level attrition, titled with the insight itself
- A grey/red bar chart isolating the overtime effect across departments
- A drill-down matrix (Department → Job Role) with accurate headcounts
- Slicers for Department, OverTime, and Job Role for interactive filtering

**Who is most at risk (Q3):** The drill-down matrix revealed the sharpest finding of the project — attrition within Sales is not evenly spread. It's concentrated in the **Sales Representative** role (39.8% attrition) versus **Sales Executive** (17.5%). This reframes the entire narrative: it isn't a department-wide "Sales problem," it's a role-specific issue affecting a smaller, front-line group.

*(Dashboard screenshot goes here — drag the image into this README on GitHub and it will embed automatically: `![dashboard](your-screenshot-filename.png)`)*

## Recommendation (Q4)
Rather than a broad departmental review or a blanket compensation adjustment, the business should specifically examine the **Sales Representative role** — workload distribution, quota structure, and staffing levels — since this group drives the majority of Sales' overall attrition and is not explained by pay.

## What I'd Explore Next
- Whether Sales Representative headcount has grown or shrunk over time relative to workload
- A simple logistic regression in Python to estimate attrition risk per employee, cross-checked against these SQL findings
