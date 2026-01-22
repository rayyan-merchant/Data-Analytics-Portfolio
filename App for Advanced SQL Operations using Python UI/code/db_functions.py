import psycopg2
from decimal import Decimal

def connect_to_db():
    return psycopg2.connect(
        host="localhost",
        user="postgres",
        password="rayyan123",
        database="dummy_db",
        port=5432
    )



def get_basic_info(cursor):
    queries = {
        "Total Suppliers": "SELECT COUNT(*) AS total_suppliers FROM suppliers",

        "Total Products": "SELECT COUNT(*) AS total_products FROM products",

        "Total Categories Dealing": "SELECT COUNT(DISTINCT category) AS total_categories FROM products",

        "Total Sale Value (Last 3 Months)": """
            SELECT ROUND(SUM(ABS(se.change_quantity) * p.price)::numeric, 2) AS total_sales_value_in_last_3_months
            FROM stock_entries se
            JOIN products p ON p.product_id = se.product_id
            WHERE se.change_type = 'Sale'
              AND se.entry_date >= (
                SELECT MAX(entry_date) - INTERVAL '3 months'
                FROM stock_entries
            )
        """,

        "Total Restock Value (Last 3 Months)": """
            SELECT ROUND(SUM(ABS(se.change_quantity) * p.price)::numeric, 2) AS total_restock_value_in_last_3_months
            FROM stock_entries se
            JOIN products p ON p.product_id = se.product_id
            WHERE se.change_type = 'Restock'
              AND se.entry_date >= (
                SELECT MAX(entry_date) - INTERVAL '3 months'
                FROM stock_entries
            )
        """,

        "Below Reorder & No Pending Reorders": """
            SELECT COUNT(*) AS products_needing_restock
            FROM products p
            WHERE p.stock_quantity < p.reorder_level
              AND p.product_id NOT IN (
                  SELECT DISTINCT product_id FROM reorders WHERE status = 'Pending'
              )
        """
    }

    results = {}
    for label, query in queries.items():
        cursor.execute(query)
        row = cursor.fetchone()   # tuple like (value,)
        value = row[0]

        # Convert Decimal → float for JSON/dashboard compatibility
        if isinstance(value, Decimal):
            value = float(value)
        results[label] = value

    return results




def get_additonal_tables(cursor):
    queries = {
        "Suppliers Contact Details": """
            SELECT supplier_name, contact_name, email, phone
            FROM suppliers
        """,

        "Products with Supplier and Stock": """
            SELECT 
                p.product_name,
                s.supplier_name,
                p.stock_quantity,
                p.reorder_level
            FROM products p
            JOIN suppliers s ON p.supplier_id = s.supplier_id
            ORDER BY p.product_name ASC
        """,

        "Products Needing Reorder": """
            SELECT product_name, stock_quantity, reorder_level
            FROM products
            WHERE stock_quantity <= reorder_level
        """
    }

    tables = {}
    for label, query in queries.items():
        cursor.execute(query)
        tables[label] = cursor.fetchall()

    return tables



def get_categories(cursor1):
    cursor1.execute("select Distinct category  from products  order by category  asc")
    rows= cursor1.fetchall()
    return [row["category"] for row in rows]

def get_suppliers(cursor1):
    cursor1.execute("select supplier_id , supplier_name from suppliers order by  supplier_name asc")
    return cursor1.fetchall()


def add_new_manual_id(cursor, db, p_name , p_category , p_price , p_stock , p_reorder, p_supplier):
    proc_call= "call AddNewProductManualID(%s, %s, %s ,%s ,%s, %s)"
    params= (p_name , p_category , p_price , p_stock , p_reorder, p_supplier)
    cursor.execute(proc_call, params)
    db.commit()


def get_all_products(cursor):
    cursor.execute("select product_id, product_name from products order by  product_name")
    return cursor.fetchall()

def get_product_history(cursor, product_id):
    query ="select * from product_inventory_history where product_id= %s order by record_date Desc"
    cursor.execute(query , (product_id,))
    return cursor.fetchall()



def place_reorder(cursor, db, product_id , reorder_quantity):
    query= """
         insert into reorders (reorder_id,product_id ,reorder_quantity,reorder_date ,status)
         select 
         COALESCE(MAX(reorder_id) + 1, 1),
         %s,
         %s,
         CURRENT_DATE,
         'Ordered'
         from reorders;
         """
    cursor.execute(query,(product_id, reorder_quantity))
    db.commit()


def get_pending_reorders(cursor):
    cursor.execute("""
    select r.reorder_id , p.product_name
    from reorders as r join products as p 
    on r.product_id= p.product_id
    """)
    return cursor.fetchall()


def mark_reorder_as_received(cursor, db, reorder_id):
    cursor.execute("CALL MarkReorderAsReceived(%s)", (reorder_id,))
    db.commit()
