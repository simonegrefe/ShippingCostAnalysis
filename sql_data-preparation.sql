-- ============================================
-- Step 1: Data cleaning and normalization
-- ============================================
WITH cleaned AS (
    SELECT DISTINCT
        s.invoice_no,
        s.transaction_date,
        s.customer_id,
        COALESCE(s.description, p.description) AS description_cleaned,																
        p.category,

        -- Customer location fields
        LOWER(c.order_city) AS order_city_cleaned,                                                               								
        c.order_postal,
        m.state,
        m.region,
        c.latitude,
        c.longitude,

        -- Clean quantity (force INT, fallback from sales/unit_price)                                     										
        CAST(
            CASE 
                WHEN s.quantity IS NULL THEN s.sales / NULLIF(s.unit_price, 0)
                ELSE s.quantity
            END AS INT
        ) AS quantity_cleaned,

        -- Clean sales (force DECIMAL, fallback from quantity * unit_price)
        CAST(
            COALESCE(s.sales, s.quantity * s.unit_price) 
            AS DECIMAL(12,2)
        ) AS sales_cleaned,

        -- Clean unit_price (fallback from sales/quantity)
        CAST(
            CASE 
                WHEN s.unit_price IS NULL THEN s.sales / NULLIF(s.quantity, 0)
                ELSE s.unit_price
            END AS DECIMAL(10,2)
        ) AS unit_price_cleaned,

        -- Shipping cost from product table
        CAST(COALESCE(p.shipping_cost_1000_mile, 0) AS DECIMAL(10,2)) AS costs,         							  

        -- Landed cost from product table
        CAST(COALESCE(p.landed_cost, 0) AS DECIMAL(10,2)) AS landed_cost                        						

    FROM mi_sales s
    LEFT JOIN mi_customers c USING(customer_id)
    LEFT JOIN mi_products p USING(stock_code)
    LEFT JOIN mi_state_region_mapping m USING(order_state)
    
	WHERE s.quantity IS NOT NULL 
       OR (s.sales IS NOT NULL AND s.unit_price IS NOT NULL)																		
),

-- ============================================
-- Step 2: Add profit per unit
-- ============================================
base AS (
    SELECT
        invoice_no,
        transaction_date,
        customer_id,
        description_cleaned AS description,
        category,
        order_city_cleaned,
        order_postal,
        state,
        region,
        latitude,
        longitude,
        quantity_cleaned AS quantity,
        costs,
        CAST(ROUND(unit_price_cleaned - landed_cost, 2) AS DECIMAL(10,2)) AS profit_per_unit			
    FROM cleaned
    WHERE quantity_cleaned >0 AND costs > 0																												
)

-- ============================================
-- Step 3: Shipping models & profit calculations
-- ============================================
SELECT
    invoice_no,
    transaction_date,
    customer_id,
    description,
    category,
    order_city_cleaned,
    order_postal,
    state,
    region,
    latitude,
    longitude,
    quantity,
    costs,
    profit_per_unit,

    -- Baseline shipping: first unit = 100%, additional = 70%           
	   CASE
        WHEN quantity = 1 THEN costs																															
        ELSE (1* costs ) + (costs * 0.7 * (quantity - 1))                             
    END AS baseline_shipping_cost,
	
    -- Hypothesis factor (all items same factor)
    CASE
        WHEN quantity = 1 THEN 1.0																																
        WHEN quantity = 2 THEN 0.8
        WHEN quantity <= 4 THEN 0.6
        WHEN quantity <= 7 THEN 0.5
        WHEN quantity <= 9 THEN 0.4
        ELSE 0.3
    END AS hypothesis_factor,


	    -- Hypothesis shipping cost
    CASE
        WHEN quantity = 1 THEN costs																							
        ELSE quantity * costs * (
            CASE
                WHEN quantity = 2 THEN 0.8
                WHEN quantity <= 4 THEN 0.6
                WHEN quantity <= 7 THEN 0.5
                WHEN quantity <= 9 THEN 0.4
                ELSE 0.3
            END
        )
    END AS hypothesis_shipping_cost,
	
    -- Profit before shipping																																				
    (quantity * profit_per_unit) AS profit_before_shipping,	

    -- Profit after baseline
    (quantity * profit_per_unit) -																																	 
    CASE
        WHEN quantity = 1 THEN costs
        ELSE (1* costs ) + (costs * 0.7 * (quantity - 1))  
    END AS profit_after_baseline,

    -- Profit after Hypothesis 
    (quantity * profit_per_unit) -
    CASE																																													
        WHEN quantity = 1 THEN costs
        ELSE quantity * costs * (
            CASE
                WHEN quantity = 2 THEN 0.8
                WHEN quantity <= 4 THEN 0.6
                WHEN quantity <= 7 THEN 0.5
                WHEN quantity <= 9 THEN 0.4
                ELSE 0.3
            END
        )
    END AS profit_after_hypothesis

FROM base;
