PURGE RECYCLEBIN;
SET SERVEROUTPUT ON;
alter session set nls_date_format = 'MM/DD/YYYY';


CREATE OR REPLACE FUNCTION is_valid_integer(p_InputNum IN NUMBER) RETURN NUMBER IS
    v_Integer NUMBER;
BEGIN
    v_Integer := TO_NUMBER(p_InputNum);
    RETURN 1;
EXCEPTION
    WHEN VALUE_ERROR THEN
        RETURN 0;
END is_valid_integer;
/

CREATE OR REPLACE FUNCTION is_valid_date(p_InputString IN VARCHAR2) RETURN NUMBER IS
    v_Date DATE;
BEGIN
    -- Try to convert the input string to a date
    v_Date := TO_DATE(p_InputString, 'MM/DD/YYYY');
    
    -- If successful, return 1 indicating a valid date
    RETURN 1;
EXCEPTION
    -- Handle exceptions
    WHEN OTHERS THEN
        -- If an exception occurs, return 0 indicating an invalid date
        RETURN 0;
END is_valid_date;
/


CREATE OR REPLACE FUNCTION is_valid_zip(p_Zip IN VARCHAR2) RETURN NUMBER IS
BEGIN
    IF REGEXP_LIKE(p_Zip, '^\d{5}$') THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END is_valid_zip;
/

CREATE OR REPLACE FUNCTION is_valid_phone(p_PhoneNumber IN VARCHAR2) RETURN NUMBER IS
BEGIN
    IF REGEXP_LIKE(p_PhoneNumber, '^[[:digit:]]{10}$') THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END is_valid_phone;
/

