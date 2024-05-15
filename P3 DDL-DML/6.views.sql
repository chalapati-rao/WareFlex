CREATE OR REPLACE VIEW Owners_Revenue_By_Warehouse AS
SELECT
    o.Owner_ID,
    o.Owner_Name,
    w.warehouse_id,
    w.warehouse_name,
    lt.type_name,
    loc.City,
    loc.State,
    loc.Country,
    COALESCE(SUM(l.lease_amount), 0) AS Total_Revenue,
    COALESCE(SUM(l.lease_amount) / NULLIF(COUNT(DISTINCT u.Unit_ID), 0), 0) AS Avg_Revenue_per_Unit,
    COALESCE(SUM(L.LEASE_AMOUNT) - SUM(L.BALANCE_AMOUNT), 0) AS Total_Amount_Paid,
    COALESCE(SUM(l.balance_amount), 0) AS Total_Balance_Amount,
    COALESCE(COUNT(DISTINCT u.Unit_ID), 0) AS Total_Units
FROM
    WAREHOUSE w
JOIN
    WAREHOUSE_OWNER o ON w.Owner_ID = o.Owner_ID
JOIN
    LOCATION loc ON w.Location_ID = loc.Location_ID
JOIN
    WAREHOUSE_TYPE lt ON w.Warehouse_Type_ID = lt.Warehouse_Type_ID
LEFT JOIN
    LEASE l ON l.Warehouse_ID = w.Warehouse_ID
LEFT JOIN 
    UNIT u ON u.Warehouse_ID = w.Warehouse_ID
LEFT JOIN 
    LEASE_UNIT lu ON l.Lease_ID = lu.Lease_ID
GROUP BY
    o.Owner_ID,
    o.Owner_Name,
    w.warehouse_id,
    w.warehouse_name,
    lt.type_name,
    loc.City,
    loc.State,
    loc.Country
ORDER BY 
    o.Owner_ID;



-- Paymnet Summary View 

CREATE OR REPLACE VIEW Payment_Summary_View AS
SELECT 
    p.payment_id,
    p.lease_id,
    l.customer_id,
    c.first_name||' '||c.last_name as customer_name,
    p.payment_mode,
    p.transaction_amount,
    p.transaction_date
FROM PAYMENT p
JOIN 
    LEASE l ON p.Lease_ID = l.Lease_ID
JOIN 
    CUSTOMER c ON c.Customer_ID = l.Customer_ID;


CREATE OR REPLACE FORCE EDITIONABLE VIEW "WAREHOUSE_APP_ADMIN_USER"."CUSTOMER_LEASE_DETAILS_VIEW" (
    "CUSTOMER_ID",
    "CUSTOMER_NAME",
    "LEASE_ID",
    "WAREHOUSE_NAME",
    "WAREHOUSE_ADDRESS",
    "START_DATE",
    "END_DATE",
    "LEASE_AMOUNT",
    "PAYMENT_STATUS",
    "BALANCE_AMOUNT",
    "LEASE_STATUS"
) DEFAULT COLLATION "USING_NLS_COMP" AS 
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        l.lease_id,
        w.warehouse_name AS warehouse_name,
        w.street_address AS warehouse_address,
        l.start_date,
        l.end_date,
        l.lease_amount,
        l.payment_status,
        l.balance_amount,
        CASE
            WHEN SYSDATE < l.start_date THEN 'Not Started'
            WHEN SYSDATE BETWEEN l.start_date AND l.end_date THEN 'Active'
            ELSE 'Expired'
        END AS lease_status
    FROM
        lease l
        INNER JOIN warehouse w ON l.warehouse_id = w.warehouse_id
        INNER JOIN customer c ON l.customer_id = c.customer_id
    UNION ALL
    SELECT
        cl.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        cl.lease_id,
        w.warehouse_name AS warehouse_name,
        w.street_address AS warehouse_address,
        cl.start_date,
        cl.end_date,
        cl.lease_amount,
        NULL AS payment_status,
        0 AS balance_amount,
        'Cancelled' AS lease_status
    FROM
        cancelled_lease cl
        INNER JOIN warehouse w ON cl.warehouse_id = w.warehouse_id
        INNER JOIN customer c ON cl.customer_id = c.customer_id
    ORDER BY
        customer_id;


GRANT SELECT ON "WAREHOUSE_APP_ADMIN_USER"."CUSTOMER_LEASE_DETAILS_VIEW" TO "WAREHOUSE_CUSTOMER";

-- Service Request View

