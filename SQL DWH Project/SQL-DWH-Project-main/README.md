# SQL Data Warehouse Project

## 📌 Overview
This project demonstrates the end-to-end design of a **Data Warehouse** using **SQL Server (T-SQL)**.  
It integrates **CRM (Customer/Sales)** and **ERP (Enterprise Resource Planning)** data into a unified repository through a structured **ETL pipeline**.  

The solution highlights:
- **ETL Process** (Extract, Transform, Load)
- **Layered Architecture** (Bronze → Silver → Gold)
- **Dimensional Modeling** (Star Schema with Facts and Dimensions)
- **Data Quality Checks** for reliability

The project is designed for **general audiences, data enthusiasts, and recruiters** who want to see a practical demonstration of data engineering workflows.

---

## 🏗️ Architecture
The warehouse follows a **Medallion Architecture**:

1. **Bronze Layer (Raw Data)**  
   - Ingests raw CSV data into staging tables.  
   - Data is preserved exactly as received.  

2. **Silver Layer (Cleaned & Standardized Data)**  
   - Applies **data cleaning, normalization, and deduplication**.  
   - Prepares conformed tables for analytics.  

3. **Gold Layer (Dimensional Model)**  
   - Implements a **Star Schema** with **Fact and Dimension Views**.  
   - Optimized for **reporting and BI tools**.  

---

## 📂 Repository Structure

### **datasets/**
Contains raw CSV files from CRM and ERP systems.

- `source_crm/`
  - `cust_info.csv` → Customer information  
  - `prd_info.csv` → Product information  
  - `sales_details.csv` → Sales details  

- `source_erp/`
  - `cust_az12.csv` → Customer IDs and birthdates  
  - `loc_a101.csv` → Customer locations  
  - `px_cat_g1v2.csv` → Product categories  

---

### **code/**
Contains all SQL scripts for building and running the warehouse.

- **`creating_database.sql`** → Creates the `DataWareHouse` database and schemas (`bronze`, `silver`, `gold`).

#### 🔹 Bronze Layer (`code/bronze/`)
- **`ddl_bronze.sql`** → Creates raw staging tables matching CSV schema.  
- **`proc_load_bronze.sql`** → Stored procedure to load CSV files via `BULK INSERT`.  
- **`execute_bronze.sql`** → Runs the Bronze ingestion procedure.  

#### 🔹 Silver Layer (`code/silver/`)
- **`ddl_silver.sql`** → Defines cleaned/conformed Silver tables.  
- **`proc_load_silver.sql`** → Cleans and transforms data from Bronze into Silver.  
- **`execute_silver.sql`** → Executes Silver loading procedure.  

#### 🔹 Gold Layer (`code/gold/`)
- **`ddl_gold.sql`** → Creates analytical star-schema views:
  - `gold.dim_customers`  
  - `gold.dim_products`  
  - `gold.fact_sales`  

---

### **tests/**
Data validation SQL scripts.  
- **`quality_checks_silver.sql`** → Ensures Silver data has no duplicates, invalid values, or missing keys.  
- **`quality_checks_gold.sql`** → Validates uniqueness of surrogate keys and referential integrity in the Gold layer.  

---

## ⚙️ ETL Workflow

1. **Extract → Load (Bronze Layer)**  
   - Raw CSVs are loaded into `bronze.*` tables using `BULK INSERT`.  
   - Preserves source formatting and schema.  

2. **Transform (Silver Layer)**  
   - Data is **cleansed, normalized, and standardized**:  
     - Trims whitespace  
     - Normalizes gender codes  
     - Handles nulls and invalid dates  
     - Maps product line codes to descriptive names  
   - Ensures consistent, business-ready data.  

3. **Load & Model (Gold Layer)**  
   - Builds a **Star Schema** with:  
     - **Dimensions:** Customers & Products  
     - **Fact:** Sales transactions  
   - Surrogate keys generated via `ROW_NUMBER()`.  
   - Optimized for BI reporting and analytics.  

---

## 📑 Database Schema

### Bronze (Raw Tables)
- `bronze.crm_cust_info`  
- `bronze.crm_prd_info`  
- `bronze.crm_sales_details`  
- `bronze.erp_cust_az12`  
- `bronze.erp_loc_a101`  
- `bronze.erp_px_cat_g1v2`  

### Silver (Cleaned Tables)
- `silver.crm_cust_info`  
- `silver.crm_prd_info`  
- `silver.crm_sales_details`  
- `silver.erp_cust_az12`  
- `silver.erp_loc_a101`  
- `silver.erp_px_cat_g1v2`  

### Gold (Analytical Views – Star Schema)
- **Dimensions**:  
  - `gold.dim_customers(customer_key, customer_id, first_name, last_name, country, gender, birthdate, marital_status)`  
  - `gold.dim_products(product_key, product_id, product_name, category, subcategory, maintenance, cost, product_line)`  

- **Fact**:  
  - `gold.fact_sales(order_number, customer_key, product_key, order_date, sales_amount, quantity, price)`  

---

## 📊 Use Cases
This warehouse supports various business intelligence use cases:

- **Sales Reporting**: Total sales by product, category, or customer demographic.  
- **Customer 360 View**: Unified CRM & ERP view (location, age, gender).  
- **Product Insights**: Sales trends by product line, category, or maintenance type.  
- **Data Quality Auditing**: Regular validation with `tests/` scripts.  

---

## 🛠️ Technologies Used
- **SQL Server (T-SQL)**  
- **BULK INSERT** for data ingestion  
- **Stored Procedures** for ETL orchestration  
- **Window Functions (`ROW_NUMBER`)** for surrogate key generation  
- **Pure SQL ETL (No external tools like SSIS or ADF)**  

---

## ✅ Data Quality Assurance
- **Silver Layer Checks**: Ensures clean, valid, non-duplicated data.  
- **Gold Layer Checks**: Validates star schema integrity and referential consistency.  
- Ensures the pipeline is **robust, scalable, and production-ready**.  

---

## 📌 Summary
This project showcases:  
✔️ End-to-end SQL-based ETL pipeline  
✔️ Medallion architecture (Bronze, Silver, Gold)  
✔️ Star schema design for analytics  
✔️ Practical data engineering best practices  

It provides a **self-contained, reproducible** demonstration of data warehousing in SQL Server—ideal for recruiters, data engineers, and analysts.

---

---

## 📢 Connect with Me  
<div align="center">
    <a href="https://www.linkedin.com/in/rayyanmerchant2004/" target="_blank">
        <img src="https://img.shields.io/badge/LinkedIn-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn"/>
    </a>
    <a href="mailto:merchantrayyan43@gmail.com" target="_blank">
        <img src="https://img.shields.io/badge/Email-%23D14836.svg?style=for-the-badge&logo=gmail&logoColor=white" alt="Email"/>
    </a>
    <a href="https://github.com/rayyan-merchant" target="_blank">
        <img src="https://img.shields.io/badge/GitHub-%23181717.svg?style=for-the-badge&logo=github&logoColor=white" alt="GitHub"/>
    </a>
</div>