CREATE OR REPLACE FUNCTION is_valid_email(p_Email IN VARCHAR2) RETURN NUMBER IS
BEGIN
    IF REGEXP_LIKE(p_Email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END is_valid_email;
/
-- Function to check if customer ID exists
CREATE OR REPLACE FUNCTION customer_exists (
    p_Customer_Email CUSTOMER.Email%TYPE
) RETURN BOOLEAN
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM CUSTOMER
    WHERE UPPER(Email) = UPPER(p_Customer_Email);
    
    RETURN v_count > 0;
END customer_exists;
/

-- function to check if a owner with owner exists.
CREATE OR REPLACE FUNCTION OWNER_EXISTS(p_Email WAREHOUSE_OWNER.Email%TYPE) RETURN BOOLEAN IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM WAREHOUSE_OWNER
    WHERE UPPER(Email) = UPPER(p_Email);

    RETURN v_count > 0;
END;
/


-- Procedure to insert a warehouse type record
CREATE OR REPLACE PROCEDURE InsertWarehouseType (
    p_Type_Name WAREHOUSE_TYPE.Type_Name%TYPE,
    p_daily_rent WAREHOUSE_TYPE.Daily_Rent%TYPE
)
IS
    TYPE_NAME_NULL EXCEPTION;
    DAILY_RENT_NULL EXCEPTION;
    INVALID_RENT EXCEPTION;
    v_count NUMBER;
BEGIN

-- Check if type name is null
    IF p_Type_Name IS NULL THEN
        RAISE TYPE_NAME_NULL;
    END IF;

    -- Check if daily rent is null
    IF p_daily_rent IS NULL THEN
        RAISE DAILY_RENT_NULL;
    END IF;
    --check if daily rent is greater than 0
    IF p_daily_rent <= 0 THEN
        RAISE INVALID_RENT;
    END IF;

    BEGIN
    SELECT COUNT(*) into v_count FROM WAREHOUSE_TYPE WHERE UPPER(Type_Name) = UPPER(p_Type_Name) AND Daily_Rent = p_daily_rent;
    IF v_count > 0 THEN
        RAISE DUP_VAL_ON_INDEX;
    ELSE
        INSERT INTO WAREHOUSE_TYPE (Warehouse_Type_ID, Type_Name, Daily_Rent)
        VALUES (Warehouse_Type_ID_SEQ.NEXTVAL, p_Type_Name, p_daily_rent);
    END IF;
END;

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Warehouse Type '|| p_Type_Name || ' inserted successfully');
EXCEPTION
    WHEN TYPE_NAME_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Ware House Type record: Ware House Type name cannot be null.');   
    WHEN DAILY_RENT_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Ware House Type record: Ware House Daily rent cannot be null.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Warehouse Type '|| p_Type_Name || ' with same price already exists');
    WHEN INVALID_RENT THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Ware House Type record: Invalid Daily rent.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid input');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END InsertWarehouseType;
/

CREATE OR REPLACE FUNCTION InsertWarehouseTypeRecord(
    p_type_name IN WAREHOUSE_TYPE.Type_Name%TYPE,
    p_daily_rent IN WAREHOUSE_TYPE.Daily_Rent%TYPE
) RETURN WAREHOUSE_TYPE.Warehouse_Type_ID%TYPE
IS
    v_warehouse_type_id WAREHOUSE_TYPE.Warehouse_Type_ID%TYPE;
    TYPE_NAME_NULL EXCEPTION;
    DAILY_RENT_NULL EXCEPTION;
    INVALID_RENT EXCEPTION;
    INVALID_TYPE EXCEPTION;
    TYPE_EXISTS EXCEPTION;
    v_count NUMBER;
BEGIN
    -- Check if type name is null
    IF p_type_name IS NULL THEN
        RAISE TYPE_NAME_NULL;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Type Name: ' || p_type_name);

    -- Check if daily rent is null
    IF p_daily_rent IS NULL THEN
        RAISE DAILY_RENT_NULL;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Daily Rent: ' || p_daily_rent);

    -- Check if daily rent is greater than 0
    IF p_daily_rent <= 0 THEN
        RAISE INVALID_RENT;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Daily Rent is valid');
    
    BEGIN
        SELECT COUNT(*) into v_count FROM WAREHOUSE_TYPE WHERE UPPER(Type_Name) = UPPER(p_Type_Name) AND Daily_Rent = p_daily_rent;
        IF v_count > 0 THEN
            RAISE TYPE_EXISTS;
        ELSE
            INSERT INTO WAREHOUSE_TYPE (Warehouse_Type_ID, Type_Name, Daily_Rent)
        VALUES (Warehouse_Type_ID_SEQ.NEXTVAL, p_type_name, p_daily_rent)
        RETURNING Warehouse_Type_ID INTO v_warehouse_type_id;
        COMMIT;
    END IF;
    END;
    

    
    RETURN v_warehouse_type_id;
EXCEPTION
        
    WHEN TYPE_NAME_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Warehouse Type name cannot be null.');
        RETURN null;
    WHEN DAILY_RENT_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Warehouse Daily rent cannot be null.');
        RETURN null;
    WHEN INVALID_RENT THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid Daily rent.');
        RETURN null;
    WHEN INVALID_TYPE THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid Warehouse Type.');
        RETURN null;
    WHEN TYPE_EXISTS THEN
        DBMS_OUTPUT.PUT_LINE('Error: Warehouse Type with the same price already exists.');
        RETURN null;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN null;
END InsertWarehouseTypeRecord;
/


-- Procedure to process payment and update payment status and balance amount in the LEASE table
CREATE OR REPLACE PROCEDURE process_payment(
    p_lease_id IN LEASE.Lease_ID%TYPE,
    p_payment_mode IN PAYMENT.Payment_Mode%TYPE,
    p_transaction_amount IN PAYMENT.Transaction_Amount%TYPE
) AS
    v_balance_amount NUMBER;
    v_transaction_date PAYMENT.Transaction_Date%TYPE := SYSTIMESTAMP;
    INVALID_PAYMENT_MODE EXCEPTION;
    TRANSACTION_AMOUNT_INVALID EXCEPTION;
    LEASE_NOT_FOUND EXCEPTION;
    LEASE_ALREADY_PAID EXCEPTION;
    TRANSACTION_AMOUNT_EXCEEDS_TOTAL_BALANCE EXCEPTION;
    v_lease_exists NUMBER;
    LEASE_NULL EXCEPTION;
    v_lease_start_date LEASE.Start_Date%TYPE;
    LEASE_NOT_STARTED EXCEPTION;
BEGIN
    IF p_transaction_amount <= 0 OR p_transaction_amount IS NULL THEN
        RAISE TRANSACTION_AMOUNT_INVALID;
    END IF;

    IF p_payment_mode IS NULL THEN
        RAISE INVALID_PAYMENT_MODE;
    END IF;

    IF UPPER(p_payment_mode) NOT IN ('CASH', 'CARD', 'CHEQUE') THEN
        RAISE INVALID_PAYMENT_MODE;
    END IF;

    IF p_lease_id IS NULL THEN
        RAISE LEASE_NULL;
    END IF;

    -- Check if lease exists
    SELECT COUNT(*)
    INTO v_lease_exists
    FROM LEASE
    WHERE Lease_ID = p_lease_id;

    IF v_lease_exists = 0 THEN
        RAISE LEASE_NOT_FOUND;
    END IF;

    -- Check if the lease has already started
    SELECT Start_Date, Balance_Amount
    INTO v_lease_start_date, v_balance_amount
    FROM LEASE
    WHERE Lease_ID = p_lease_id;

    IF SYSDATE < v_lease_start_date THEN
       RAISE LEASE_NOT_STARTED;
    END IF;

    -- Check if the lease is already paid in full
    IF v_balance_amount <= 0 THEN
        RAISE LEASE_ALREADY_PAID;
    END IF;

    -- Calculate new balance amount after payment
    v_balance_amount := v_balance_amount - p_transaction_amount;

    -- Check if the transaction amount exceeds the remaining balance
    IF v_balance_amount < 0 THEN
        RAISE TRANSACTION_AMOUNT_EXCEEDS_TOTAL_BALANCE;
    END IF;

    -- Update payment status and balance amount in the LEASE table
    UPDATE LEASE
    SET Payment_Status = CASE
                            WHEN v_balance_amount = 0 THEN 'PAID'
                            ELSE 'PARTIAL'
                         END,
        Balance_Amount = v_balance_amount
    WHERE Lease_ID = p_lease_id;

    -- Insert payment record into the PAYMENT table using the local transaction date variable
    INSERT INTO PAYMENT (Lease_ID, Transaction_Date, Payment_Mode, Transaction_Amount)
    VALUES (p_lease_id, SYSTIMESTAMP, p_payment_mode, p_transaction_amount);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Payment processed successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('No lease found with the given Lease_ID');
    WHEN LEASE_ALREADY_PAID THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Lease is already paid in full');
    WHEN TRANSACTION_AMOUNT_EXCEEDS_TOTAL_BALANCE THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transaction amount exceeds the total balance amount');
    WHEN TRANSACTION_AMOUNT_INVALID THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Invalid transaction amount');
    WHEN INVALID_PAYMENT_MODE THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Invalid payment mode');
    WHEN LEASE_NOT_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Lease not found');
    WHEN LEASE_NULL THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Lease ID cannot be null');
    WHEN LEASE_NOT_STARTED THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Cannot process payment for a lease that has not started');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error processing payment: ' || SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE customer_makes_transaction(
    p_customer_email IN CUSTOMER.Email%TYPE,
    p_payment_mode IN PAYMENT.Payment_Mode%TYPE,
    p_transaction_amount IN PAYMENT.Transaction_Amount%TYPE
) AS
    v_customer_id CUSTOMER.Customer_ID%TYPE;
    v_total_balance_amount LEASE.Balance_Amount%TYPE := 0;
    v_remaining_transaction_amount PAYMENT.Transaction_Amount%TYPE := p_transaction_amount;
    TRANSACTION_AMOUNT_EXCEEDS_TOTAL_BALANCE EXCEPTION;
    CUSTOMER_DOES_NOT_EXIST EXCEPTION;
    CUSTOMER_NULL EXCEPTION;
    TRANSACTION_AMOUNT_INVALID EXCEPTION;

    -- Cursor to fetch leases associated with the customer's ID, ordered by end_date
    CURSOR lease_cursor IS
        SELECT Lease_ID, Balance_Amount, Start_Date
        FROM LEASE
        WHERE Customer_ID = v_customer_id
        AND Start_Date <= SYSDATE  -- Only consider leases that have started
        ORDER BY End_Date;
BEGIN
    -- CHECK IF TRANSACTION AMOUNT IS NULL OR LESS THAN 0
    IF p_transaction_amount IS NULL OR p_transaction_amount <= 0 THEN
        RAISE TRANSACTION_AMOUNT_INVALID;
    END IF;


    -- Check if the customer email is null
    IF p_customer_email IS NULL THEN
        RAISE CUSTOMER_NULL;
    END IF;

    -- Check if the customer exists
    IF NOT customer_exists(p_customer_email) THEN
        RAISE CUSTOMER_DOES_NOT_EXIST;
    END IF;

    -- Get the customer ID for the provided email
    SELECT Customer_ID INTO v_customer_id
    FROM CUSTOMER
    WHERE Email = p_customer_email;

    -- Fetch total balance amount of leases associated with the customer's ID
    SELECT SUM(Balance_Amount) INTO v_total_balance_amount
    FROM LEASE
    WHERE Customer_ID = v_customer_id
    AND Start_Date <= SYSDATE;

    -- Check if the total balance amount is less than the transaction amount
    IF v_total_balance_amount < p_transaction_amount THEN
        RAISE TRANSACTION_AMOUNT_EXCEEDS_TOTAL_BALANCE;
    END IF;

    -- Loop through leases and process payments
    FOR lease_rec IN lease_cursor LOOP
        -- Check if the remaining transaction amount is greater than 0
        IF v_remaining_transaction_amount > 0 THEN
            -- Calculate the payment amount for the current lease
            DECLARE
                v_payment_amount LEASE.Balance_Amount%TYPE;
            BEGIN
                -- Determine the payment amount for the current lease
                IF v_remaining_transaction_amount >= lease_rec.Balance_Amount THEN
                    v_payment_amount := lease_rec.Balance_Amount;
                ELSE
                    v_payment_amount := v_remaining_transaction_amount;
                END IF;

                -- Call process_payment procedure for the current lease
                process_payment(
                    p_lease_id => lease_rec.Lease_ID,
                    p_payment_mode => p_payment_mode,
                    p_transaction_amount => v_payment_amount
                );

                -- Update remaining transaction amount
                v_remaining_transaction_amount := v_remaining_transaction_amount - v_payment_amount;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error processing payment for Lease ID ' || lease_rec.Lease_ID || ': ' || SQLERRM);
            END;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Customer transaction processed successfully.');
EXCEPTION
    WHEN CUSTOMER_NULL THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Customer email should not be null.');
    WHEN CUSTOMER_DOES_NOT_EXIST THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Customer with the email ' || p_customer_email || ' does not exist.');
    WHEN TRANSACTION_AMOUNT_EXCEEDS_TOTAL_BALANCE THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transaction amount exceeds the total balance amount of the current/expired leases for the customer.');
    WHEN TRANSACTION_AMOUNT_INVALID THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Invalid transaction amount.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error processing customer transaction: ' || SQLERRM);
END;
/






-- Function to return Location_ID based on ZIP

CREATE OR REPLACE FUNCTION GET_LOCATION_ID(
    p_zip IN LOCATION.ZIP%TYPE,
    p_city IN LOCATION.City%TYPE,
    p_state IN LOCATION.State%TYPE,
    p_country IN LOCATION.Country%TYPE
) RETURN LOCATION.Location_ID%TYPE
IS
    v_location_id LOCATION.Location_ID%TYPE;
    l_city LOCATION.City%TYPE;
    l_state LOCATION.State%TYPE;
    l_country LOCATION.Country%TYPE;
       
BEGIN
    -- Check if the ZIP exists in the LOCATION table
    SELECT Location_ID INTO v_location_id
    FROM LOCATION
    WHERE ZIP = p_zip;
    
    IF v_location_id IS NOT NULL THEN
        SELECT City , State ,Country l_country into l_city,l_state,l_country  from Location  
        where ZIP = p_zip;
        
        IF UPPER(p_city) <> UPPER(l_city) OR UPPER(p_state) <> UPPER(l_state) OR UPPER(p_country) <> UPPER(l_country) THEN
        RETURN NULL;
        END IF;
        
    END IF;

    -- If ZIP does not exist, insert a new record into the LOCATION table
    IF v_location_id IS NULL THEN
        INSERT INTO LOCATION (Location_ID, ZIP, City, State, Country)
        VALUES (Location_ID_SEQ.NEXTVAL, p_zip, p_city, p_state, p_country)
        RETURNING Location_ID INTO v_location_id;
    END IF;

    RETURN v_location_id;
EXCEPTION

    WHEN NO_DATA_FOUND THEN
        -- Handle the case when no record is found for the ZIP
        INSERT INTO LOCATION (Location_ID, ZIP, City, State, Country)
        VALUES (Location_ID_SEQ.NEXTVAL, p_zip, p_city, p_state, p_country)
        RETURNING Location_ID INTO v_location_id;

        RETURN v_location_id;

    WHEN OTHERS THEN
        -- Handle any other exceptions
        RAISE_APPLICATION_ERROR(-20001, 'Error occurred: ' || SQLERRM);
END;
/
CREATE OR REPLACE FUNCTION GET_WAREHOUSETYPE_ID(
    p_type_name IN WAREHOUSE_TYPE.Type_Name%TYPE,
    p_daily_rent IN WAREHOUSE_TYPE.Daily_Rent%TYPE
) RETURN WAREHOUSE_TYPE.Warehouse_Type_ID%TYPE
AS
    v_warehouse_type_id WAREHOUSE_TYPE.Warehouse_Type_ID%TYPE;
BEGIN
    -- Check if the warehouse type exists in the WAREHOUSE_TYPE and return the Warehouse_Type_ID
    SELECT Warehouse_Type_ID INTO v_warehouse_type_id
    FROM WAREHOUSE_TYPE
    WHERE Type_Name = p_type_name
    AND Daily_Rent = p_daily_rent;

    -- If warehouse type does not exist, call the InsertWarehouseType function to insert a new record
    IF v_warehouse_type_id IS NULL THEN
        v_warehouse_type_id := InsertWarehouseTypeRecord(p_type_name, p_daily_rent);
    END IF;

    DBMS_OUTPUT.PUT_LINE('Warehouse Type ID: ' || v_warehouse_type_id);
    RETURN v_warehouse_type_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Call InsertWarehouseType function to insert a new record
        v_warehouse_type_id := InsertWarehouseTypeRecord(p_type_name, p_daily_rent);

        DBMS_OUTPUT.PUT_LINE('Warehouse Type ID: ' || v_warehouse_type_id);
        RETURN v_warehouse_type_id;
    WHEN OTHERS THEN
        -- Handle any other exceptions
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN null; -- or some other default value if needed
END;
/



CREATE OR REPLACE FUNCTION GET_OWNER_ID(
    p_email IN WAREHOUSE_OWNER.Email%TYPE
) RETURN WAREHOUSE_OWNER.Owner_ID%TYPE
AS
    v_owner_id WAREHOUSE_OWNER.Owner_ID%TYPE;
BEGIN
    -- Check if the owner exists in the WAREHOUSE_OWNER and return the Owner_ID
    SELECT Owner_ID INTO v_owner_id
    FROM WAREHOUSE_OWNER
    WHERE Email = p_email;

    DBMS_OUTPUT.PUT_LINE('Owner ID: ' || v_owner_id);
    RETURN v_owner_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle the case where no data is found
        RETURN null;
    WHEN OTHERS THEN
        -- Handle any other exceptions
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN null; -- or some other default value if needed
END;
/


-- Procedure to insert a customer record
CREATE OR REPLACE PROCEDURE InsertCustomer (
    p_First_Name CUSTOMER.First_Name%TYPE,
    p_Last_Name CUSTOMER.Last_Name%TYPE,
    p_Street_Address CUSTOMER.Street_Address%TYPE,
    p_Email CUSTOMER.Email%TYPE,
    p_Phone CUSTOMER.Phone%TYPE,
    p_Location_ID WAREHOUSE.Location_ID%TYPE
)
IS
    CUSTOMER_FIRST_NAME_NULL EXCEPTION;
    CUSTOMER_LAST_NAME_NULL EXCEPTION;
    CUSTOMER_EMAIL_NULL EXCEPTION;
    CUSTOMER_PHONE_NULL EXCEPTION;
    CUSTOMER_EMAIL_UNIQUE EXCEPTION;
    CUSTOMER_PHONE_CHECK EXCEPTION;
    CUSTOMER_EMAIL_FORMAT_EXCEPTION EXCEPTION;
    INVALID_LOCATION_DETAILS EXCEPTION;
    CUSTOMER_ALREADY_EXISTS EXCEPTION;
    e_count NUMBER;

BEGIN

    -- Check if customer first name is null
    IF p_first_name IS NULL THEN
        RAISE CUSTOMER_FIRST_NAME_NULL;
    END IF;

    -- Check if customer last name is null
    IF p_last_name IS NULL THEN
        RAISE CUSTOMER_LAST_NAME_NULL;
    END IF;
  
    -- Check if the email is null or it violates unique constraint
    IF p_Email IS NOT NULL THEN
        SELECT COUNT(*)
        INTO e_count
        FROM CUSTOMER
        WHERE UPPER(Email) = UPPER(p_Email)
        AND (UPPER(First_Name) <> UPPER(p_first_name) OR UPPER(Last_Name) <> UPPER(p_last_name));
    
        IF e_count > 0 THEN
            RAISE CUSTOMER_EMAIL_UNIQUE;
        END IF;
    ELSE
        RAISE CUSTOMER_EMAIL_NULL;
    END IF;
    
    -- Check email format
    IF NOT REGEXP_LIKE(p_Email, '^(\S+)\@(\S+)\.(\S+)$') THEN
        RAISE CUSTOMER_EMAIL_FORMAT_EXCEPTION;
    END IF;
    

    -- Check if phone number is null or its length is valid
    IF p_Phone IS NOT NULL THEN
        IF NOT regexp_like(p_Phone, '^[[:digit:]]{10}$') THEN
        RAISE CUSTOMER_PHONE_CHECK;
        END IF;
    ELSE
        RAISE CUSTOMER_PHONE_NULL;
    END IF;

    -- Check if the location ID is null
    IF p_Location_ID IS NULL THEN
        RAISE INVALID_LOCATION_DETAILS;
    END IF;

    -- Check if customer already exists
    IF customer_exists(p_Email) THEN
        RAISE CUSTOMER_ALREADY_EXISTS;
    ELSE
        INSERT INTO CUSTOMER (Customer_ID, First_Name, Last_Name, Street_Address, Email, Phone, Location_ID)
        VALUES (Customer_ID_SEQ.NEXTVAL, p_First_Name, p_Last_Name, p_Street_Address, p_Email, p_Phone, p_Location_ID);
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Customer '|| p_First_Name || ' ' || p_Last_Name || ' inserted successfully');
    END IF;

EXCEPTION
    WHEN CUSTOMER_FIRST_NAME_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Customer first name cannot be null.');
        
    WHEN CUSTOMER_LAST_NAME_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Customer last name cannot be null.');
        
    WHEN CUSTOMER_EMAIL_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Email cannot be null.');
        
    WHEN CUSTOMER_PHONE_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Phone cannot be null.');

    WHEN CUSTOMER_ALREADY_EXISTS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Customer already exists.');
        
    WHEN CUSTOMER_EMAIL_UNIQUE THEN
        DBMS_OUTPUT.PUT_LINE('Error updating customer information: Email already exists for another customer');
    
    WHEN CUSTOMER_EMAIL_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Invalid email format.');
  
    WHEN CUSTOMER_PHONE_CHECK THEN
        DBMS_OUTPUT.PUT_LINE('Error updating customer information: Invalid phone number (must be 10 digits)');
    
    WHEN INVALID_LOCATION_DETAILS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating customer information: Location details cannot be null.');
        
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Customer '|| p_First_Name || ' ' || p_Last_Name || ' already exists');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid input');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END InsertCustomer;
/


