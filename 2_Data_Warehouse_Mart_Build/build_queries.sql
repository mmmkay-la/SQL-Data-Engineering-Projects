-- To run this script : .read 2_Data_Warehouse_Mart_Build/build_queries.sql


-- Create Data Warehouse & Tables
.read 2_Data_Warehouse_Mart_Build/01_create_dw_tables.sql

-- Load Tables
.read 2_Data_Warehouse_Mart_Build/02_load_schema_dw.sql

-- Create & Load Flat Mart
.read 2_Data_Warehouse_Mart_Build/03_create_flat_mart.sql


-- Create & Load Skills Mart
.read 2_Data_Warehouse_Mart_Build/04_create_skils_mart.sql