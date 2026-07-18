/*
Question: What are the most in-demand skill?
-- SQL Query to retrieve the top 10 most in-demand skills for a specific job title.
-- Both Queries will return results from Job Openings in the Philippines.
-- Data Warehouse used is provided by Luke Barousse.
*/

/*
QUERY OPTION 1: Retrieves top 10 in-demand skills for specific for Data Engineer Job Openings in the Philippines
*/
SELECT 
    sd.skills,
    COUNT(sd.skills) AS demand_count,
    sd.type AS skill_type
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd ON sjd.job_id = jpf.job_id
INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
WHERE 
    jpf.job_country in ('Philippines')
    AND jpf.job_title_short in ('Data Engineer')
GROUP BY sd.skills, sd.type
ORDER BY demand_count DESC
Limit 10;

/*
Key take aways:
- SQL and Python are the top in-demand programming skill used for Data Engineering jobs in the Philippines with job postings of 2,870 and 2,403 respectively.
- Microsoft Azure and Amazon AWS are the top most used cloud computing platforms with demand of 1,535 and 1,235 respectively
- Power BI is the most used as an analsyt tool with 637 job openings requiring this skill.

┌────────────┬──────────────┬───────────────┐
│   skills   │ demand_count │  skill_type   │
│  varchar   │    int64     │    varchar    │
├────────────┼──────────────┼───────────────┤
│ sql        │         2870 │ programming   │
│ python     │         2403 │ programming   │
│ azure      │         1535 │ cloud         │
│ aws        │         1235 │ cloud         │
│ spark      │          860 │ libraries     │
│ java       │          737 │ programming   │
│ power bi   │          637 │ analyst_tools │
│ databricks │          636 │ cloud         │
│ hadoop     │          594 │ libraries     │
│ snowflake  │          544 │ cloud         │
└────────────┴──────────────┴───────────────┘
*/


/* 
QUERY OPTION 2: Retrieves top 10 in-demand skills from the Job Openings in the Philippines for the following Job Titles: 
Data Analyst              
Software Engineer         
Senior Data Analyst       
Machine Learning Engineer 
Cloud Engineer            
Senior Data Scientist     
Data Engineer             
Senior Data Engineer      
Business Analyst          
Business Analyst          
Data Scientist  
*/

WITH in_demand_skills AS (
    SELECT 
        jpf.job_title_short,
        sd.skills,
        COUNT(sd.skills) AS demand_count,
        ROW_NUMBER() OVER(
            PARTITION BY jpf.job_title_short
            ORDER BY demand_count DESC
        ) AS skill_rank,
        sd.type AS skill_type
    FROM job_postings_fact AS jpf
    INNER JOIN skills_job_dim AS sjd ON sjd.job_id = jpf.job_id
    INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
    WHERE 
        jpf.job_country in ('Philippines') 
    GROUP BY jpf.job_title_short, sd.skills, sd.type
    ORDER BY jpf.job_title_short, demand_count DESC
) SELECT 
    job_title_short, 
    skills,
    demand_count,
    skill_type
 FROM in_demand_skills 
 WHERE skill_rank <= 10;