CREATE OR REPLACE PROCEDURE InsertLocation (
    p_ZIP LOCATION.ZIP%TYPE,
    p_City LOCATION.City%TYPE,
    p_State LOCATION.State%TYPE,
    p_Country LOCATION.Country%TYPE
)
IS
    ZIP_NULL EXCEPTION;
    ZIP_FORMAT_EXCEPTION EXCEPTION;
    CITY_NULL EXCEPTION;
    STATE_NULL EXCEPTION;
    COUNTRY_NULL EXCEPTION;
    CITY_INVALID_EXCEPTION EXCEPTION;
    STATE_INVALID_EXCEPTION EXCEPTION;
    COUNTRY_INVALID_EXCEPTION EXCEPTION;
BEGIN
    IF p_ZIP IS NULL THEN
        RAISE ZIP_NULL;
    END IF;

    -- Check Zip format
    IF NOT regexp_like(p_ZIP, '^[[:digit:]]{5}$') THEN
    RAISE ZIP_FORMAT_EXCEPTION;
    END IF;

    IF p_City IS NULL THEN
        RAISE CITY_NULL;
    END IF;

    IF p_State IS NULL THEN
        RAISE STATE_NULL;
    END IF;

    IF p_Country IS NULL THEN
        RAISE COUNTRY_NULL;
    END IF;

    -- Checking if City is valid
    IF NOT regexp_like(p_City, '^[a-zA-Z ]+$') THEN
        RAISE CITY_INVALID_EXCEPTION;
    END IF;

    -- Checking if State is valid
    IF NOT regexp_like(p_State, '^[a-zA-Z ]+$') THEN
        RAISE STATE_INVALID_EXCEPTION;
    END IF;

    -- Checking if Country is valid
    IF NOT regexp_like(p_Country, '^[a-zA-Z ]+$') THEN
        RAISE COUNTRY_INVALID_EXCEPTION;
    END IF;


    INSERT INTO LOCATION (Location_ID, ZIP, City, State, Country)
    VALUES (Location_ID_SEQ.NEXTVAL, p_ZIP, p_City, p_State, p_Country);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Location with ZIP '|| p_ZIP || ' inserted successfully');
EXCEPTION
    WHEN ZIP_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting LOCATION record: Location Zip cannot be null.');
    WHEN ZIP_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Invalid Zip format.');
    WHEN CITY_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting LOCATION record: Location City cannot be null.');
    WHEN STATE_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting LOCATION record: Location State cannot be null.');
    WHEN COUNTRY_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting LOCATION record: Location Country cannot be null.');
    WHEN CITY_INVALID_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting LOCATION record: Invalid City.');
    WHEN STATE_INVALID_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting LOCATION record: Invalid State.');
    WHEN COUNTRY_INVALID_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting LOCATION record: Invalid Country.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Location with ZIP '|| p_ZIP || ' already exists');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid input');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END InsertLocation;
/


-- Procedure to insert a warehouse owner record
CREATE OR REPLACE PROCEDURE InsertWarehouseOwner (
    p_Owner_Name WAREHOUSE_OWNER.Owner_Name%TYPE,
    p_Street_Address WAREHOUSE_OWNER.Street_Address%TYPE,
    p_Email WAREHOUSE_OWNER.Email%TYPE,
    p_Phone WAREHOUSE_OWNER.Phone%TYPE,
    p_Location_ID WAREHOUSE.Location_ID%TYPE
)
IS
    OWNER_ALREADY_EXISTS EXCEPTION;
    OWNER_NAME_NULL EXCEPTION;
    OWNER_EMAIL_NULL EXCEPTION;
    OWNER_PHONE_NULL EXCEPTION;
    OWNER_EMAIL_UNIQUE EXCEPTION;
    OWNER_PHONE_CHECK EXCEPTION;
    OWNER_EMAIL_FORMAT_EXCEPTION EXCEPTION;
    INVALID_LOCATION_DETAILS EXCEPTION;
    e_count NUMBER;

BEGIN

    -- Check if OWNER name is null
    IF p_Owner_Name IS NULL THEN
        RAISE OWNER_NAME_NULL;
    END IF;

    -- Check if the email is null or it violates unique constraint
    IF p_Email IS NOT NULL THEN
        SELECT COUNT(*)
        INTO e_count
        FROM WAREHOUSE_OWNER
        WHERE UPPER(Email) = UPPER(p_Email)
        AND (UPPER(Owner_Name) <> UPPER(p_Owner_Name));
    
        IF e_count > 0 THEN
            RAISE OWNER_EMAIL_UNIQUE;
        END IF;
    ELSE
        RAISE OWNER_EMAIL_NULL;
    END IF;
    -- Check email format
    IF NOT REGEXP_LIKE(p_Email, '^(\S+)\@(\S+)\.(\S+)$') THEN
        RAISE OWNER_EMAIL_FORMAT_EXCEPTION;
    END IF;

    IF p_Phone IS NOT NULL THEN
        IF NOT regexp_like(p_Phone, '^[[:digit:]]{10}$') THEN
            RAISE OWNER_PHONE_CHECK;
        END IF;
    ELSE
        RAISE OWNER_PHONE_NULL;
    END IF;
    IF owner_exists(p_Email) THEN
        RAISE OWNER_ALREADY_EXISTS;
    ELSE

    IF p_Location_ID IS NULL THEN
        RAISE INVALID_LOCATION_DETAILS;
        END IF;

    INSERT INTO WAREHOUSE_OWNER (Owner_ID, Owner_Name, Street_Address, Email, Phone, Location_ID)
    VALUES (Owner_ID_SEQ.NEXTVAL, p_Owner_Name, p_Street_Address, p_Email, p_Phone, p_Location_ID);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Warehouse Owner '|| p_Owner_Name || ' inserted successfully');
    END IF;
EXCEPTION
    WHEN OWNER_NAME_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Ware House owner record: Owner name cannot be null.');
    WHEN OWNER_EMAIL_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Ware House owner record: Owner Email cannot be null.');
    WHEN OWNER_PHONE_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Ware House owner record: Owner Phone cannot be null.');
    WHEN OWNER_ALREADY_EXISTS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Ware House owner record: Owner already exists.');
        
    WHEN OWNER_EMAIL_UNIQUE THEN
        DBMS_OUTPUT.PUT_LINE('Error updating Ware House owner information: Email already exists for another customer');
    
    WHEN OWNER_EMAIL_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Ware House owner record: Invalid email format.');
  
    WHEN OWNER_PHONE_CHECK THEN
        DBMS_OUTPUT.PUT_LINE('Error updating Ware House owner information: Invalid phone number (must be 10 digits)');
    
    WHEN INVALID_LOCATION_DETAILS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating Ware House owner information: location details ');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Warehouse Owner '|| p_Owner_Name || ' already exists');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid input');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END InsertWarehouseOwner;
/


CREATE OR REPLACE PROCEDURE InsertWarehouse (
    p_Warehouse_Name WAREHOUSE.Warehouse_Name%TYPE,
    p_Street_Address WAREHOUSE.Street_Address%TYPE,
    p_total_units WAREHOUSE.Total_Units%TYPE,
    p_Warehouse_Type_ID WAREHOUSE.Warehouse_Type_ID%TYPE,
    p_Location_ID WAREHOUSE.Location_ID%TYPE,
    p_Owner_ID WAREHOUSE.Owner_ID%TYPE,
    p_Location_LAT WAREHOUSE.Location_LAT%TYPE,
    p_Location_LONG WAREHOUSE.Location_LONG%TYPE
)
IS
    WAREHOUSE_NAME_NULL EXCEPTION;
    AVAILABLE_SPACE_NULL EXCEPTION;
    Owner_ID_NULL EXCEPTION;
    INVALID_WAREHOUSE_TYPE EXCEPTION;
    INVALID_LOCATION_DETAILS EXCEPTION;
    AVAILABLE_SPACE_INVALID EXCEPTION;
    WAREHOUSE_TYPE_NULL EXCEPTION;
    INVALID_OWNER_ID EXCEPTION;
    v_count NUMBER;
BEGIN

    IF p_Warehouse_Name IS NULL THEN
        RAISE WAREHOUSE_NAME_NULL;
    END IF;
    IF p_total_units IS NULL THEN
        RAISE AVAILABLE_SPACE_NULL;
    END IF;
    IF p_Owner_ID IS NULL THEN
        RAISE Owner_ID_NULL;
    END IF;
    IF p_Warehouse_Type_ID IS NULL THEN
        RAISE WAREHOUSE_TYPE_NULL;
    END IF;
    IF p_Location_ID IS NULL THEN
        RAISE INVALID_LOCATION_DETAILS;
    END IF;

    --CHECK IF OWNER EXISTS
    SELECT COUNT(*)
    INTO v_count
    FROM WAREHOUSE_OWNER
    WHERE Owner_ID = p_Owner_ID;

    IF v_count = 0 THEN
        RAISE INVALID_OWNER_ID;
    END IF;

    -- CHECK IF LOCATION EXISTS
    SELECT COUNT(*)
    INTO v_count
    FROM LOCATION
    WHERE Location_ID = p_Location_ID;

    IF v_count = 0 THEN
        RAISE INVALID_LOCATION_DETAILS;
    END IF;
    -- CHECK IF WAREHOUSE TYPE EXISTS
    SELECT COUNT(*)
    INTO v_count
    FROM WAREHOUSE_TYPE
    WHERE Warehouse_Type_ID = p_Warehouse_Type_ID;

    IF v_count = 0 THEN
        RAISE INVALID_WAREHOUSE_TYPE;
    END IF;


    --check if avaialble space is greater than 0
    IF p_total_units <= 0 THEN
        RAISE AVAILABLE_SPACE_INVALID;
    END IF;

    INSERT INTO WAREHOUSE (Warehouse_ID, Warehouse_Name, Street_Address, Total_Units, Warehouse_Type_ID, Location_ID, Owner_ID, Location_LAT, Location_LONG)
    VALUES (Warehouse_ID_SEQ.NEXTVAL, p_Warehouse_Name, p_Street_Address, p_total_units, p_Warehouse_Type_ID, p_Location_ID, p_Owner_ID, p_Location_LAT, p_Location_LONG);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Warehouse '|| p_Warehouse_Name || ' inserted successfully');
EXCEPTION
    WHEN WAREHOUSE_NAME_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Warehouse record: Warehouse name cannot be null.');
    WHEN AVAILABLE_SPACE_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Warehouse record: Available Space cannot be null.');
    WHEN Owner_ID_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Warehouse record: Owner ID cannot be null.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Warehouse '|| p_Warehouse_Name || ' already exists');
    WHEN INVALID_WAREHOUSE_TYPE THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Warehouse record: Invalid Warehouse Type.');
    WHEN INVALID_LOCATION_DETAILS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Warehouse record: Invalid Location Details.');
    WHEN AVAILABLE_SPACE_INVALID THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Warehouse record: Available Space should be greater than 0.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid input');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END InsertWarehouse;
/