CREATE OR REPLACE VIEW service_request_status_warehouse_view AS
SELECT r.Request_ID,w.Warehouse_ID,w.Warehouse_Name,l1.unit_id as unit_fault,r.Request_Desc,r.Request_Date,r.Request_Status,c.customer_id,c.First_Name||' '||c.Last_Name as Customer_Name,c.email,c.phone
FROM SERVICE_REQUEST r 
JOIN LEASE_UNIT l1 ON r.Lease_Unit_ID = l1.Lease_Unit_ID
JOIN LEASE l2 ON l1.Lease_ID = l2.Lease_ID
JOIN WAREHOUSE w ON l2.Warehouse_ID = w.Warehouse_ID
JOIN CUSTOMER c ON l2.Customer_ID = c.Customer_ID
ORDER BY r.Request_Date DESC
;
 

-- -- Lease Units Available/Status View
   

CREATE OR REPLACE FORCE EDITIONABLE VIEW "WAREHOUSE_APP_ADMIN_USER"."LEASE_UNITS_AVAILABILITY_STATUS" (
    "WAREHOUSE_ID",
    "WAREHOUSE_NAME",
    "TYPE_NAME",
    "DAILY_RENT",
    "UNIT_ID",
    "LEASE_ID",
    "START_DATE",
    "END_DATE",
    "CUSTOMER_ID",
    "FIRST_NAME",
    "LAST_NAME",
    "AVAILABILITY_STATUS"
) DEFAULT COLLATION "USING_NLS_COMP" AS 
SELECT
    W.WAREHOUSE_ID,
    W.WAREHOUSE_NAME,
    WT.TYPE_NAME,
    WT.DAILY_RENT,
    U.UNIT_ID,
    L.LEASE_ID,
    L.START_DATE,
    L.END_DATE,
    C.CUSTOMER_ID,
    C.FIRST_NAME,
    C.LAST_NAME,
    CASE WHEN LU.LEASE_ID IS NULL THEN 'Available' ELSE 'Not Available' END AS AVAILABILITY_STATUS
FROM
    WAREHOUSE W
JOIN
    WAREHOUSE_TYPE WT ON W.WAREHOUSE_TYPE_ID = WT.WAREHOUSE_TYPE_ID
JOIN
    UNIT U ON W.WAREHOUSE_ID = U.WAREHOUSE_ID
LEFT JOIN
    LEASE_UNIT LU ON U.UNIT_ID = LU.UNIT_ID
LEFT JOIN
    LEASE L ON LU.LEASE_ID = L.LEASE_ID
LEFT JOIN
    CUSTOMER C ON L.CUSTOMER_ID = C.CUSTOMER_ID
WHERE
    L.END_DATE IS NULL OR L.END_DATE > SYSDATE;



-- Warehouse Availability View

CREATE OR REPLACE VIEW warehouse_availability_status_view AS
SELECT
    w.warehouse_id,
    loc.zip,
    w.warehouse_name AS warehouse_name,
    w.street_address AS warehouse_address,
    wt.type_name AS warehouse_type,
    wt.daily_rent AS days_unit_rate,
    (SELECT COUNT(*) FROM unit u WHERE u.warehouse_id = w.warehouse_id) AS total_units,
    NVL(au.available_units_count, 0) AS units_leased,
    (SELECT COUNT(*) FROM lease l WHERE l.warehouse_id = w.warehouse_id 
     AND l.start_date <= TRUNC(SYSDATE) AND l.end_date >= TRUNC(SYSDATE)
    ) AS active_leases,
    (SELECT COUNT(*) FROM lease l WHERE l.warehouse_id = w.warehouse_id 
     AND l.end_date < TRUNC(SYSDATE)
    ) AS expired_leases,
    (SELECT COUNT(*) FROM lease l WHERE l.warehouse_id = w.warehouse_id 
     AND l.start_date > TRUNC(SYSDATE)
    ) AS not_started_leases,
    (SELECT COUNT(*) FROM cancelled_lease c WHERE c.warehouse_id = w.warehouse_id) AS cancelled_leases,
    (SELECT COUNT(*) FROM lease l WHERE l.warehouse_id = w.warehouse_id) + 
    (SELECT COUNT(*) FROM cancelled_lease c WHERE c.warehouse_id = w.warehouse_id) AS total_leases
FROM
    warehouse w
INNER JOIN location loc ON w.location_id = loc.location_id
INNER JOIN warehouse_type wt ON w.warehouse_type_id = wt.warehouse_type_id
LEFT JOIN
    (SELECT w.warehouse_id, COUNT(*) AS available_units_count
     FROM warehouse w
     LEFT JOIN lease_unit lu ON lu.unit_id IN (SELECT unit_id FROM unit WHERE warehouse_id = w.warehouse_id)
     LEFT JOIN lease l ON lu.lease_id = l.lease_id
     WHERE l.end_date >= TRUNC(SYSDATE) AND l.start_date <= TRUNC(SYSDATE)
     GROUP BY w.warehouse_id
    ) au ON au.warehouse_id = w.warehouse_id
ORDER BY
    w.warehouse_id,
    loc.zip;