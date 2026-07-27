# Data Warehouse & Mart Build: Production ETL Pipeline
An end-to-end data engineering pipeline that transforms raw data from CSV files in Google Cloud Storage to a normalized star schema data warehouse. Data Marts are also built for specific use cases.

## 🖥️ Executive Summary
- **Pipeline Scope** - Build an ETL pipeline to load raw data from csv files in GCS to a star schema data warehouse and then to data marts.

- **Data Modeling** - Designed using Star Schema with fact, dimension and bridge tables for many-to-many relationships.

- **ETL Development** - Implemented **extract, transform, and load** processes and performed data quality checks while keeping idempotency.

- **Mart Architecture** - Created specialized data marts with additive measures and incremental update patterns.

## ❓Problem & Context
Raw job posting data arrives as flat CSV files in Google Cloud Storage—not structured for analytical queries. Analysts need to answer:

    Which skills are most in-demand over time?
    What are hiring trends by company and location?
    How do salary patterns vary by role and skill?

***Challenge:*** Data teams need a single source of truth system (a data warehouse) to be able to perform consistent, reliable analysis across the organization. Additionally, specialized data marts are required to optimize resources by pre-aggregating data for specific business use cases, reducing query complexity and improving performance for common analytical patterns.

***Solution:*** End-to-end ETL pipeline that extracts CSV files from cloud storage, normalizes them into a star schema warehouse (separating facts from dimensions), and creates specialized data marts optimized for specific use cases (flat queries, skill demand analysis, priority role tracking).

## 🧰 Tech Stack
- **Database** : Duckdb/MotherDuck 
- **Language** : SQL (DDL & DML for schema design and data loading and transformations)
- **Data Model** : Star Schema (Fact, Dimension & Bridge Tables)
- **Development** : VS Code for code editing + Terminal for Duckdb CLI Exectution
- **Automation** : Used a master Build SQL file to run queries sequentialy.
- **Version Control** : Git (local repo) & Github (remote repo)
- **Storage** : Google Cloud Storage for CSV source files.

## ⛓️ Pipeline Architecture

`build_queries.sql` is used to run each of the following SQL files sequentially.

### 🗄️ Data Warehouse
Implemented using star schema with the following tables:  
**Dimension Tables:** `company_dim`, `skills_dim`  
**Fact Table:** `job_posts_fact`  
**Bridge Table:** `skills_job_dim`

- **SQL Files:**  
    - `01_create_dw_tables.sql` : Create database & tables for Data warehouse  
    - `02_load_schema_dw.sql` : Load raw data from CSV files in the GCS.
- **Purpose:** This Data Warehouse will be used as single source of truth.
- **Grain:** One row per job posting in the fact table.

### 📁 Flat Mart
- **SQL Files:**  
    - `03_create_flat_mart.sql`
- **Purpose:** Denormalized table for quick queries.
- **Grain:** One row per job posting with all columns from dimension tables joined.

### 📁 Skills Mart
- **SQL Files:**  
    - `04_create_skills_mart.sql`
- **Purpose:** Time-series analysis of skill over demand over time with additive measures
- **Grain:** `skill_id` + `month_start_date` + `job_title_short`

### 📁 Priority Mart
- **SQL Files:**  
    - `05_create_priority_mart.sql` - Create & Load tables.
    - `06_update_priority_mart.sql` - Update `priority_jobs_snapshot` to reflect changes from `priority_roles`
- **Purpose:** Track Priority Roles and Job snapshots with update capabilities
- **Grain:** One row of job posting with priority level assignment 

### 📁 Company Mart
- **SQL Files:**  
    - `07_company_mart.sql`
- **Purpose:** Show company hiring trends by role, location & Month
- **Grain:** `company_id` + `job_title_short_id` + `location_id` + `month_start_date`

## 📊 Analysis Overview
- Which skills are most in-demand over time?
- What are hiring trends by company and location?
- How do salary patterns vary by role and skill?

## 🧠 SQL Skills Demonstrated
#### ETL Pipeline Development
- **Extract:** Direct loading of CSVs from CSV with using Duckdb's `httpfs` extension.
- **Transform:** Data nomalization, conversion (casting data types and `DATE_TRUNC`) and quality filtering.
- **Load:** Idempotent table creation with the use of.
- **Incremental Updates:** Use of `MERGE` Operations for upsert patterns. 
- **Orchestration:** Use of master `build_queries.sql` for automated pipeline execution.
 
#### Dimensional Modeling
- **Star Schema Design:** Use of Fact & Dimention Tables
- **Bridge Tables:** Handling of many-to-many relationships.
- **Grain Definition:** Proper Fact Table Granularity
- **Additive Measures:** Used of `COUNT` and `SUM` that can be re-aggregated at any level.

#### SQL Advanced Techniques
- **DDL Operations:** `CREATE TABLE` & `DROP TABLE`, `CREATE SCHEMA` for schema management
- **DML Operations:** 
- **Merge Operation:**
- **CTEs:** 
- **Date Functions:** 
- **String Functions:**
- **Boolean Logic:**

#### Data Quality & Production Practices
- **Idempotency:** Ensuring that running master build script can be run repeatedly without error.
- **Data Validations:** Included validations for row counts and selecting sample data for each table.
- **Type Safety:** Proper Data type definitions (`INETEGER`, `VARCHAR`, `DATE`, `BOOLEAN`, `DOUBLE`)
- **Schema Organization:** Separate schemas for each Data Mart.