CREATE OR REPLACE PROCEDURE InsertWarehouseWithLocationAndType (
    p_Warehouse_Name WAREHOUSE.Warehouse_Name%TYPE,
    p_type_name IN WAREHOUSE_TYPE.Type_Name%TYPE,
    p_Available_Space WAREHOUSE.TOTAL_UNITS%TYPE,
    p_daily_rent IN WAREHOUSE_TYPE.Daily_Rent%TYPE,
    p_Street_Address WAREHOUSE.Street_Address%TYPE,
    p_zip IN LOCATION.ZIP%TYPE,
    p_city IN LOCATION.City%TYPE,
    p_state IN LOCATION.State%TYPE,
    p_country IN LOCATION.Country%TYPE,
    p_Owner_Email IN WAREHOUSE_OWNER.Email%TYPE,
    p_Location_LAT WAREHOUSE.Location_LAT%TYPE,
    p_Location_LONG WAREHOUSE.Location_LONG%TYPE
)
AS
    v_location_id LOCATION.Location_ID%TYPE;
    v_warehouse_type_id WAREHOUSE_TYPE.Warehouse_Type_ID%TYPE;
    v_owner_id WAREHOUSE_OWNER.Owner_ID%TYPE;
    NO_LOCATION_FOUND EXCEPTION;
    NO_WAREHOUSE_TYPE_FOUND EXCEPTION;
    NO_OWNER_FOUND EXCEPTION;
    WAREHOUSE_NAME_NULL EXCEPTION;
    AVAILABLE_SPACE_NULL EXCEPTION;
    DAILY_RENT_NULL EXCEPTION;
    OWNER_EMAIL_NULL EXCEPTION;
    AVAILABLE_SPACE_INVALID EXCEPTION;

BEGIN
    IF p_Warehouse_Name IS NULL THEN
        RAISE WAREHOUSE_NAME_NULL;
    END IF;
    IF p_Available_Space IS NULL THEN
        RAISE AVAILABLE_SPACE_NULL;
    END IF;
    IF p_daily_rent IS NULL THEN
        RAISE DAILY_RENT_NULL;
    END IF;
    IF p_Owner_Email IS NULL THEN
        RAISE OWNER_EMAIL_NULL;
    END IF;
    IF p_Available_Space <= 0 THEN
        RAISE AVAILABLE_SPACE_INVALID;
    END IF;



    SAVEPOINT start_transaction;

    v_location_id := GET_LOCATION_ID(p_zip, p_city, p_state, p_country);
    dbms_output.put_line('Location ID: ' || v_location_id);
    IF v_location_id IS NULL THEN
        ROLLBACK TO start_transaction;
        RAISE NO_LOCATION_FOUND;
    END IF;

    v_warehouse_type_id := GET_WAREHOUSETYPE_ID(p_type_name, p_daily_rent);
    dbms_output.put_line('Warehouse Type ID: ' || v_warehouse_type_id);
    IF v_warehouse_type_id IS NULL THEN
        ROLLBACK TO start_transaction;
        RAISE NO_WAREHOUSE_TYPE_FOUND;
    END IF;

    v_owner_id := GET_OWNER_ID(p_Owner_Email);
    dbms_output.put_line('Owner ID: ' || v_owner_id);

    IF v_owner_id IS NULL THEN
        ROLLBACK TO start_transaction;
        RAISE NO_OWNER_FOUND;
    END IF;

    INSERT INTO WAREHOUSE (Warehouse_ID, Warehouse_Name, Street_Address, Total_Units, Warehouse_Type_ID, Location_ID, Owner_ID, Location_LAT, Location_LONG)
    VALUES (Warehouse_ID_SEQ.NEXTVAL, p_Warehouse_Name, p_Street_Address, p_Available_Space, v_warehouse_type_id , v_location_id, v_owner_id, p_Location_LAT, p_Location_LONG);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Warehouse '|| p_Warehouse_Name || ' inserted successfully');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Warehouse '|| p_Warehouse_Name || ' already exists');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid input');
    WHEN NO_LOCATION_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Location details invalid');
    WHEN NO_WAREHOUSE_TYPE_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Warehouse Type details invalid');
    WHEN NO_OWNER_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Owner Doesnt exist. You can add a new warehouse only if you are an existing owner.');
    WHEN OTHERS THEN
        ROLLBACK TO start_transaction;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END InsertWarehouseWithLocationAndType;
/

-- Procedure to insert a warehouse employee record
CREATE OR REPLACE PROCEDURE InsertWarehouseEmployee (
    p_Warehouse_ID WAREHOUSE_EMPLOYEE.Warehouse_ID%TYPE,
    p_Employee_Name WAREHOUSE_EMPLOYEE.Employee_Name%TYPE,
    p_Street_Address WAREHOUSE_EMPLOYEE.Street_Address%TYPE,
    p_Email WAREHOUSE_EMPLOYEE.Email%TYPE,
    p_Phone WAREHOUSE_EMPLOYEE.Phone%TYPE,
    p_Role WAREHOUSE_EMPLOYEE.Role%TYPE,
    p_Salary WAREHOUSE_EMPLOYEE.Salary%TYPE,
    p_Location_ID WAREHOUSE.Location_ID%TYPE
)
IS

    EMPLOYEE_NAME_NULL EXCEPTION;
    EMPLOYEE_EMAIL_NULL EXCEPTION;
    EMPLOYEE_PHONE_NULL EXCEPTION;
    EMPLOYEE_EMAIL_UNIQUE EXCEPTION;
    EMPLOYEE_PHONE_CHECK EXCEPTION;
    EMPLOYEE_EMAIL_FORMAT_EXCEPTION EXCEPTION;
    INVALID_LOCATION_DETAILS EXCEPTION;
    e_count NUMBER;

BEGIN

    IF p_Employee_Name IS NULL THEN
        RAISE EMPLOYEE_NAME_NULL;
    END IF;

    IF p_Email IS NOT NULL THEN
        SELECT COUNT(*)
        INTO e_count
        FROM WAREHOUSE_EMPLOYEE
        WHERE UPPER(Email) = UPPER(p_Email);
    
        IF e_count > 0 THEN
            RAISE EMPLOYEE_EMAIL_UNIQUE;
        END IF;
    ELSE
        RAISE EMPLOYEE_EMAIL_NULL;
    END IF;
    
    -- Check email format
    IF NOT REGEXP_LIKE(p_Email, '^(\S+)\@(\S+)\.(\S+)$') THEN
        RAISE EMPLOYEE_EMAIL_FORMAT_EXCEPTION;
    END IF;
    

    -- Check if phone number is null or its length is valid
    IF p_Phone IS NOT NULL THEN
        IF NOT regexp_like(p_Phone, '^[[:digit:]]{10}$') THEN
            RAISE EMPLOYEE_PHONE_CHECK;
        END IF;
    ELSE
        RAISE EMPLOYEE_PHONE_NULL;
    END IF;
    IF p_Location_ID IS NULL THEN
        RAISE INVALID_LOCATION_DETAILS;
        END IF;

    INSERT INTO WAREHOUSE_EMPLOYEE (Employee_ID, Warehouse_ID, Employee_Name, Street_Address, Email, Phone, Role, Salary, Location_ID)
    VALUES (Employee_ID_SEQ.NEXTVAL, p_Warehouse_ID, p_Employee_Name, p_Street_Address, p_Email, p_Phone, p_Role, p_Salary, p_Location_ID);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Employee '|| p_Employee_Name || ' inserted successfully');
EXCEPTION
    WHEN EMPLOYEE_NAME_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting WareHouse Employee record: WareHouse Employee last name cannot be null.');
        
    WHEN EMPLOYEE_EMAIL_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting WareHouse Employee record: Email cannot be null.');
        
    WHEN EMPLOYEE_PHONE_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting WareHouse Employee record: Phone cannot be null.');
        
    WHEN EMPLOYEE_EMAIL_UNIQUE THEN
        DBMS_OUTPUT.PUT_LINE('Error updating WareHouse Employee information: Email already exists for another WareHouse Employee');
    
    WHEN EMPLOYEE_EMAIL_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting WareHouse Employee record: Invalid email format.');
  
    WHEN EMPLOYEE_PHONE_CHECK THEN
        DBMS_OUTPUT.PUT_LINE('Error updating WareHouse Employee information: Invalid phone number length (must be 10 digits)');
    
    WHEN INVALID_LOCATION_DETAILS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating WareHouse Employee information: location details ');

    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Employee '|| p_Employee_Name || ' already exists');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid input');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END InsertWarehouseEmployee;
/

-- Procedure to insert a service request record
-- CREATE OR REPLACE PROCEDURE InsertServiceRequest (
--     p_Lease_Unit_ID SERVICE_REQUEST.Lease_Unit_ID%TYPE,
--     p_Request_Desc SERVICE_REQUEST.Request_Desc%TYPE,
--     p_Customer_ID SERVICE_REQUEST.Customer_ID%TYPE
-- )
-- IS
--     LEASE_UNIT_ID_NULL EXCEPTION;
--     LEASE_REQUEST_DESC_NULL EXCEPTION;
--     CUSTOMER_ID_NULL EXCEPTION;


-- BEGIN

--     IF p_Lease_Unit_ID IS NULL THEN
--         RAISE LEASE_UNIT_ID_NULL;
--     END IF;
--     IF p_Request_Desc IS NULL THEN
--         RAISE LEASE_REQUEST_DESC_NULL;
--     END IF;
--     IF p_Customer_ID IS NULL THEN
--         RAISE CUSTOMER_ID_NULL;
--     END IF;
--     INSERT INTO SERVICE_REQUEST (Request_ID, Lease_Unit_ID, Request_Desc, Customer_ID)
--     VALUES (Service_Request_ID_SEQ.NEXTVAL, p_Lease_Unit_ID, p_Request_Desc, p_Customer_ID);
    
--     COMMIT;
    
--     DBMS_OUTPUT.PUT_LINE('Service request inserted successfully');
-- EXCEPTION
--     WHEN LEASE_UNIT_ID_NULL THEN
--         DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Lease Unit ID cannot be null.');
--     WHEN LEASE_REQUEST_DESC_NULL THEN
--         DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Lease Request Desc cannot be null.');
--     WHEN CUSTOMER_ID_NULL THEN
--         DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Customer ID cannot be null.');

--     WHEN DUP_VAL_ON_INDEX THEN
--         DBMS_OUTPUT.PUT_LINE('Service request already exists');
--     WHEN VALUE_ERROR THEN
--         DBMS_OUTPUT.PUT_LINE('Invalid input');
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
-- END InsertServiceRequest;
-- /

-- CREATE OR REPLACE PROCEDURE InsertServiceRequest (
--     p_Lease_Unit_ID SERVICE_REQUEST.Lease_Unit_ID%TYPE,
--     p_Request_Desc SERVICE_REQUEST.Request_Desc%TYPE,
--     p_Customer_ID SERVICE_REQUEST.Customer_ID%TYPE
-- )
-- IS
--     LEASE_UNIT_ID_NULL EXCEPTION;
--     LEASE_REQUEST_DESC_NULL EXCEPTION;
--     CUSTOMER_ID_NULL EXCEPTION;
--     INVALID_LEASE_UNIT_ID EXCEPTION;
--     INVALID_CUSTOMER_LEASE_EXCEPTION EXCEPTION;

--     v_Lease_ID LEASE_UNIT.Lease_ID%TYPE;

-- BEGIN
--     IF p_Lease_Unit_ID IS NULL THEN
--         RAISE LEASE_UNIT_ID_NULL;
--     END IF;
--     IF p_Request_Desc IS NULL THEN
--         RAISE LEASE_REQUEST_DESC_NULL;
--     END IF;
--     IF p_Customer_ID IS NULL THEN
--         RAISE CUSTOMER_ID_NULL;
--     END IF;

--     -- Check if the provided Lease_Unit_ID is valid
--     SELECT Lease_ID INTO v_Lease_ID
--     FROM LEASE_UNIT
--     WHERE Lease_Unit_ID = p_Lease_Unit_ID;

--     -- Check if the lease associated with the Lease_Unit_ID belongs to the provided Customer_ID
--     SELECT 1
--     INTO v_Lease_ID
--     FROM LEASE_UNIT lu
--     JOIN LEASE l ON lu.Lease_ID = l.Lease_ID
--     WHERE lu.Lease_Unit_ID = p_Lease_Unit_ID
--     AND l.Customer_ID = p_Customer_ID;

--     -- If the control reaches here, the Lease_Unit_ID is valid and associated with the provided Customer_ID
--     INSERT INTO SERVICE_REQUEST (Request_ID, Lease_Unit_ID, Request_Desc, Customer_ID)
--     VALUES (Service_Request_ID_SEQ.NEXTVAL, p_Lease_Unit_ID, p_Request_Desc, p_Customer_ID);
    
