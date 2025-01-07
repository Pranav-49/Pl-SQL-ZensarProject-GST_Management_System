CREATE TABLE Products (
    Product_ID NUMBER PRIMARY KEY,
    Product_Name VARCHAR2(50),
    Price NUMBER(10, 2),
    GST_Rate NUMBER(5, 2) 
);

CREATE TABLE Invoices (
    Invoice_ID NUMBER PRIMARY KEY,
    Customer_Name VARCHAR2(50),
    Invoice_Date DATE DEFAULT SYSDATE,
    Total_Amount NUMBER(10, 2),
    GST_Amount NUMBER(10, 2),
    Final_Amount NUMBER(10, 2)
);

CREATE TABLE Invoice_Details (
    Invoice_Detail_ID NUMBER PRIMARY KEY,
    Invoice_ID NUMBER,
    Product_ID NUMBER,
    Quantity NUMBER,
    FOREIGN KEY (Invoice_ID) REFERENCES Invoices(Invoice_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

INSERT INTO Products VALUES (1, 'Laptop', 50000, 18);
INSERT INTO Products VALUES (2, 'Mobile Phone', 20000, 12);
INSERT INTO Products VALUES (3, 'Headphones', 2000, 5);
INSERT INTO Products VALUES (4, 'Keyboard', 1000, 18);
INSERT INTO Products VALUES (5, 'Mouse', 500, 18);
INSERT INTO Products VALUES (6, 'Smart Watch', 8000, 12);
INSERT INTO Products VALUES (7, 'Tablet', 25000, 18);
INSERT INTO Products VALUES (8, 'Camera', 40000, 18);
INSERT INTO Products VALUES (9, 'TV', 30000, 28);
INSERT INTO Products VALUES (10, 'Refrigerator', 45000, 28);
COMMIT;


CREATE OR REPLACE PACKAGE GST_Package IS
    PROCEDURE Generate_Invoice(
        p_Customer_Name IN VARCHAR2,
        p_Product_ID IN NUMBER,
        p_Quantity IN NUMBER,
        p_Invoice_ID OUT NUMBER
    );

    FUNCTION Calculate_GST(p_Product_ID IN NUMBER, p_Quantity IN NUMBER) RETURN NUMBER;

    PROCEDURE View_Invoice(p_Invoice_ID IN NUMBER);
END GST_Package;
/

CREATE OR REPLACE PACKAGE BODY GST_Package IS

    FUNCTION Calculate_GST(p_Product_ID IN NUMBER, p_Quantity IN NUMBER) RETURN NUMBER IS
        v_Price NUMBER;
        v_GST_Rate NUMBER;
        v_GST_Amount NUMBER;
    BEGIN
        SELECT Price, GST_Rate INTO v_Price, v_GST_Rate FROM Products WHERE Product_ID = p_Product_ID;

        v_GST_Amount := (v_Price * p_Quantity) * v_GST_Rate / 100;
        RETURN v_GST_Amount;
    END Calculate_GST;

    PROCEDURE Generate_Invoice(
        p_Customer_Name IN VARCHAR2,
        p_Product_ID IN NUMBER,
        p_Quantity IN NUMBER,
        p_Invoice_ID OUT NUMBER
    ) IS
        v_Total_Amount NUMBER;
        v_GST_Amount NUMBER;
        v_Final_Amount NUMBER;
        v_Invoice_ID NUMBER;
    BEGIN
        SELECT NVL(MAX(Invoice_ID), 0) + 1 INTO v_Invoice_ID FROM Invoices;
        p_Invoice_ID := v_Invoice_ID;

        SELECT Price INTO v_Total_Amount FROM Products WHERE Product_ID = p_Product_ID;
        v_Total_Amount := v_Total_Amount * p_Quantity;
        v_GST_Amount := Calculate_GST(p_Product_ID, p_Quantity);
        v_Final_Amount := v_Total_Amount + v_GST_Amount;

        INSERT INTO Invoices (Invoice_ID, Customer_Name, Total_Amount, GST_Amount, Final_Amount)
        VALUES (v_Invoice_ID, p_Customer_Name, v_Total_Amount, v_GST_Amount, v_Final_Amount);

        INSERT INTO Invoice_Details (Invoice_Detail_ID, Invoice_ID, Product_ID, Quantity)
        VALUES ((SELECT NVL(MAX(Invoice_Detail_ID), 0) + 1 FROM Invoice_Details), v_Invoice_ID, p_Product_ID, p_Quantity);

        COMMIT;
    END Generate_Invoice;

    PROCEDURE View_Invoice(p_Invoice_ID IN NUMBER) IS
        v_Customer_Name VARCHAR2(50);
        v_Invoice_Date DATE;
        v_Total_Amount NUMBER;
        v_GST_Amount NUMBER;
        v_Final_Amount NUMBER;
    BEGIN
        SELECT Customer_Name, Invoice_Date, Total_Amount, GST_Amount, Final_Amount
        INTO v_Customer_Name, v_Invoice_Date, v_Total_Amount, v_GST_Amount, v_Final_Amount
        FROM Invoices
        WHERE Invoice_ID = p_Invoice_ID;

        DBMS_OUTPUT.PUT_LINE('Invoice ID: ' || p_Invoice_ID);
        DBMS_OUTPUT.PUT_LINE('Customer Name: ' || v_Customer_Name);
        DBMS_OUTPUT.PUT_LINE('Invoice Date: ' || TO_CHAR(v_Invoice_Date, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('Total Amount: ' || v_Total_Amount);
        DBMS_OUTPUT.PUT_LINE('GST Amount: ' || v_GST_Amount);
        DBMS_OUTPUT.PUT_LINE('Final Amount: ' || v_Final_Amount);
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('');

		

        DBMS_OUTPUT.PUT_LINE('Product Details:');
        FOR rec IN (
            SELECT p.Product_Name, d.Quantity, p.Price, p.GST_Rate
            FROM Invoice_Details d, Products p
            WHERE d.Product_ID = p.Product_ID AND d.Invoice_ID = p_Invoice_ID
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Product: ' || rec.Product_Name || ', Quantity: ' || rec.Quantity ||
                                 ', Price: ' || rec.Price || ', GST Rate: ' || rec.GST_Rate || '%');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('');
    END View_Invoice;

END GST_Package;
/

SET SERVEROUTPUT ON;

DECLARE
    v_Invoice_ID NUMBER;
BEGIN
    GST_Package.Generate_Invoice('John Doe', 1, 2, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);

    GST_Package.Generate_Invoice('Jane Smith', 2, 3, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);

    GST_Package.Generate_Invoice('Alice Johnson', 3, 5, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);

    GST_Package.Generate_Invoice('Bob Brown', 4, 10, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);

    GST_Package.Generate_Invoice('Charlie White', 5, 7, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);

    GST_Package.Generate_Invoice('David Black', 6, 1, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);

    GST_Package.Generate_Invoice('Emma Green', 7, 4, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);

    GST_Package.Generate_Invoice('Frank Blue', 8, 2, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);

    GST_Package.Generate_Invoice('Grace Pink', 9, 1, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);

    GST_Package.Generate_Invoice('Henry Gray', 10, 3, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);
END;
/


INSERT INTO Products VALUES (11, 'Air Conditioner', 50000, 18);
COMMIT;

DECLARE
    v_Invoice_ID NUMBER;
BEGIN
    GST_Package.Generate_Invoice('Liam Brown', 11, 2, v_Invoice_ID);
    GST_Package.View_Invoice(v_Invoice_ID);
END;
/
