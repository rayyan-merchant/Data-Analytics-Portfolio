select * from products;
select * from reorders;
select * from shipments;
select * from stock_entries;
select * from suppliers;


-- basic metrics

select count(*) as total_suppliers from suppliers;

select count(*) as total_products from products;

select COUNT(DISTINCT category) as total_categories from products;


-- sales in the last 3 months
select 
    ROUND(SUM(ABS(se.change_quantity) * p.price)::numeric, 2) AS total_sales_value_in_last_3_months
from stock_entries se
join products p ON p.product_id = se.product_id
where se.change_type = 'Sale'
and se.entry_date >= (
    select MAX(entry_date) - INTERVAL '3 months'
    from stock_entries
);


-- restock in last three months
select 
    ROUND(SUM(ABS(se.change_quantity) * p.price)::numeric, 2) AS total_restock_value_in_last_3_months
from stock_entries se
join products p ON p.product_id = se.product_id
where se.change_type = 'Restock'
and se.entry_date >= (
    select MAX(entry_date) - INTERVAL '3 months'
    from stock_entries
);


 -- 6: products that need to be restocked
select count(*) 
from products  as p  
where p.stock_quantity<p.reorder_level
 	  and  product_id NOT IN(
					select distinct product_id 
					from reorders  
					where status ='Pending')



-- 7 Suppliers and their  contact details
select supplier_name, contact_name , email, phone 
from suppliers


-- 8 Product with their suppliers and current stock
select p.product_name,s.supplier_name , p.stock_quantity, p.reorder_level
from products as p 
join suppliers  s on
p.supplier_id = s.supplier_id
order by p.product_name ASC


-- 9 Product needing reorder
select product_id ,product_name, stock_quantity, reorder_level  
from products 
where stock_quantity<reorder_level



-- 10  Add an new product to the database
CREATE OR REPLACE PROCEDURE AddNewProductManualID(
    p_name VARCHAR,
    p_category VARCHAR,
    p_price NUMERIC(10,2),
    p_stock INT,
    p_reorder INT,
    p_supplier INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_prod_id INT;
    new_shipment_id INT;
    new_entry_id INT;
BEGIN
    -- Generate new product_id
    SELECT COALESCE(MAX(product_id), 0) + 1 INTO new_prod_id FROM products;
    -- Insert into products
    INSERT INTO products(product_id, product_name, category, price, stock_quantity, reorder_level, supplier_id)
    VALUES (new_prod_id, p_name, p_category, p_price, p_stock, p_reorder, p_supplier);

    -- Generate new shipment_id
    SELECT COALESCE(MAX(shipment_id), 0) + 1 INTO new_shipment_id FROM shipments;
    -- Insert into shipments
    INSERT INTO shipments(shipment_id, product_id, supplier_id, quantity_received, shipment_date)
    VALUES (new_shipment_id, new_prod_id, p_supplier, p_stock, CURRENT_DATE);

    -- Generate new stock entry id
    SELECT COALESCE(MAX(entry_id), 0) + 1 INTO new_entry_id FROM stock_entries;
    -- Insert into stock_entries
    INSERT INTO stock_entries(entry_id, product_id, change_quantity, change_type, entry_date)
    VALUES (new_entry_id, new_prod_id, p_stock, 'Restock', CURRENT_DATE);
END;
$$;


call AddNewProductManualID('Smart Watch', 'Electronics', 99.99,100,25,5)





select * from products where  product_name ="Bettles"
select * from shipments where product_id =202
select * from stock_entries where product_id= 202



CREATE OR REPLACE VIEW product_inventory_history AS
SELECT 
    pih.product_id,
    pih.record_type,
    pih.record_date,
    pih.quantity,
    pih.change_type,
    pr.supplier_id
FROM (
    SELECT 
        product_id,
        'Shipment' AS record_type,
        shipment_date::timestamp AS record_date,
        quantity_received AS quantity,
        NULL AS change_type
    FROM shipments

    UNION ALL

    SELECT 
        product_id,
        'Stock Entry' AS record_type,
        entry_date::timestamp AS record_date,
        change_quantity AS quantity,
        change_type
    FROM stock_entries
) pih
JOIN products pr ON pr.product_id = pih.product_id;





select * from 
product_inventory_history
where product_id= 123
order by record_date desc



-- 12 Place an reorder
insert into reorders(reorder_id , product_id , reorder_quantity, reorder_date ,status)
select max(reorder_id)+1,  101, 200, curdate(), "ordered" from reorders


select * from stock_entries
select * from shipments 
select * from reorders
select * from products



CREATE OR REPLACE PROCEDURE MarkReorderAsReceived(in_reorder_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    prod_id INT;
    qty INT;
    sup_id INT;
    new_shipment_id INT;
    new_entry_id INT;
BEGIN
    -- Start transaction is implicit

    -- get product_id , quantity  from reorders
    SELECT product_id, reorder_quantity
    INTO prod_id, qty
    FROM reorders
    WHERE reorder_id = in_reorder_id;

    -- Get supplier_id from Products
    SELECT supplier_id
    INTO sup_id
    FROM products
    WHERE product_id = prod_id;

    -- update reorder table -- Received
    UPDATE reorders
    SET status = 'Received'
    WHERE reorder_id = in_reorder_id;

    -- update quantity in product table
    UPDATE products
    SET stock_quantity = stock_quantity + qty
    WHERE product_id = prod_id;

    -- Insert record into shipment table
    SELECT COALESCE(MAX(shipment_id), 0) + 1
    INTO new_shipment_id
    FROM shipments;

    INSERT INTO shipments(shipment_id, product_id, supplier_id, quantity_received, shipment_date)
    VALUES (new_shipment_id, prod_id, sup_id, qty, CURRENT_DATE);

    -- Insert record into stock_entries (Restock)
    SELECT COALESCE(MAX(entry_id), 0) + 1
    INTO new_entry_id
    FROM stock_entries;

    INSERT INTO stock_entries(entry_id, product_id, change_quantity, change_type, entry_date)
    VALUES (new_entry_id, prod_id, qty, 'Restock', CURRENT_DATE);

END;
$$;



select * from reorders where  reorder_id=13


select * from products where product_name= "Someone Shirt"


select * from reorders where reorder_id= 1

select * from stock_entries where product_id=164 order by entry_date desc
select * from shipments  order  by shipment_id desc


