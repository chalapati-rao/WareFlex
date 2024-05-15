-- Calling the procedure to insert location data into the tables
BEGIN
    InsertLocation('12345', 'New York', 'New York', 'USA');
    InsertLocation('23456', 'Los Angeles', 'California', 'USA');
    InsertLocation('34567', 'Chicago', 'Illinois', 'USA');
    InsertLocation('45678', 'Houston', 'Texas', 'USA');
    InsertLocation('56789', 'Phoenix', 'Arizona', 'USA');
END;
/

-- Calling the procedure to insert customer data into the tables
BEGIN
    WAREHOUSE_APP_ADMIN_USER.INSERT_CUSTOMER_RECORD('John', 'Doe', '123 Main St', 'john.doe@example.com', '1234567890','12345', 'New York', 'New York', 'USA');
    WAREHOUSE_APP_ADMIN_USER.INSERT_CUSTOMER_RECORD('Alice', 'Smith', '456 Elm St', 'alice.smith@example.com', '2345678901','23456', 'Los Angeles', 'California', 'USA');
    WAREHOUSE_APP_ADMIN_USER.INSERT_CUSTOMER_RECORD('Bob', 'Johnson', '789 Oak St', 'bob.johnson@example.com', '3456789012','34567', 'Chicago', 'Illinois', 'USA');
    WAREHOUSE_APP_ADMIN_USER.INSERT_CUSTOMER_RECORD('Emily', 'Brown', '321 Maple St', 'emily.brown@example.com', '4567890123','45678', 'Houston', 'Texas', 'USA');
    WAREHOUSE_APP_ADMIN_USER.INSERT_CUSTOMER_RECORD('Michael', 'Wilson', '654 Pine St', 'michael.wilson@example.com', '5678901234','56789', 'Phoenix', 'Arizona', 'USA');
END;
/


-- Calling the procedure to insert warehouse type data into the tables
-- BEGIN
--     InsertWarehouseType('Dry Storage', 1000.00);
--     InsertWarehouseType('Cold Storage', 1500.00);
--     InsertWarehouseType('Bulk Storage', 1200.00);
--     InsertWarehouseType('Distribution Center', 2000.00);
--     InsertWarehouseType('Fulfillment Center', 1800.00);
--     InsertWarehouseType('Specialized Storage', 2500.00);
-- END;
-- /

DECLARE
    v_warehouse_type_id WAREHOUSE_TYPE.Warehouse_Type_ID%TYPE;
BEGIN
    v_warehouse_type_id := InsertWarehouseTypeRecord('Dry Storage', 1000.00);
    DBMS_OUTPUT.PUT_LINE('Warehouse Type ID for Dry Storage: ' || v_warehouse_type_id);

    v_warehouse_type_id := InsertWarehouseTypeRecord('Cold Storage', 1500.00);
    DBMS_OUTPUT.PUT_LINE('Warehouse Type ID for Cold Storage: ' || v_warehouse_type_id);

    v_warehouse_type_id := InsertWarehouseTypeRecord('Bulk Storage', 1200.00);
    DBMS_OUTPUT.PUT_LINE('Warehouse Type ID for Bulk Storage: ' || v_warehouse_type_id);

    v_warehouse_type_id := InsertWarehouseTypeRecord('Distribution Center', 2000.00);
    DBMS_OUTPUT.PUT_LINE('Warehouse Type ID for Distribution Center: ' || v_warehouse_type_id);
END;
/


-- Calling the procedure to insert warehouse owner data into the tables
BEGIN
    InsertWarehouseOwner('John Doe', '123 Main St', 'john.doe@example.com', '1234567890','1');
    InsertWarehouseOwner('Jane Smith', '456 Elm St', 'jane.smith@example.com', '9876543210','1');
    InsertWarehouseOwner('David Johnson', '789 Oak St', 'david.johnson@example.com', '1112223333','2');
    InsertWarehouseOwner('Sarah Williams', '321 Pine St', 'sarah.williams@example.com', '4445556666','3');
    InsertWarehouseOwner('Michael Brown', '654 Maple St', 'michael.brown@example.com', '7778889999','5');