--     COMMIT;
    
--     DBMS_OUTPUT.PUT_LINE('Service request inserted successfully');
-- EXCEPTION
--     WHEN LEASE_UNIT_ID_NULL THEN
--         DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Lease Unit ID cannot be null.');
--     WHEN LEASE_REQUEST_DESC_NULL THEN
--         DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Lease Request Desc cannot be null.');
--     WHEN CUSTOMER_ID_NULL THEN
--         DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Customer ID cannot be null.');
--     WHEN NO_DATA_FOUND THEN
--         RAISE INVALID_LEASE_UNIT_ID;
--     WHEN INVALID_LEASE_UNIT_ID THEN
--         DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Invalid Lease Unit ID.');
--     WHEN INVALID_CUSTOMER_LEASE_EXCEPTION THEN
--         DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Lease Unit does not belong to the provided Customer.');
--     WHEN DUP_VAL_ON_INDEX THEN
--         DBMS_OUTPUT.PUT_LINE('Service request already exists');
--     WHEN VALUE_ERROR THEN
--         DBMS_OUTPUT.PUT_LINE('Invalid input');
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
-- END InsertServiceRequest;
-- /

CREATE OR REPLACE PROCEDURE InsertServiceRequest (
    p_Lease_Unit_ID SERVICE_REQUEST.Lease_Unit_ID%TYPE,
    p_Request_Desc SERVICE_REQUEST.Request_Desc%TYPE,
    p_Customer_Email CUSTOMER.Email%TYPE
)
IS
    LEASE_UNIT_ID_NULL EXCEPTION;
    LEASE_REQUEST_DESC_NULL EXCEPTION;
    CUSTOMER_EMAIL_NULL EXCEPTION;
    CUSTOMER_NOT_FOUND EXCEPTION;
    INVALID_LEASE_UNIT_ID EXCEPTION;
    INVALID_CUSTOMER_LEASE_EXCEPTION EXCEPTION;

    v_Customer_ID CUSTOMER.Customer_ID%TYPE;
    v_Lease_ID LEASE_UNIT.Lease_ID%TYPE;

BEGIN
    IF p_Lease_Unit_ID IS NULL THEN
        RAISE LEASE_UNIT_ID_NULL;
    END IF;
    IF p_Request_Desc IS NULL THEN
        RAISE LEASE_REQUEST_DESC_NULL;
    END IF;
    IF p_Customer_Email IS NULL THEN
        RAISE CUSTOMER_EMAIL_NULL;
    END IF;

    -- Fetch the Customer_ID corresponding to the provided Customer_Email
    BEGIN
        SELECT Customer_ID INTO v_Customer_ID
        FROM CUSTOMER
        WHERE Email = p_Customer_Email;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE CUSTOMER_NOT_FOUND;
    END;

   -- Check if the provided Lease_Unit_ID is valid
    BEGIN
        SELECT Lease_ID INTO v_Lease_ID
        FROM LEASE_UNIT
        WHERE Lease_Unit_ID = p_Lease_Unit_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE INVALID_LEASE_UNIT_ID;
    END;

    -- Check if the lease associated with the Lease_Unit_ID belongs to the provided Customer_ID
    BEGIN
        SELECT 1
        INTO v_Lease_ID
        FROM LEASE_UNIT lu
        JOIN LEASE l ON lu.Lease_ID = l.Lease_ID
        WHERE lu.Lease_Unit_ID = p_Lease_Unit_ID
        AND l.Customer_ID = v_Customer_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE INVALID_CUSTOMER_LEASE_EXCEPTION;
    END;

    INSERT INTO SERVICE_REQUEST (Request_ID, Lease_Unit_ID, Request_Desc, Customer_ID)
    VALUES (Service_Request_ID_SEQ.NEXTVAL, p_Lease_Unit_ID, p_Request_Desc, v_Customer_ID);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Service request inserted successfully');
EXCEPTION
    WHEN LEASE_UNIT_ID_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Lease Unit ID cannot be null.');
    WHEN LEASE_REQUEST_DESC_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Lease Request Desc cannot be null.');
    WHEN CUSTOMER_EMAIL_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Customer Email cannot be null.');
    WHEN CUSTOMER_NOT_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Customer not found.');
    WHEN NO_DATA_FOUND THEN
        RAISE INVALID_LEASE_UNIT_ID;
    WHEN INVALID_LEASE_UNIT_ID THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Invalid Lease Unit ID.');
    WHEN INVALID_CUSTOMER_LEASE_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting Service Request record: Lease Unit does not belong to the provided Customer.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Service request already exists');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid input');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END InsertServiceRequest;
/


-- Trigger to insert units (based on warehouse space provided when creating a new warehouse) into the UNIT table after a warehouse is created

CREATE OR REPLACE TRIGGER insert_warehouse_units_trigger
AFTER INSERT ON WAREHOUSE
FOR EACH ROW
DECLARE
    num_units WAREHOUSE.TOTAL_UNITS%TYPE;
BEGIN
   
    num_units := :new.Total_Units;

    FOR i IN 1..num_units LOOP
        INSERT INTO UNIT (Unit_ID, Warehouse_ID)
        VALUES (Unit_ID_SEQ.NEXTVAL, :new.Warehouse_ID);
    END LOOP;
END;

/


CREATE OR REPLACE FUNCTION find_available_warehouse (
  p_Start_Date LEASE.Start_Date%TYPE,
  p_End_Date LEASE.End_Date%TYPE,
  p_Units_Leased LEASE.Units_Leased%TYPE,
  p_Warehouse_Type WAREHOUSE_TYPE.Type_Name%TYPE,
  p_Location_Zip LOCATION.ZIP%TYPE
) RETURN VARCHAR2
IS
  v_warehouse_id VARCHAR2(50);
BEGIN
  -- Finding a suitable warehouse for the lease
SELECT Warehouse_ID
INTO v_warehouse_id
FROM (
    SELECT sub.Warehouse_ID, COUNT(u.Unit_ID) AS Total_Units,
           (COUNT(u.Unit_ID) - NVL(COUNT(CASE WHEN l.Start_Date <= TO_DATE(p_Start_Date, 'MM/DD/YYYY') 
                                              AND l.End_Date >= TO_DATE(p_End_Date, 'MM/DD/YYYY') THEN lu.Unit_ID END), 0)) AS Available_Space
    FROM (
      SELECT u.Warehouse_ID
      FROM UNIT u
      JOIN WAREHOUSE w ON u.Warehouse_ID = w.Warehouse_ID
      JOIN WAREHOUSE_TYPE wt ON w.Warehouse_Type_ID = wt.Warehouse_Type_ID
      JOIN LOCATION loc ON w.Location_ID = loc.Location_ID
      LEFT JOIN LEASE_UNIT lu ON u.Unit_ID = lu.Unit_ID
      LEFT JOIN LEASE l ON lu.Lease_ID = l.Lease_ID
      WHERE loc.ZIP = p_Location_Zip
        AND wt.Type_Name = p_Warehouse_Type
      GROUP BY u.Warehouse_ID
    ) sub
    JOIN UNIT u ON sub.Warehouse_ID = u.Warehouse_ID
    LEFT JOIN LEASE_UNIT lu ON u.Unit_ID = lu.Unit_ID
    LEFT JOIN LEASE l ON lu.Lease_ID = l.Lease_ID
    GROUP BY sub.Warehouse_ID
    HAVING (COUNT(u.Unit_ID) - NVL(COUNT(CASE WHEN l.Start_Date <= TO_DATE(p_Start_Date, 'MM/DD/YYYY') 
                                                  AND l.End_Date >= TO_DATE(p_End_Date, 'MM/DD/YYYY') THEN lu.Unit_ID END), 0)) >= p_Units_Leased
    ) sub_query
ORDER BY Available_Space DESC
FETCH FIRST ROW ONLY;

  dbms_output.put_line('Warehouse ID: ' || v_warehouse_id);
  RETURN v_warehouse_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;
END find_available_warehouse;
/



CREATE OR REPLACE PROCEDURE validate_lease_dates (
    p_Start_Date VARCHAR2,
    p_End_Date VARCHAR2
)
IS
    LEASE_START_DATE_ERROR EXCEPTION;
    LEASE_END_DATE_ERROR EXCEPTION;
BEGIN
    IF TO_DATE(p_Start_Date,'MM/DD/YYYY') < SYSDATE - 1 THEN
        RAISE LEASE_START_DATE_ERROR;

    END IF;
    
    IF TO_DATE(p_End_Date,'MM/DD/YYYY') <= TO_DATE(p_Start_Date,'MM/DD/YYYY') THEN
        RAISE LEASE_END_DATE_ERROR;
    END IF;

    EXCEPTION
        WHEN LEASE_START_DATE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Lease Start date cannot be before the current date');
            RAISE;
        WHEN LEASE_END_DATE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Lease End date must be after the start date');
            RAISE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
END validate_lease_dates;
/

CREATE OR REPLACE PROCEDURE validate_lease_period (
    p_Start_Date DATE,
    p_End_Date DATE
)
IS
    LEASE_PERIOD_ERROR EXCEPTION;
BEGIN
    IF MONTHS_BETWEEN(p_End_Date, p_Start_Date) < 1 THEN
        -- RAISE_APPLICATION_ERROR(-20003, 'Lease period must be a minimum of one month');
        RAISE LEASE_PERIOD_ERROR;
    END IF;

    EXCEPTION
        WHEN LEASE_PERIOD_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Lease period must be a minimum of one month');
            RAISE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
END validate_lease_period;
/


CREATE OR REPLACE FUNCTION calculate_lease_amount(
    p_start_date LEASE.Start_Date%TYPE,
    p_end_date LEASE.End_Date%TYPE,
    p_required_units LEASE.Units_Leased%TYPE,
    p_warehouse_type WAREHOUSE_TYPE.Type_Name%TYPE
) RETURN NUMBER
IS
    v_daily_rent WAREHOUSE_TYPE.Daily_Rent%TYPE;
    v_lease_amount LEASE.LEASE_AMOUNT%TYPE;
    v_days NUMBER;
BEGIN
    -- Retrieve the monthly rate for the specified warehouse type
    SELECT wt.Daily_Rent
    INTO v_daily_rent
    FROM WAREHOUSE_TYPE wt
    WHERE wt.Type_Name = p_warehouse_type;

    -- Calculate the number of days between start and end dates
    v_days := p_end_date - p_start_date;

    DBMS_OUTPUT.PUT_LINE('Days: ' || v_days);


    -- Ensure the lease period is at least one month
    -- IF v_months < 1 THEN
    --     v_months := 1;
    -- END IF;

    -- Calculate the lease amount
    DBMS_OUTPUT.PUT_LINE('Daily rent: ' || v_daily_rent);
    DBMS_OUTPUT.PUT_LINE('Required Units: ' || p_required_units);
    v_lease_amount := v_daily_rent * v_days * p_required_units;
    DBMS_OUTPUT.PUT_LINE('Lease Amount: ' || v_lease_amount);

    RETURN v_lease_amount;
END calculate_lease_amount;
/


CREATE OR REPLACE PROCEDURE update_units_availability_and_lease_units_insertion(
    p_warehouse_id IN WAREHOUSE.Warehouse_ID%TYPE,
    p_units_leased IN LEASE.Units_Leased%TYPE,
    p_lease_id IN LEASE.Lease_ID%TYPE,
    p_lease_start_date IN LEASE.Start_Date%TYPE,
    p_lease_end_date IN LEASE.End_Date%TYPE
) AS
    CURSOR c_units IS
        SELECT UNIT_ID
        FROM UNIT
        WHERE WAREHOUSE_ID = p_warehouse_id
        AND UNIT_ID NOT IN (
            SELECT lu.Unit_ID
            FROM LEASE_UNIT lu
            JOIN LEASE l ON lu.Lease_ID = l.Lease_ID
            WHERE l.End_Date >= p_lease_start_date
            AND l.Start_Date <= p_lease_end_date
        )
        AND ROWNUM <= p_units_leased; -- Cursor to select available units for lease
