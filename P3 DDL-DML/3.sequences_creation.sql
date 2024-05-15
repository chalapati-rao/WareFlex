PURGE RECYCLEBIN;

SET SERVEROUTPUT ON;
 --script to create sequences
CREATE OR REPLACE PROCEDURE create_sequence(seqName IN VARCHAR2, startWith IN NUMBER) AS
BEGIN
   -- Check if sequence exists
   FOR seq IN (SELECT sequence_name FROM all_sequences WHERE sequence_name = seqName) LOOP
      RETURN;
   END LOOP;
 
   -- Create sequence if it doesn't exist
   EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || seqName || ' INCREMENT BY 1 START WITH ' || startWith;
   dbms_output.put_line(seqName || 'created' );
EXCEPTION
   WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            dbms_output.put_line('Sequence ' ||seqName||'  already exists.');
        ELSE
            dbms_output.put_line(SQLERRM);
        END IF;
END create_sequence;
/
-- create required sequences
BEGIN
   create_sequence('Customer_ID_SEQ', 1);
   create_sequence('Location_ID_SEQ', 1);
   create_sequence('Warehouse_Type_ID_SEQ', 1);
   create_sequence('Owner_ID_SEQ', 1);
   create_sequence('Warehouse_ID_SEQ', 1);
   create_sequence('Employee_ID_SEQ', 1);
   create_sequence('Service_Request_ID_SEQ', 1);
   create_sequence('Payment_ID_SEQ', 1);
   create_sequence('Lease_Unit_ID_SEQ', 1);
   create_sequence('Lease_ID_SEQ', 1);
   create_sequence('Unit_ID_SEQ', 1);
   create_sequence('Cancelled_Lease_ID_SEQ', 1);
   COMMIT;
END;
/


