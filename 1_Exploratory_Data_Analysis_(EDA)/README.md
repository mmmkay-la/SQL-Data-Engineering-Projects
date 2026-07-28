# Exploratory Data Analysis w/ SQL : Philippines Job Market Analysis

A SQL project analyzing data engeneering job market in the Philippines using real world job posting data. 

This project is created to demonstrate skills in writing production quality analytical SQL, design efficient queries, and turn business questions into data-driven insights.

## 🖥️ Executive Summary
- **Project Scope:** Build *3 analytical queries* answering questions about Data Engineeirng job market in the philipppines.

1. [01_top__in_demand_skills.sql](/1_Exeploratory_Data_Analysis_(EDA)/01_top_in_demand_skills.sql) - demand analysis of data engineering skills

2. [02_highest_paying_skills.sql](1_Exeploratory_Data_Analysis_(EDA)/02_highest_paying_skills.sql) - based on median salary

3. [03_optimal_skills.sql](1_Exeploratory_Data_Analysis_(EDA)/03_optimal_skills.sql) - determine the optimal score of data engineering sklls based on smedian alary and demand.

- **Data modeling:** Used multi-tabke joins
- **Analytics:** Applied **aggregations, filtering, and sortng** to determine the top skills by demand, salary and overall value.
- **Outcomes:** SQL and Python were the top demanded skills for data engineeing roles in the Philippines.

## ❓Problem & Context
The following questions were used as guide for the job market analysis;
1. What are the most in-demand skill?
2. What skills command the highest salaries?
3. What is the optimal skill set balancing demand and compensation?

This project analyzes a **data warehouse** built using a schema design. (c/o Luke Barousse)
1. Fact Table = 
    -  job_postings_fact = central table containing job posting details
2. Dimensions Table = 
    - company_dim = stores company details
    - skills_dim = stores job skills details
3. Bridge Table
    - skillls_job_dim = used to connect skills_dim dimensions table to job_postings_fact table.

## 🧰 Tech Stack
- Query Engine = DuckDB for fast OLAP-style analytical queries
- Language = standard ANSI SQL
- Data Model = Star Shema with Fact, Dimension and Bridge Tables
- Development = VS Code for SQL editing + Terminal for DuckDB CLI
- Version Control = Git/Github

## 📈 Analysis Overview
### Query Structure
1. **Top Demanded Skills** = Identified the top 10 most in demand skills for data engineering roles in the Philippines.
2. **Top Paying Skills** = Analyzed the highest paying skills using median salary and demand metrics.
3. **Optimal Skills** = Calculates for each skills optimal score by combining median salary and demand to determine the most valuable skill to learn for data engineering roles.

### Key Takeaways:
 - Core languages: SQL / Python dominates the list with over 2,000+ job postings for data engineering roles in the Philippines
 - Cloud platforms: AWS and Azure are critical for modern data engineering roles.
 - Big Data tools: Apache Spark and Databricks shows strong demand and competetive compensations.

## 🧠 SQL Skills Demonstrated
### Query Design & Omptimization
- Complex Joins: Multiple `INNER JOIN` operations to connect `job_postings_fact`, `skills_job_dim`, and `skills_dim`
- Aggregations: `COUNT()`, `MEDIAN()`, `ROUND()` for analysis
- Filtering: use of multiple conditions in the `WHERE` clauses
- Sorting and Limiting: `ORDER BY DESC` and `LIMIT` top-N analysis.

### Data Analysis Techniques
- Grouping: `GROUP BY` for categorical analysis by skill
- Mathematical Functions: used `LN()` for natural logartithmic transformation to normalaize demand metrics
- Calculated Metrics: Derived the optimal score by combining the log-transformed demand with median salary.
- Having Clause: used to filter aggregated results (skills with >= 100 postings)
- NULL Handling: Proper filtering of incomplete records in computing the median salary by using `salary_year_avg IS NOT NULL`