BEGIN

    -- Update units' availability status and insert records into lease_units table
    FOR unit_rec IN c_units LOOP
        BEGIN
            -- Insert record into LEASE_UNIT table
            INSERT INTO LEASE_UNIT (Lease_Unit_ID, Unit_ID, Lease_ID)
            VALUES (Lease_Unit_ID_SEQ.NEXTVAL, unit_rec.UNIT_ID, p_lease_id);
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Error processing unit ' || unit_rec.UNIT_ID || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE InsertLease (
    p_Customer_Email CUSTOMER.Email%TYPE,
    p_Units_Leased LEASE.Units_Leased%TYPE,
    p_Warehouse_Type WAREHOUSE_TYPE.Type_Name%TYPE,
    p_Location_Zip LOCATION.ZIP%TYPE,
    p_Start_Date VARCHAR2,
    p_End_Date VARCHAR2
)
IS
    v_warehouse_id WAREHOUSE.Warehouse_ID%TYPE;
    v_lease_amount LEASE.Lease_Amount%TYPE;
    v_customer_id CUSTOMER.Customer_ID%TYPE;
    CUSTOMER_NOT_FOUND EXCEPTION;
    NO_WAREHOUSE_AVAILABLE EXCEPTION;
    NULL_CUSTOMER_EMAIL EXCEPTION;
    NULL_UNITS_LEASED EXCEPTION;
    NULL_LOCATION_ZIP EXCEPTION; 
    NULL_START_DATE EXCEPTION; 
    NULL_END_DATE EXCEPTION; 
    NULL_WAREHOUSE_TYPE EXCEPTION;
    INVALID_UNITS_LEASED EXCEPTION;
    INVALID_START_DATE EXCEPTION;
    INVALID_END_DATE EXCEPTION;
    v_start_date DATE;
    v_end_date DATE;
    LEASE_TOO_ADVANCED EXCEPTION;

BEGIN
    -- Check for null input parameters
    IF p_Customer_Email IS NULL THEN
        RAISE NULL_CUSTOMER_EMAIL;
    END IF;
    IF p_Units_Leased IS NULL THEN
        RAISE NULL_UNITS_LEASED;
    END IF;
    IF p_Warehouse_Type IS NULL THEN
        RAISE NULL_WAREHOUSE_TYPE;
    END IF;
    IF p_Location_Zip IS NULL THEN
        RAISE NULL_LOCATION_ZIP;
    END IF;
    IF p_Start_Date IS NULL THEN
        RAISE NULL_START_DATE;
    END IF;
    IF p_End_Date IS NULL THEN
        RAISE NULL_END_DATE;
    END IF;

    -- Validate start date format and convert to DATE type
    BEGIN
        v_start_date := TO_DATE(p_Start_Date, 'MM/DD/YYYY');
        DBMS_OUTPUT.PUT_LINE('Start Date: ' || v_start_date);
    EXCEPTION
        WHEN VALUE_ERROR THEN
            RAISE INVALID_START_DATE;
        WHEN OTHERS THEN
            RAISE INVALID_START_DATE;
    END;

    -- Validate end date format and convert to DATE type
    BEGIN
        v_end_date := TO_DATE(p_End_Date, 'MM/DD/YYYY');
        DBMS_OUTPUT.PUT_LINE('End Date: ' || v_end_date);
    EXCEPTION
        WHEN VALUE_ERROR THEN
            RAISE INVALID_END_DATE;
        WHEN OTHERS THEN
            RAISE INVALID_END_DATE;
    END;

    -- Check if the start date is more than one year in advance
    IF TO_DATE(p_Start_Date, 'MM/DD/YYYY') > SYSDATE + 365 THEN
        RAISE LEASE_TOO_ADVANCED;
    END IF;

    --CHECK IF LEASE UNITS ARE GREATER THAN 0
    IF MOD(p_units_leased, 1) != 0 OR p_units_leased < 1 THEN
        RAISE INVALID_UNITS_LEASED;
    END IF;

    

    -- Validate lease dates and period
    validate_lease_dates(p_start_date, p_end_date);

    -- Check if customer ID exists
    IF NOT customer_exists(p_Customer_Email) THEN
        RAISE CUSTOMER_NOT_FOUND;
    END IF;

    -- Find available warehouse
    v_warehouse_id := find_available_warehouse(v_start_date, v_end_date, p_Units_Leased, p_Warehouse_Type, p_Location_Zip);
    dbms_output.put_line('Warehouse ID: ' || v_warehouse_id);
    IF v_warehouse_id IS NULL THEN
        RAISE NO_WAREHOUSE_AVAILABLE;
    END IF;

    -- Calculate lease amount
    v_lease_amount := calculate_lease_amount(v_start_date, v_end_date, p_Units_Leased, p_Warehouse_Type);

    -- Retrieve Customer_ID for the provided email
    SELECT Customer_ID INTO v_customer_id FROM CUSTOMER WHERE Email = p_Customer_Email;

    -- Start transaction
    BEGIN
        -- Insert into LEASE table
        INSERT INTO LEASE (Lease_ID, Warehouse_ID, Customer_ID, Start_Date, End_Date, Lease_Amount,  Balance_Amount, Units_Leased)
        VALUES (Lease_ID_SEQ.NEXTVAL, v_warehouse_id, v_customer_id, v_Start_Date, v_End_Date, v_lease_amount, v_lease_amount, p_Units_Leased);

        -- Insert records into LEASE_UNIT and update warehouse and unit information
        update_units_availability_and_lease_units_insertion(v_warehouse_id, p_Units_Leased, Lease_ID_SEQ.CURRVAL, v_Start_Date, v_End_Date);
        
        -- Commit transaction
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Lease inserted successfully');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Lease already exists');
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Invalid input value for Lease');
        WHEN OTHERS THEN
            -- Rollback transaction
            DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
            ROLLBACK;
            IF SQLCODE = -6502 THEN
                DBMS_OUTPUT.PUT_LINE('Error: Invalid input value for Lease');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Error Creating Lease: ');
            END IF;
    END;
EXCEPTION
    WHEN CUSTOMER_NOT_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Customer with the Email does not exist');
    WHEN NO_WAREHOUSE_AVAILABLE THEN
        DBMS_OUTPUT.PUT_LINE('No available warehouse for the lease');
    WHEN NULL_CUSTOMER_EMAIL THEN 
        DBMS_OUTPUT.PUT_LINE('Customer email should not be null');
    WHEN NULL_UNITS_LEASED THEN
        DBMS_OUTPUT.PUT_LINE('Units leased should not be null');
    WHEN NULL_WAREHOUSE_TYPE THEN 
        DBMS_OUTPUT.PUT_LINE('Warehouse type should not be null');
    WHEN NULL_LOCATION_ZIP THEN 
        DBMS_OUTPUT.PUT_LINE('Location ZIP should not be null');
    WHEN NULL_START_DATE THEN 
        DBMS_OUTPUT.PUT_LINE('Start date should not be null');
    WHEN NULL_END_DATE THEN
        DBMS_OUTPUT.PUT_LINE('End date should not be null');
    WHEN INVALID_UNITS_LEASED THEN
        DBMS_OUTPUT.PUT_LINE('Invalid Lease Units');
    WHEN INVALID_START_DATE THEN
        DBMS_OUTPUT.PUT_LINE('Invalid LEASE Start Date. DATE should be in the format MM/DD/YYYY');
    WHEN INVALID_END_DATE THEN
        DBMS_OUTPUT.PUT_LINE('Invalid LEASE End Date. DATE should be in the format MM/DD/YYYY');
    WHEN LEASE_TOO_ADVANCED THEN
        DBMS_OUTPUT.PUT_LINE('Cannot lease more than an year in advance');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END InsertLease;
/



-- Function used for updating location table and returning location ID used in UPDATE_CUSTOMER_INFO Procedure

CREATE OR REPLACE FUNCTION GET_LOCATION_ID_UPDATE_CUSTOMER(
    p_zip IN LOCATION.ZIP%TYPE,
    p_city IN LOCATION.City%TYPE,
    p_state IN LOCATION.State%TYPE,
    p_country IN LOCATION.Country%TYPE
) RETURN LOCATION.Location_ID%TYPE
IS
    v_location_id LOCATION.Location_ID%TYPE;
    l_city LOCATION.City%TYPE;
    l_state LOCATION.State%TYPE;
    l_country LOCATION.Country%TYPE;
       
BEGIN
    -- Check if the ZIP exists in the LOCATION table
    SELECT Location_ID INTO v_location_id
    FROM LOCATION
    WHERE ZIP = p_zip;
    
    IF v_location_id IS NOT NULL THEN
        SELECT City , State ,Country l_country into l_city,l_state,l_country  from Location  
        where ZIP = p_zip;
        
        IF UPPER(NVL(p_city,l_city)) <> UPPER(l_city) OR UPPER(NVL(p_city,l_city)) <> UPPER(l_city) OR UPPER(NVL(p_country,l_country))<>UPPER(l_country) THEN
        RETURN NULL;
        END IF;
        
    END IF;

    -- If ZIP does not exist, insert a new record into the LOCATION table
    IF v_location_id IS NULL THEN
        INSERT INTO LOCATION (Location_ID, ZIP, City, State, Country)
        VALUES (Location_ID_SEQ.NEXTVAL, p_zip, p_city, p_state, p_country)
        RETURNING Location_ID INTO v_location_id;
    END IF;

    RETURN v_location_id;
EXCEPTION

    WHEN NO_DATA_FOUND THEN
        -- Handle the case when no record is found for the ZIP
        INSERT INTO LOCATION (Location_ID, ZIP, City, State, Country)
        VALUES (Location_ID_SEQ.NEXTVAL, p_zip, p_city, p_state, p_country)
        RETURNING Location_ID INTO v_location_id;

        RETURN v_location_id;

    WHEN OTHERS THEN
        -- Handle any other exceptions
        RAISE_APPLICATION_ERROR(-20001, 'Error occurred: ' || SQLERRM);
END;
/

-- procedure to insert a new customer record

CREATE OR REPLACE PROCEDURE INSERT_CUSTOMER_RECORD(
    p_first_name IN CUSTOMER.First_Name%TYPE,
    p_last_name IN CUSTOMER.Last_Name%TYPE,
    p_Street_Address IN CUSTOMER.Street_Address%TYPE,
    p_email IN CUSTOMER.Email%TYPE,
    p_phone IN CUSTOMER.Phone%TYPE,
    p_zip IN LOCATION.ZIP%TYPE,
    p_city IN LOCATION.City%TYPE,
    p_state IN LOCATION.State%TYPE,
    p_country IN LOCATION.Country%TYPE


) AS
    CUSTOMER_ALREADY_EXISTS EXCEPTION;
    CUSTOMER_FIRST_NAME_NULL EXCEPTION;
    CUSTOMER_LAST_NAME_NULL EXCEPTION;
    CUSTOMER_EMAIL_NULL EXCEPTION;
    CUSTOMER_PHONE_NULL EXCEPTION;
    CUSTOMER_EMAIL_UNIQUE EXCEPTION;
    CUSTOMER_PHONE_CHECK EXCEPTION;
    CUSTOMER_EMAIL_FORMAT_EXCEPTION EXCEPTION;
    INVALID_LOCATION_DETAILS EXCEPTION;
    e_count NUMBER;
    v_location_id LOCATION.Location_ID%TYPE;
    CUSTOMER_ZIP_NULL EXCEPTION;
    ZIP_FORMAT_EXCEPTION EXCEPTION;
    CUSTOMER_CITY_NULL EXCEPTION;
    CUSTOMER_STATE_NULL EXCEPTION;
    CUSTOMER_COUNTRY_NULL EXCEPTION;