/*
Key takeaways:
- SQL and Python are both part of the top 10 in-demand skills from the Job postings in the Philippines for all the above mentioned Job Titles,
making SQL and Python the top skills to learn that will result to the most job opportunities.
- Data Analyst has the most Job openings in the Philippines followed by Data Engineer and Business Analyst.

┌───────────────────────────┬──────────────┬──────────────┬────────────┬───────────────┐
│      job_title_short      │    skills    │ demand_count │ skill_rank │  skill_type   │
│          varchar          │   varchar    │    int64     │   int64    │    varchar    │
├───────────────────────────┼──────────────┼──────────────┼────────────┼───────────────┤
│ Business Analyst          │ excel        │         1808 │          1 │ analyst_tools │
│ Business Analyst          │ sql          │         1335 │          2 │ programming   │
│ Business Analyst          │ tableau      │          919 │          3 │ analyst_tools │
│ Business Analyst          │ power bi     │          889 │          4 │ analyst_tools │
│ Business Analyst          │ python       │          548 │          5 │ programming   │
│ Business Analyst          │ powerpoint   │          537 │          6 │ analyst_tools │
│ Business Analyst          │ word         │          401 │          7 │ analyst_tools │
│ Business Analyst          │ r            │          267 │          8 │ programming   │
│ Business Analyst          │ oracle       │          229 │          9 │ cloud         │
│ Business Analyst          │ flow         │          186 │         10 │ other         │
│ Cloud Engineer            │ azure        │          110 │          1 │ cloud         │
│ Cloud Engineer            │ aws          │           93 │          2 │ cloud         │
│ Cloud Engineer            │ sql          │           91 │          3 │ programming   │
│ Cloud Engineer            │ python       │           88 │          4 │ programming   │
│ Cloud Engineer            │ terraform    │           60 │          5 │ other         │
│ Cloud Engineer            │ linux        │           57 │          6 │ os            │
│ Cloud Engineer            │ excel        │           53 │          7 │ analyst_tools │
│ Cloud Engineer            │ windows      │           50 │          8 │ os            │
│ Cloud Engineer            │ powershell   │           44 │          9 │ programming   │
│ Cloud Engineer            │ go           │           43 │         10 │ programming   │
│ Data Analyst              │ excel        │         4566 │          1 │ analyst_tools │
│ Data Analyst              │ sql          │         3683 │          2 │ programming   │
│ Data Analyst              │ python       │         2075 │          3 │ programming   │
│ Data Analyst              │ tableau      │         2029 │          4 │ analyst_tools │
│ Data Analyst              │ power bi     │         1949 │          5 │ analyst_tools │
│ Data Analyst              │ r            │         1080 │          6 │ programming   │
│ Data Analyst              │ word         │          877 │          7 │ analyst_tools │
│ Data Analyst              │ powerpoint   │          803 │          8 │ analyst_tools │
│ Data Analyst              │ sheets       │          538 │          9 │ analyst_tools │
│ Data Analyst              │ sap          │          537 │         10 │ analyst_tools │
│ Data Engineer             │ sql          │         2870 │          1 │ programming   │
│ Data Engineer             │ python       │         2403 │          2 │ programming   │
│ Data Engineer             │ azure        │         1535 │          3 │ cloud         │
│ Data Engineer             │ aws          │         1235 │          4 │ cloud         │
│ Data Engineer             │ spark        │          860 │          5 │ libraries     │
│ Data Engineer             │ java         │          737 │          6 │ programming   │
│ Data Engineer             │ power bi     │          637 │          7 │ analyst_tools │
│ Data Engineer             │ databricks   │          636 │          8 │ cloud         │
│ Data Engineer             │ hadoop       │          594 │          9 │ libraries     │
│ Data Engineer             │ snowflake    │          544 │         10 │ cloud         │
│ Data Scientist            │ sql          │         1407 │          1 │ programming   │
│ Data Scientist            │ python       │         1377 │          2 │ programming   │
│ Data Scientist            │ r            │          838 │          3 │ programming   │
│ Data Scientist            │ excel        │          798 │          4 │ analyst_tools │
│ Data Scientist            │ tableau      │          619 │          5 │ analyst_tools │
│ Data Scientist            │ power bi     │          491 │          6 │ analyst_tools │
│ Data Scientist            │ aws          │          342 │          7 │ cloud         │
│ Data Scientist            │ azure        │          265 │          8 │ cloud         │
│ Data Scientist            │ spark        │          238 │          9 │ libraries     │
│ Data Scientist            │ sas          │          234 │         10 │ programming   │
│ Machine Learning Engineer │ python       │          284 │          1 │ programming   │
│ Machine Learning Engineer │ tensorflow   │          133 │          2 │ libraries     │
│ Machine Learning Engineer │ aws          │          124 │          3 │ cloud         │
│ Machine Learning Engineer │ pytorch      │          107 │          4 │ libraries     │
│ Machine Learning Engineer │ r            │           90 │          5 │ programming   │
│ Machine Learning Engineer │ sql          │           82 │          6 │ programming   │
│ Machine Learning Engineer │ azure        │           78 │          8 │ cloud         │
│ Machine Learning Engineer │ scikit-learn │           78 │          7 │ libraries     │
│ Machine Learning Engineer │ kubernetes   │           58 │          9 │ other         │
│ Machine Learning Engineer │ docker       │           49 │         10 │ other         │
│ Senior Data Analyst       │ sql          │          591 │          1 │ programming   │
│ Senior Data Analyst       │ excel        │          446 │          2 │ analyst_tools │
│ Senior Data Analyst       │ tableau      │          347 │          3 │ analyst_tools │
│ Senior Data Analyst       │ python       │          338 │          4 │ programming   │
│ Senior Data Analyst       │ power bi     │          239 │          5 │ analyst_tools │
│ Senior Data Analyst       │ r            │          189 │          6 │ programming   │
│ Senior Data Analyst       │ powerpoint   │          137 │          7 │ analyst_tools │
│ Senior Data Analyst       │ word         │           80 │          8 │ analyst_tools │
│ Senior Data Analyst       │ sap          │           76 │          9 │ analyst_tools │
│ Senior Data Analyst       │ oracle       │           75 │         10 │ cloud         │
│ Senior Data Engineer      │ sql          │          568 │          1 │ programming   │
│ Senior Data Engineer      │ python       │          483 │          2 │ programming   │
│ Senior Data Engineer      │ aws          │          295 │          3 │ cloud         │
│ Senior Data Engineer      │ azure        │          201 │          4 │ cloud         │
│ Senior Data Engineer      │ spark        │          171 │          5 │ libraries     │
│ Senior Data Engineer      │ java         │          169 │          6 │ programming   │
│ Senior Data Engineer      │ scala        │          166 │          7 │ programming   │
│ Senior Data Engineer      │ redshift     │          164 │          8 │ cloud         │
│ Senior Data Engineer      │ databricks   │          119 │          9 │ cloud         │
│ Senior Data Engineer      │ tableau      │          116 │         10 │ analyst_tools │
│ Senior Data Scientist     │ sql          │          261 │          1 │ programming   │
│ Senior Data Scientist     │ python       │          255 │          2 │ programming   │
│ Senior Data Scientist     │ r            │          116 │          3 │ programming   │
│ Senior Data Scientist     │ excel        │           86 │          4 │ analyst_tools │
│ Senior Data Scientist     │ azure        │           78 │          5 │ cloud         │
│ Senior Data Scientist     │ tableau      │           70 │          6 │ analyst_tools │
│ Senior Data Scientist     │ power bi     │           54 │          7 │ analyst_tools │
│ Senior Data Scientist     │ aws          │           54 │          8 │ cloud         │
│ Senior Data Scientist     │ sas          │           44 │          9 │ analyst_tools │
│ Senior Data Scientist     │ sas          │           44 │         10 │ programming   │
│ Software Engineer         │ sql          │          434 │          1 │ programming   │
│ Software Engineer         │ aws          │          258 │          2 │ cloud         │
│ Software Engineer         │ python       │          255 │          3 │ programming   │
│ Software Engineer         │ azure        │          168 │          4 │ cloud         │
│ Software Engineer         │ java         │          150 │          5 │ programming   │
│ Software Engineer         │ excel        │          146 │          6 │ analyst_tools │
│ Software Engineer         │ c#           │          117 │          7 │ programming   │
│ Software Engineer         │ docker       │          113 │          8 │ other         │
│ Software Engineer         │ oracle       │          109 │          9 │ cloud         │
│ Software Engineer         │ kubernetes   │          107 │         10 │ other         │
└───────────────────────────┴──────────────┴──────────────┴────────────┴───────────────┘
*/