/*
Question:  What are the most optimal skills in data engineers (balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on Data Engineer positions in the Philippines with specified annual salaries.
Why?
-- This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately,
rather than letting rare, outlier skills distort the results.
*/

SELECT
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg),0) AS salary_median,
    COUNT(sd.skills) AS demand_count,
    ROUND((MEDIAN(jpf.salary_year_avg) * LN(COUNT(sd.skills))/1000000),1) AS optimal_rank,
    sd.type AS skill_type
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd ON sjd.job_id = jpf.job_id
INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
WHERE 
    jpf.job_country in ('Philippines')
    AND jpf.job_title_short in ('Data Engineer')
GROUP BY sd.skills, sd.type
HAVING COUNT(sd.skills) >= 100
    AND ROUND(MEDIAN(jpf.salary_year_avg),0) IS NOT NULL
ORDER BY 
    optimal_rank DESC, demand_count DESC;

/*
Key Take Aways:
- Unix annd Flow leads the list of optimal skills for Data Engineering roles in the Phiilippines
 wih a median salary of ~ $140,000 - $147,000 median salary and having 200+ demand each.
- SQL and Python comes next with - $84,000 median salary and having 2,000+ demand each.

- The nost optimal skill for Analyst tools is SSIS (SQL Server Integration Servises) with - $114,000 demand salary
and 300+ Demand. Followed by Power BI, for most optimal skill for anaylyst tool, with - $94,000 median salary and having 600 demand.

- AWS leads as the most optimal Cloud Skill with - $80,000 median salary and having 1,000+ demand each. 
Followed by databricks (- $70,000 median salary, 600+ postings), azure (- $70,000 median salary, 1,000+ postings), 
snowflake (- $84,000 median salary, 500+ postings) and spark (- $70,000 median salary, 800+ postings)

Summary:
Skills that consistently appear near the top balance a strong combination of market demand 
(job security) and financial benefit. Python, SQL, Unix, SSIS, AWS, and Flow are particularly strategic 
for both immediate opportunities and longer-term career growth in data engineering roles in the Philippines.


┌────────────┬───────────────┬──────────────┬──────────────┬───────────────┐
│   skills   │ salary_median │ demand_count │ optimal_rank │  skill_type   │
│  varchar   │    double     │    int64     │    double    │    varchar    │
├────────────┼───────────────┼──────────────┼──────────────┼───────────────┤
│ flow       │      147500.0 │          238 │          0.8 │ other         │
│ unix       │      140000.0 │          214 │          0.8 │ os            │
│ sql        │       84000.0 │         2870 │          0.7 │ programming   │
│ python     │       84000.0 │         2403 │          0.7 │ programming   │
│ ssis       │      114177.0 │          306 │          0.7 │ analyst_tools │
│ aws        │       80000.0 │         1235 │          0.6 │ cloud         │
│ java       │       96773.0 │          737 │          0.6 │ programming   │
│ power bi   │       94583.0 │          637 │          0.6 │ analyst_tools │
│ nosql      │       90386.0 │          481 │          0.6 │ programming   │
│ kubernetes │      114177.0 │          137 │          0.6 │ other         │
│ azure      │       70375.0 │         1535 │          0.5 │ cloud         │
│ spark      │       70750.0 │          860 │          0.5 │ libraries     │
│ databricks │       70000.0 │          636 │          0.5 │ cloud         │
│ hadoop     │       84000.0 │          594 │          0.5 │ libraries     │
│ snowflake  │       84000.0 │          544 │          0.5 │ cloud         │
│ scala      │       83387.0 │          470 │          0.5 │ programming   │
│ gcp        │       75375.0 │          420 │          0.5 │ cloud         │
│ redshift   │       83762.0 │          419 │          0.5 │ cloud         │
│ excel      │       84000.0 │          378 │          0.5 │ analyst_tools │
│ mysql      │       84000.0 │          278 │          0.5 │ databases     │
│ r          │       97444.0 │          270 │          0.5 │ programming   │
│ bigquery   │       96773.0 │          235 │          0.5 │ cloud         │
│ linux      │       84000.0 │          231 │          0.5 │ os            │
│ postgresql │       96773.0 │          223 │          0.5 │ databases     │
│ javascript │       96250.0 │          180 │          0.5 │ programming   │
│ php        │       96773.0 │          146 │          0.5 │ programming   │
│ tableau    │       70887.0 │          461 │          0.4 │ analyst_tools │
│ shell      │       80000.0 │          276 │          0.4 │ programming   │
│ go         │       93600.0 │          122 │          0.4 │ programming   │
│ kafka      │       45000.0 │          425 │          0.3 │ libraries     │
│ airflow    │       45000.0 │          391 │          0.3 │ libraries     │
│ oracle     │       50400.0 │          387 │          0.3 │ cloud         │
└────────────┴───────────────┴──────────────┴──────────────┴───────────────┘

*/