BEGIN
    
    -- Check if customer first name is null
    IF p_first_name IS NULL THEN
        RAISE CUSTOMER_FIRST_NAME_NULL;
    END IF;

    -- Check if customer last name is null
    IF p_last_name IS NULL THEN
        RAISE CUSTOMER_LAST_NAME_NULL;
    END IF;
  
    -- Check if the email is null or it violates unique constraint
    IF p_email IS NOT NULL THEN
        SELECT COUNT(*)
        INTO e_count
        FROM CUSTOMER
        WHERE UPPER(Email) = UPPER(p_email)
        AND (UPPER(First_Name) <> UPPER(p_first_name) OR UPPER(Last_Name) <> UPPER(p_last_name));
    
        IF e_count > 0 THEN
            RAISE CUSTOMER_EMAIL_UNIQUE;
        END IF;
    ELSE
        RAISE CUSTOMER_EMAIL_NULL;
    END IF;
    
    -- Check email format
    IF NOT REGEXP_LIKE(p_email, '^(\S+)\@(\S+)\.(\S+)$') THEN
        RAISE CUSTOMER_EMAIL_FORMAT_EXCEPTION;
    END IF;
    

    -- Check if phone number is null or its length is valid
    IF p_phone IS NOT NULL THEN
        IF NOT regexp_like(p_phone, '^[[:digit:]]{10}$') THEN
            RAISE CUSTOMER_PHONE_CHECK;
        END IF;
    ELSE
        RAISE CUSTOMER_PHONE_NULL;
    END IF;

    -- check if ZIP is null
    IF p_zip IS NULL THEN
    RAISE CUSTOMER_ZIP_NULL;
    END IF;

    -- Check Zip format
    IF NOT regexp_like(p_zip, '^[[:digit:]]{5}$') THEN
    RAISE ZIP_FORMAT_EXCEPTION;
    END IF;

    -- check if city is null
    IF p_city IS NULL THEN
    RAISE CUSTOMER_CITY_NULL;
    END IF;

    -- check if state is null
    IF p_state IS NULL THEN
    RAISE CUSTOMER_STATE_NULL;
    END IF;

     -- check if country is null
    IF p_country IS NULL THEN
    RAISE CUSTOMER_COUNTRY_NULL;
    END IF;
  
    IF customer_exists(p_email) THEN
        RAISE CUSTOMER_ALREADY_EXISTS;
    ELSE
        v_location_id:= GET_LOCATION_ID(p_zip, p_city, p_state, p_country);
        IF v_location_id IS NULL THEN
        RAISE INVALID_LOCATION_DETAILS;
        END IF;
        INSERT INTO CUSTOMER (First_Name, Last_Name, Street_Address, Email, Phone, Location_ID)
        VALUES (p_first_name, p_last_name, p_Street_Address, p_email, p_phone, v_location_id );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('New customer record inserted successfully.');
    END IF;
    
EXCEPTION
    
    WHEN CUSTOMER_FIRST_NAME_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Customer first name cannot be null.');
        
    WHEN CUSTOMER_LAST_NAME_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Customer last name cannot be null.');
        
    WHEN CUSTOMER_EMAIL_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Email cannot be null.');
        
    WHEN CUSTOMER_PHONE_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Phone cannot be null.');

    WHEN CUSTOMER_ALREADY_EXISTS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Customer already exists.');
        
    WHEN CUSTOMER_EMAIL_UNIQUE THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer information: Email already exists for another customer');
    
    WHEN CUSTOMER_EMAIL_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Invalid email format.');
  
    WHEN CUSTOMER_PHONE_CHECK THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer information: Invalid phone number (must be 10 digits)');
    
    WHEN INVALID_LOCATION_DETAILS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer information: location details ');

    WHEN CUSTOMER_ZIP_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: ZIP cannot be null.');

    WHEN ZIP_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Invalid Zip format.');

    WHEN CUSTOMER_CITY_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: City cannot be null.');

    WHEN CUSTOMER_STATE_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: State cannot be null.');
    
    WHEN CUSTOMER_COUNTRY_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Country cannot be null.');

        
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: ' || SQLERRM);
END;
/
-- procedure to update customer personal information based on customer email

CREATE OR REPLACE PROCEDURE UPDATE_CUSTOMER_INFO(
    p_email IN CUSTOMER.Email%TYPE,
    p_first_name IN CUSTOMER.First_Name%TYPE,
    p_last_name IN CUSTOMER.Last_Name%TYPE,
    p_Street_Address IN CUSTOMER.Street_Address%TYPE,
    p_phone IN CUSTOMER.Phone%TYPE,
    p_zip IN LOCATION.ZIP%TYPE,
    p_city IN LOCATION.City%TYPE,
    p_state IN LOCATION.State%TYPE,
    p_country IN LOCATION.Country%TYPE
) AS
    CUSTOMER_DOESNOT_EXIST EXCEPTION;
    CUSTOMER_EMAIL_UNIQUE EXCEPTION;
    CUSTOMER_PHONE_CHECK EXCEPTION;
    CUSTOMER_EMAIL_NULL EXCEPTION;
    CUSTOMER_EMAIL_FORMAT_EXCEPTION EXCEPTION;
    e_count NUMBER;
    l_zip LOCATION.ZIP%TYPE;
    ZIP_FORMAT_EXCEPTION EXCEPTION;
    l_city LOCATION.City%TYPE;
    l_state LOCATION.State%TYPE;
    l_country LOCATION.Country%TYPE;
    l_location_id LOCATION.Location_ID%TYPE;
    INVALID_LOCATION_DETAILS EXCEPTION;
    v_location_id LOCATION.Location_ID%TYPE;
BEGIN

    -- Check is email is not null and  format
    IF p_email IS NOT NULL THEN

        IF NOT REGEXP_LIKE(p_email, '^(\S+)\@(\S+)\.(\S+)$') THEN
            RAISE CUSTOMER_EMAIL_FORMAT_EXCEPTION;
        END IF;
    ELSE
        RAISE CUSTOMER_EMAIL_NULL;
    END IF;

    -- Check Zip format
    IF NOT regexp_like(p_zip, '^[[:digit:]]{5}$') THEN
    RAISE ZIP_FORMAT_EXCEPTION;
    END IF;

    -- Check if the customer exists based on email
    IF NOT customer_exists(p_email) THEN
        RAISE CUSTOMER_DOESNOT_EXIST;
    END IF;

    -- Check if the email violates unique constraint
    -- SELECT COUNT(*)
    -- INTO e_count
    -- FROM CUSTOMER
    -- WHERE UPPER(Email) = UPPER(p_email)
    -- AND (UPPER(First_Name) <> UPPER(NVL(p_first_name,First_Name)) OR UPPER(Last_Name) <> UPPER(NVL(p_last_name,Last_Name)));

    -- IF e_count > 0 THEN
    --     RAISE CUSTOMER_EMAIL_UNIQUE;
    -- END IF;

    -- Check if phone number length is valid
    IF p_phone IS NOT NULL THEN
        IF NOT regexp_like(p_phone, '^[[:digit:]]{10}$') THEN
            RAISE CUSTOMER_PHONE_CHECK;
        END IF;
    END IF;

    --case 1: p_zip is null or p_zip is same exisitng zip for the given customer , get the location ID and check whether city, state and country matches with existing record.
    
    --case 2: p_zip is not same as existing zip for the given customer, but p_zip already exists in the Location table, then 
    -- get the location_id for the new ZIP and update it to customer if the city, state and country matches with the new ZIP existing record

    -- case 3: If p_zip is a new ZIP no present in location table, create a new record in location table with the given details,
    -- then add the corresponding location_ID to customer table .
 
   select Location_ID into l_location_id from customer where UPPER(email) = UPPER(p_email);
   SELECT ZIP into l_zip 
   from Location where Location_ID = l_location_id;

    IF p_zip IS NULL OR p_zip = l_zip  THEN
        SELECT city, state, country 
        into  l_city, l_state, l_country  
        from Location where ZIP = l_zip;

        IF UPPER(NVL(p_city,l_city)) <> UPPER(l_city) OR UPPER(NVL(p_city,l_city)) <> UPPER(l_city) OR UPPER(NVL(p_country,l_country))<>UPPER(l_country) THEN
        RAISE INVALID_LOCATION_DETAILS;
        END IF;
        v_location_id := l_location_id;
    ELSE

        v_location_id := GET_LOCATION_ID_UPDATE_CUSTOMER(p_zip, p_city, p_state, p_country);
        IF v_location_id IS NULL THEN
        RAISE INVALID_LOCATION_DETAILS;
        END IF;
        
    END IF;

    -- Update customer information
    UPDATE CUSTOMER
    SET Email = NVL(p_email, Email),
        Phone = NVL(p_phone, Phone),
        First_Name = NVL(p_first_name, First_Name),
        Last_Name = NVL(p_last_name, Last_Name),
        Street_Address = NVL(p_Street_Address, Street_Address),
        Location_ID = v_location_id 
    WHERE UPPER(Email) = UPPER(p_email);
    
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Customer information updated successfully.');

EXCEPTION

    
    WHEN CUSTOMER_EMAIL_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error updating customer record: Customer email can not be null');
        
    WHEN CUSTOMER_DOESNOT_EXIST THEN
        DBMS_OUTPUT.PUT_LINE('Error updating customer information: Please enter a valid customer email');
    
    WHEN CUSTOMER_EMAIL_UNIQUE THEN
        DBMS_OUTPUT.PUT_LINE('Error updating customer information: Email already exists for another customer');
  
    WHEN CUSTOMER_PHONE_CHECK THEN
        DBMS_OUTPUT.PUT_LINE('Error updating customer information: Invalid phone number length (must be 10 digits)');

    WHEN CUSTOMER_EMAIL_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error updating customer record: Invalid email format.');
    
    WHEN INVALID_LOCATION_DETAILS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating customer record: location details');

    WHEN ZIP_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer record: Invalid Zip format.');
    
    
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating customer information: ' || SQLERRM);
END;
/

-- procedure to delete a customer record

CREATE OR REPLACE PROCEDURE DELETE_CUSTOMER(
    p_email IN CUSTOMER.Email%TYPE
) AS
    CUSTOMER_NOT_FOUND EXCEPTION;
    CUSTOMER_EMAIL_FORMAT_EXCEPTION EXCEPTION;
    CUSTOMER_EMAIL_NULL EXCEPTION;
    ACTIVE_LEASES_EXIST EXCEPTION;
    v_active_leases NUMBER;
BEGIN

    -- Check if email is not null and format
    IF p_email IS NOT NULL THEN
        IF NOT REGEXP_LIKE(p_email, '^(\S+)\@(\S+)\.(\S+)$') THEN
            RAISE CUSTOMER_EMAIL_FORMAT_EXCEPTION;
        END IF;
    ELSE
        RAISE CUSTOMER_EMAIL_NULL;
    END IF;

    -- Check if the customer exists using the customer_exists function
    IF NOT customer_exists(p_email) THEN
        RAISE CUSTOMER_NOT_FOUND;
    END IF;

    -- Check if the customer has any active leases
    SELECT COUNT(*)
    INTO v_active_leases
    FROM LEASE
    WHERE Customer_ID = (SELECT Customer_ID FROM CUSTOMER WHERE UPPER(Email) = UPPER(p_email))
    AND End_Date >= SYSDATE;

    IF v_active_leases > 0 THEN
        RAISE ACTIVE_LEASES_EXIST;
    ELSE
        
        -- Set customer id to NULL for all leases belonging to the customer
        UPDATE LEASE
        SET Customer_ID = NULL
        WHERE Customer_ID = (SELECT Customer_ID FROM CUSTOMER WHERE UPPER(Email) = UPPER(p_email));

        -- updating the location id to NULL for the customer records
        update SERVICE_REQUEST
        set Customer_ID = NULL
        WHERE Customer_ID = (SELECT Customer_ID FROM CUSTOMER WHERE UPPER(Email) = UPPER(p_email));

        -- Delete the customer record
        DELETE FROM CUSTOMER
        WHERE UPPER(Email) = UPPER(p_email);
        
        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Customer record deleted successfully.');
    END IF;