END;
/

-- Calling the procedure to insert warehouse data into the tables
BEGIN
    InsertWarehouse('WAREHOUSE A', '123 Main St', 10, 1, 1, 1, 40.7128, -74.0060);
    InsertWarehouse('WAREHOUSE B', '456 Elm St', 50, 1, 1, 2, 34.0522, -118.2437);
    InsertWarehouse('WAREHOUSE C', '789 Oak St', 20, 1, 2, 3, 29.7604, -95.3698);
    InsertWarehouse('WAREHOUSE D', '321 Pine St', 25, 2, 4, 4, 41.8781, -87.6298);
    InsertWarehouse('WAREHOUSE E', '654 Maple St', 30, 2, 5, 5, 37.7749, -122.4194);
    InsertWarehouse('WAREHOUSE F', '987 Cedar St', 35, 3, 3, 2, 33.4484, -112.0740);
    InsertWarehouse('WAREHOUSE G', '159 Birch St', 40, 4, 2, 1, 32.7157, -117.1611);
    InsertWarehouse('WAREHOUSE H', '111 Oak St', 40, 2, 3, 2, 34.0822, -118.2437);
    InsertWarehouse('WAREHOUSE I', '222 Elm St', 50, 3, 1, 3, 40.7198, -74.0060);
    InsertWarehouse('WAREHOUSE J', '333 Pine St', 50, 4, 2, 4, 34.0502, -118.2437);
    InsertWarehouse('WAREHOUSE K', '444 Oak St', 60, 1, 1, 5, 29.1604, -95.3698);
    InsertWarehouse('WAREHOUSE L', '555 Cedar St', 60, 2, 2, 2, 41.8721, -87.6298);
    InsertWarehouse('WAREHOUSE M', '666 Maple St', 10, 1, 3, 5, 37.7049, -122.4194);
    InsertWarehouse('WAREHOUSE N', '777 Birch St', 24, 2, 1, 1, 33.9484, -112.0740);
    InsertWarehouse('WAREHOUSE O', '888 Pine St', 18, 4, 1, 4, 37.7349, -122.4194);
END;
/
-- Calling the procedure to insert warehouse employee data into the tables
BEGIN
    InsertWarehouseEmployee('1', 'John Doe', '123 Main St', 'john.doe@example.com', '1234567890', 'Manager', 50000.00,'1');
    InsertWarehouseEmployee('2', 'Mark Johnson', '456 Elm St', 'mark.johnson@example.com', '1234567892', 'Manager', 48000.00,'3');
    
    InsertWarehouseEmployee('3', 'Michael Williams', '789 Oak St', 'michael.williams@example.com', '1234567894', 'Manager', 52000.00,'5');
    
    InsertWarehouseEmployee('4', 'David Garcia', '321 Pine St', 'david.garcia@example.com', '1234567896', 'Manager', 53000.00,'2');
    
    InsertWarehouseEmployee('5', 'James Rodriguez', '654 Maple St', 'james.rodriguez@example.com', '1234567898', 'Manager', 54000.00,'4');
    
    InsertWarehouseEmployee('6', 'Logan Smith', '987 Cedar St', 'logan.smith@example.com', '1234567800', 'Manager', 55000.00,'1');
    
    InsertWarehouseEmployee('7', 'Noah Brown', '753 Birch St', 'noah.brown@example.com', '1234567802', 'Manager', 56000.00,'3');
    
    InsertWarehouseEmployee('8', 'William Martinez', '852 Oak St', 'william.martinez@example.com', '1234567804', 'Manager', 57000.00,'5');
    
    InsertWarehouseEmployee('9', 'Ethan Anderson', '369 Elm St', 'ethan.anderson@example.com', '1234567806', 'Manager', 58000.00,'2');
    
    InsertWarehouseEmployee('10', 'Oliver Wilson', '147 Walnut St', 'oliver.wilson@example.com', '1234567808', 'Manager', 59000.00,'4');
    END;
