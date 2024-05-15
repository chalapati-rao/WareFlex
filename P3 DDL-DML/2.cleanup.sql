PURGE RECYCLEBIN;
-- script to cleanup sequences, tables and views if they already exist
SET SERVEROUTPUT ON;
-- cleanup sequences
DECLARE
    is_true NUMBER;
BEGIN

    dbms_output.put_line('*********CHECKING IF sequences ALREADY EXISTS************');
    
    --Customer_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'CUSTOMER_ID_SEQ';
    
    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: CUSTOMER_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE CUSTOMER_ID_SEQ';
    END IF;

    --Location_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'LOCATION_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: LOCATION_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE LOCATION_ID_SEQ';
    END IF;

    --Warehouse_Type_ID_SEQ

    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'WAREHOUSE_TYPE_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: WAREHOUSE_TYPE_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE WAREHOUSE_TYPE_ID_SEQ';
    END IF;

    --Owner_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'OWNER_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: OWNER_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE OWNER_ID_SEQ';
    END IF;

    --Warehouse_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'WAREHOUSE_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: WAREHOUSE_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE WAREHOUSE_ID_SEQ';
    END IF;

    --Employee_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'EMPLOYEE_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: EMPLOYEE_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE EMPLOYEE_ID_SEQ';
    END IF;

    --Service_Request_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'SERVICE_REQUEST_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: SERVICE_REQUEST_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE SERVICE_REQUEST_ID_SEQ';
    END IF;

    --Payment_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'PAYMENT_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: PAYMENT_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE PAYMENT_ID_SEQ';
    END IF;

    --Lease_Unit_ID_SEQ

    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'LEASE_UNIT_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: LEASE_UNIT_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE LEASE_UNIT_ID_SEQ';
    END IF;

    --Lease_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'LEASE_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: LEASE_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE LEASE_ID_SEQ';
    END IF;

    --Unit_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'UNIT_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: UNIT_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE UNIT_ID_SEQ';
    END IF;

    --Canceled_Lease_ID_SEQ
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_sequences
    WHERE
        sequence_name = 'CANCELLED_LEASE_ID_SEQ';

    IF is_true > 0 THEN
        dbms_output.put_line('Sequence: CANCELLED_LEASE_ID_SEQ Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP SEQUENCE CANCELLED_LEASE_ID_SEQ';
    END IF;

END;
/



--cleanup tables
DECLARE
    is_true NUMBER;
BEGIN

    dbms_output.put_line('*********CHECKING IF TABLES ALREADY EXISTS************');
    
     --Service Request
     SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'SERVICE_REQUEST';

    IF is_true > 0 THEN
        dbms_output.put_line('Table: SERVICE_REQUEST Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE SERVICE_REQUEST CASCADE CONSTRAINTS';
    END IF;
    
     --Payment
     SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'PAYMENT';

    IF is_true > 0 THEN
        dbms_output.put_line('Table: PAYMENT Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE PAYMENT CASCADE CONSTRAINTS';
    END IF;
    
    --Lease Unit
     SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'LEASE_UNIT';

    IF is_true > 0 THEN
        dbms_output.put_line('Table: LEASE_UNIT Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE LEASE_UNIT CASCADE CONSTRAINTS';
    END IF;
    
    --UNIT
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'UNIT';

    IF is_true > 0 THEN
        dbms_output.put_line('Table: UNIT Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE UNIT CASCADE CONSTRAINTS';
    END IF;

    --LEASE
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'LEASE';

    IF is_true > 0 THEN
        dbms_output.put_line('Table: LEASE Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE LEASE CASCADE CONSTRAINTS';
    END IF;

    --CUSTOMER
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'CUSTOMER';
    
    IF is_true > 0 THEN
        dbms_output.put_line('Table: CUSTOMER Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE CUSTOMER CASCADE CONSTRAINTS';
    END IF;

    --WAREHOUSE_EMPLOYEE
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'WAREHOUSE_EMPLOYEE';
    
    IF is_true > 0 THEN
        dbms_output.put_line('Table: WAREHOUSE_EMPLOYEE Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE WAREHOUSE_EMPLOYEE CASCADE CONSTRAINTS';
    END IF;

    --WAREHOUSE
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'WAREHOUSE';

    IF is_true > 0 THEN
        dbms_output.put_line('Table: WAREHOUSE Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE WAREHOUSE CASCADE CONSTRAINTS';
    END IF;

    --WAREHOUSE_OWNER
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'WAREHOUSE_OWNER';
    
    IF is_true > 0 THEN
        dbms_output.put_line('Table: WAREHOUSE_OWNER Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE WAREHOUSE_OWNER CASCADE CONSTRAINTS';
    END IF;

    --WAREHOUSE_TYPE
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'WAREHOUSE_TYPE';

    IF is_true > 0 THEN
        dbms_output.put_line('Table: WAREHOUSE_TYPE Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE WAREHOUSE_TYPE CASCADE CONSTRAINTS';
    END IF;

    --LOCATION
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'LOCATION';

    IF is_true > 0 THEN
        dbms_output.put_line('Table: LOCATION Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE LOCATION CASCADE CONSTRAINTS';
    END IF;


    -- CANCELED_LEASE
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_tables
    WHERE
        table_name = 'CANCELLED_LEASE';

    IF is_true > 0 THEN
        dbms_output.put_line('Table: CANCELLED_LEASE Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP TABLE CANCELLED_LEASE CASCADE CONSTRAINTS';
    END IF;

END;
/

--cleanup views
DECLARE 
    is_true NUMBER;
BEGIN

    dbms_output.put_line('*********CHECKING IF VIEWS ALREADY EXISTS************');
    
    --Payment Summary View
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_views
    WHERE
        view_name = 'PAYMENT_SUMMARY_VIEW';

    IF is_true > 0 THEN
        dbms_output.put_line('View: PAYMENT_SUMMARY_VIEW Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP VIEW PAYMENT_SUMMARY_VIEW';
    END IF;

    --Lease Units Available View
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_views
    WHERE
        view_name = 'Lease_Units_Availability_Status';

    IF is_true > 0 THEN
        dbms_output.put_line('View: Lease_Units_Availability_Status Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP VIEW Lease_Units_Availability_Status';
    END IF;

    --Owners Revenue By Location View
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_views
    WHERE
        view_name = 'OWNERS_REVENUE_BY_WAREHOUSE';

    IF is_true > 0 THEN
        dbms_output.put_line('View: OWNERS_REVENUE_BY_WAREHOUSE Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP VIEW OWNERS_REVENUE_BY_WAREHOUSE';
    END IF;


    --Service Request Status Warehouse View
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_views
    WHERE
        view_name = 'SERVICE_REQUEST_STATUS_WAREHOUSE_VIEW';

    IF is_true > 0 THEN
        dbms_output.put_line('View: SERVICE_REQUEST_STATUS_WAREHOUSE_VIEW Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP VIEW SERVICE_REQUEST_STATUS_WAREHOUSE_VIEW';
    END IF;

    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_views
    WHERE
        view_name = 'customer_lease_details_view';

    IF is_true > 0 THEN
        dbms_output.put_line('View: customer_lease_details_view Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP VIEW customer_lease_details_view';
    END IF;

    -- customer_lease_details_view
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_views
    WHERE
        view_name = 'customer_lease_details_view';
    
    IF is_true > 0 THEN
        dbms_output.put_line('View: customer_lease_details_view Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP VIEW customer_lease_details_view';
    END IF;

    -- warehouse_availability_status_view
    SELECT
        COUNT(*)
    INTO is_true
    FROM
        user_views
    WHERE
        view_name = 'warehouse_availability_status_view';
    
    IF is_true > 0 THEN
        dbms_output.put_line('View: warehouse_availability_status_view Already exists, dropping it');
        EXECUTE IMMEDIATE 'DROP VIEW warehouse_availability_status_view';
    END IF;

END;