EXCEPTION
    WHEN CUSTOMER_NOT_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error deleting customer record: Customer not found.');
    WHEN CUSTOMER_EMAIL_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error deleting customer record: Invalid email format.');
    WHEN CUSTOMER_EMAIL_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error deleting customer record: Customer email cannot be null');
    WHEN ACTIVE_LEASES_EXIST THEN
        DBMS_OUTPUT.PUT_LINE('Error deleting customer record: Active leases exist for this customer.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error deleting customer record: ' || SQLERRM);
END;
/



-- procedure to update owner personal information based on owner email

CREATE OR REPLACE PROCEDURE UPDATE_OWNER_INFO(
    p_Email WAREHOUSE_OWNER.Email%TYPE,
    p_Owner_Name WAREHOUSE_OWNER.Owner_Name%TYPE,
    p_Street_Address WAREHOUSE_OWNER.Street_Address%TYPE,
    p_Phone WAREHOUSE_OWNER.Phone%TYPE
) AS

    OWNER_DOESNOT_EXIST EXCEPTION;
    OWNER_EMAIL_FORMAT_EXCEPTION EXCEPTION;
    OWNER_EMAIL_NULL EXCEPTION;
    OWNER_PHONE_CHECK EXCEPTION;


BEGIN
     -- Check is email is not null and  format
    IF p_Email IS NOT NULL THEN

        IF NOT REGEXP_LIKE(p_Email, '^(\S+)\@(\S+)\.(\S+)$') THEN
            RAISE OWNER_EMAIL_FORMAT_EXCEPTION;
        END IF;
    ELSE
        RAISE OWNER_EMAIL_NULL;
    END IF;

     -- Check if phone number length is valid
    IF p_Phone IS NOT NULL THEN
        IF NOT regexp_like(p_Phone, '^[[:digit:]]{10}$') THEN
    RAISE OWNER_PHONE_CHECK;
    END IF;
    END IF;
    
    -- check if owner exists
    IF NOT OWNER_EXISTS(p_Email) THEN
        --RAISE_APPLICATION_ERROR(-20002, 'Owner with the specified email does not exist.');
        RAISE OWNER_DOESNOT_EXIST;
    END IF;

    UPDATE WAREHOUSE_OWNER
    SET Owner_Name = NVL(p_Owner_Name,Owner_Name),
        Street_Address = NVL(p_Street_Address,Street_Address),
        Phone = NVL(p_phone,Phone)
    WHERE UPPER(Email) = UPPER(p_Email);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Owner information updated successfully.');
EXCEPTION

    WHEN OWNER_DOESNOT_EXIST THEN
    DBMS_OUTPUT.PUT_LINE('Error updating Owner information: Please enter a valid Owner email');

    WHEN OWNER_EMAIL_FORMAT_EXCEPTION THEN
        DBMS_OUTPUT.PUT_LINE('Error updating Owner record: Invalid email format.');

    WHEN OWNER_EMAIL_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error updating owner record: Owner email can not be null');

    WHEN OWNER_PHONE_CHECK THEN
        DBMS_OUTPUT.PUT_LINE('Error updating Owner information: Invalid phone number length (must be 10 digits)');
    WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error updating owner information: ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE CancelLease (
    p_Lease_ID LEASE.Lease_ID%TYPE
)
IS
    v_Warehouse_ID LEASE.Warehouse_ID%TYPE;
    v_Lease_Amount LEASE.Lease_Amount%TYPE;
    v_Units_Leased LEASE.Units_Leased%TYPE;
    v_Customer_ID LEASE.Customer_ID%TYPE;
    v_Start_Date LEASE.Start_Date%TYPE;
    v_End_Date LEASE.End_Date%TYPE;
    Lease_Not_Found EXCEPTION;
    Cancellation_Failed EXCEPTION;
    LEASE_ID_NULL EXCEPTION;
    v_lease_count NUMBER;
BEGIN
    -- check if lease id is null

    IF p_Lease_ID IS NULL THEN
        RAISE LEASE_ID_NULL;
    END IF;

    -- Check if lease is cancellable
    IF v_Start_Date < SYSDATE THEN
        RAISE Cancellation_Failed;
    END IF;

    -- check if lease exists
    SELECT COUNT(*)
    INTO v_lease_count
    FROM LEASE
    WHERE Lease_ID = p_Lease_ID;

    IF v_lease_count = 0 THEN
        RAISE Lease_Not_Found;
    END IF;



    -- Retrieve lease information
    SELECT u.Warehouse_ID, l.Lease_Amount, l.Units_Leased, l.Start_Date, l.End_Date, l.Customer_ID
    INTO v_Warehouse_ID, v_Lease_Amount, v_Units_Leased, v_Start_Date, v_End_Date, v_Customer_ID
    FROM LEASE l
    JOIN LEASE_UNIT lu ON l.Lease_ID = lu.Lease_ID
    JOIN UNIT u ON lu.Unit_ID = u.Unit_ID
    WHERE l.Lease_ID = p_Lease_ID
    AND ROWNUM = 1;

    

    -- Start transaction
    BEGIN

        -- Delete lease units associated with the lease
        DELETE FROM LEASE_UNIT WHERE Lease_ID = p_Lease_ID;

        dbms_output.put_line('Lease Units deleted successfully');

        -- Delete the lease from the LEASE table
        DELETE FROM LEASE WHERE Lease_ID = p_Lease_ID;

        dbms_output.put_line('Lease deleted successfully');

       
        -- Insert the canceled lease into the CANCELED_LEASE table
        INSERT INTO CANCELLED_LEASE (CL_ID, customer_id, Lease_ID, Warehouse_ID, Lease_Amount, Units_Leased, Start_Date, End_Date, Cancelled_Date)
        VALUES (Cancelled_Lease_ID_SEQ.NEXTVAL,v_Customer_ID, p_Lease_ID, v_Warehouse_ID, v_Lease_Amount, v_Units_Leased, v_Start_Date, v_End_Date, SYSDATE);

        dbms_output.put_line('Lease inserted into CANCELLED_LEASE table successfully');
        
        -- Commit the transaction
        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Lease canceled successfully');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE Lease_Not_Found;
        WHEN OTHERS THEN
            -- Rollback the transaction
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END;
EXCEPTION
    WHEN Lease_Not_Found THEN
        DBMS_OUTPUT.PUT_LINE('Error: Lease ID ' || p_Lease_ID || ' not found');
    WHEN LEASE_ID_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Lease ID cannot be null');
     WHEN Cancellation_Failed THEN
            DBMS_OUTPUT.PUT_LINE('Error: Cannot Cancel an active lease');
END CancelLease;
/

CREATE OR REPLACE PROCEDURE ExtendLease (
  p_Lease_ID LEASE.Lease_ID%TYPE,
  p_New_End_Date VARCHAR2
)
IS
  v_Units_Leased LEASE.Units_Leased%TYPE;
  v_Lease_Amount LEASE.Lease_Amount%TYPE;
  v_Start_Date LEASE.Start_Date%TYPE;
  v_End_Date LEASE.End_Date%TYPE;
  Lease_Not_Found EXCEPTION;
  No_Warehouse_Available EXCEPTION;
  Invalid_Extension_Date EXCEPTION;
  v_Warehouse_ID UNIT.Warehouse_ID%TYPE;
  v_Warehouse_Type WAREHOUSE_TYPE.Type_Name%TYPE;
  v_Total_Units INTEGER;
  v_Leased_Units INTEGER;
  v_Unit_ID LEASE_UNIT.Unit_ID%TYPE;
  LEASE_ID_NULL EXCEPTION;
  EXTENSION_DATE_NULL EXCEPTION;
  

  CURSOR LeasedUnitCursor IS
    SELECT lu.Unit_ID
    FROM LEASE_UNIT lu
    WHERE lu.Lease_ID = p_Lease_ID;
BEGIN

 -- Check if lease id is null
    IF p_Lease_ID IS NULL THEN
        RAISE LEASE_ID_NULL;
    END IF;

-- Check if the DATE IS NULL
    IF p_New_End_Date IS NULL THEN
        RAISE EXTENSION_DATE_NULL;
    END IF;
 -- Check if the extension date is valid
  IF TO_DATE(p_New_End_Date,'MM/DD/YYYY') <= v_End_Date THEN
    RAISE Invalid_Extension_Date;
  END IF;

  -- Check if the lease ID exists
  SELECT Units_Leased, Lease_Amount, Start_Date, End_Date
  INTO v_Units_Leased, v_Lease_Amount, v_Start_Date, v_End_Date
  FROM LEASE
  WHERE Lease_ID = p_Lease_ID;
  DBMS_OUTPUT.PUT_LINE('Units Leased: ' || v_Units_Leased);

 

  DBMS_OUTPUT.PUT_LINE('New End Date: ' || TO_DATE(p_New_End_Date,'MM/DD/YYYY'));

  -- Get the warehouse ID and warehouse type for the lease
  SELECT u.Warehouse_ID, wt.Type_Name INTO v_Warehouse_ID, v_Warehouse_Type
  FROM LEASE_UNIT lu
  JOIN UNIT u ON lu.Unit_ID = u.Unit_ID
  JOIN WAREHOUSE w ON u.Warehouse_ID = w.Warehouse_ID
  JOIN WAREHOUSE_TYPE wt ON w.Warehouse_Type_ID = wt.Warehouse_Type_ID
  WHERE lu.Lease_ID = p_Lease_ID
  AND ROWNUM = 1;

  DBMS_OUTPUT.PUT_LINE('Warehouse ID: ' || v_Warehouse_ID);

  -- Check if there are enough available units for extension
  SELECT COUNT(*) INTO v_Total_Units
  FROM UNIT
  WHERE Warehouse_ID = v_Warehouse_ID;

  DBMS_OUTPUT.PUT_LINE('Total Units: ' || v_Total_Units);

  -- Loop through each leased unit and check for availability during extension
  FOR leased_unit_rec IN LeasedUnitCursor LOOP
    v_Unit_ID := leased_unit_rec.Unit_ID;

    SELECT COUNT(*) INTO v_Leased_Units
    FROM LEASE_UNIT lu
    JOIN LEASE l ON lu.Lease_ID = l.Lease_ID
    WHERE lu.Unit_ID = v_Unit_ID
      AND l.End_Date >= TO_DATE(p_New_End_Date,'MM/DD/YYYY')
      AND l.Start_Date <= TO_DATE(v_End_Date,'MM/DD/YYYY');

    DBMS_OUTPUT.PUT_LINE('Leased Units: ' || v_Leased_Units);

    -- Raise exception if unit is already leased during extension period
    IF v_Leased_Units > 0 THEN
      RAISE No_Warehouse_Available;
    END IF;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Lease extension validated');

  -- Calculate new lease amount
  v_Lease_Amount := calculate_lease_amount(v_Start_Date, TO_DATE(p_New_End_Date,'MM/DD/YYYY'), v_Units_Leased, v_Warehouse_Type);

    DBMS_OUTPUT.PUT_LINE('New Lease Amount: ' || v_Lease_Amount);

  -- Update lease details
  UPDATE LEASE
  SET End_Date = TO_DATE(p_New_End_Date,'MM/DD/YYYY'),
      Lease_Amount = v_Lease_Amount,
      Balance_Amount = Balance_Amount + (v_Lease_Amount - Lease_Amount)
  WHERE Lease_ID = p_Lease_ID;

  -- Commit the transaction
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Lease extended successfully');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE Lease_Not_Found;
   WHEN LEASE_ID_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Lease ID cannot be null');
   WHEN EXTENSION_DATE_NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Extension date cannot be null');
  WHEN No_Warehouse_Available THEN
    DBMS_OUTPUT.PUT_LINE('No available space in the warehouse for extension');
  WHEN Invalid_Extension_Date THEN
    DBMS_OUTPUT.PUT_LINE('Invalid extension date. The new end date should be after the current end date');
  WHEN OTHERS THEN
    -- Rollback the transaction
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END ExtendLease;
/