/


-- Calling the function to calculate lease amount and insert lease data into the tables
BEGIN
    -- Customer_Id, units_to_lease, warehouse_type, location, start_date, end_date
    InsertLease('john.doe@example.com', 20, 'Cold Storage', '12345', '04/01/2024', '06/01/2024');
    InsertLease('bob.johnson@example.com', 4, 'Cold Storage', '12345', '05/12/2024', '06/04/2024');
    InsertLease('john.doe@example.com', 12, 'Dry Storage', '12345', '04/18/2024', '04/29/2024');
    InsertLease('michael.wilson@example.com', 4, 'Dry Storage', '12345', '06/15/2024', '07/30/2024');
    InsertLease('alice.smith@example.com', 10, 'Cold Storage', '23456', '04/17/2024', '06/15/2024');
    InsertLease('alice.smith@example.com', 25, 'Bulk Storage', '34567', '04/17/2024', '05/24/2024');
    InsertLease('emily.brown@example.com', 6, 'Cold Storage', '23456', '05/30/2024', '06/01/2024');
    InsertLease('john.doe@example.com', 3, 'Dry Storage', '34567', '04/19/2024', '12/29/2024');
    InsertLease('emily.brown@example.com', 10,'Distribution Center', '12345', '05/06/2024', '05/12/2024');
    InsertLease('john.doe@example.com', 15, 'Bulk Storage', '34567', '04/24/2024', '05/14/2024');
    InsertLease('michael.wilson@example.com', 5, 'Cold Storage', '56789', '05/14/2024', '05/30/2024');
    InsertLease('michael.wilson@example.com', 10, 'Dry Storage', '12345', '02/10/2024', '04/12/2024');
    InsertLease('alice.smith@example.com', 15, 'Bulk Storage', '34567', '01/13/2024', '04/16/2024');
    InsertLease('bob.johnson@example.com', 6, 'Cold Storage', '12345', '03/12/2024', '03/15/2024');
END;
/


-- Calling the procedure to insert payment data into the tables
BEGIN
    process_payment(1,'CASH', 5000.00);
    process_payment(2,'CARD', 1500.00);
    process_payment(2,'CASH', 6000.00);
    process_payment(4,'CASH', 10000.00);
    process_payment(5,'CASH', 4000.98);
    process_payment(5,'CARD', 1250.00);
    process_payment(1,'CARD', 2800);
    process_payment(5,'CHEQUE', 1000.00);
    process_payment(5,'CHEQUE', 1500.00);
    process_payment(1,'CASH', 1200.00);
    process_payment(1,'CARD', 2000.00);
    process_payment(3,'CARD', 4500);
END;
/

-- Calling the procedure to insert service request data into the tables

BEGIN
    InsertServiceRequest(1, 'Request 1', 1);
    InsertServiceRequest(3, 'Request 3', 1);
    InsertServiceRequest(4, 'Request 4', 1);
    InsertServiceRequest(6, 'Request 6', 1);
    InsertServiceRequest(7, 'Request 7', 2);
    InsertServiceRequest(8, 'Request 8', 1);
END;
/

--exec InsertWarehouseWithLocationAndType('new WAREHOUSE ', 'New Type', 70,5000.00,'338 warren st','02119', 'Boston', 'Massachusetts', 'USA','christopher.lee@example.com', 40.7128, -74.0060);

--exec InsertWarehouseWithLocationAndType('new WAREHOUSE ', 'SPECIAL TYPE', 30,2000.00,'250 HUNGTINTON AVE','02115', 'Boston', 'Massachusetts', 'USA','david.johnson@example.com', 45.7128, -14.0060);