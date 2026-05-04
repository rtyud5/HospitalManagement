-- 00_bootstrap_demo.sql
-- Run as SYS AS SYSDBA or an equivalent account.
-- Must run inside the PDB, for example XEPDB1, not CDB$ROOT.
--
-- Subsystem 1 is the Oracle administration app. It should manage the
-- real hospital schema ADMIN instead of creating separate sample data.

SET DEFINE OFF;
SET SERVEROUTPUT ON;

BEGIN DBMS_OUTPUT.PUT_LINE('0. Kiem tra container hien tai'); END;
/

DECLARE
  v_con_name VARCHAR2(128);
BEGIN
  SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_con_name FROM dual;
  IF v_con_name = 'CDB$ROOT' THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Hay chay script trong PDB (vi du XEPDB1), khong chay trong CDB$ROOT.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('Dang chay trong container: ' || v_con_name);
END;
/

BEGIN DBMS_OUTPUT.PUT_LINE('1. Xoa ATBM_ADMIN cu neu ton tai'); END;
/

BEGIN
  FOR r IN (
    SELECT username
    FROM dba_users
    WHERE username = 'ATBM_ADMIN'
  ) LOOP
    EXECUTE IMMEDIATE 'DROP USER ' || r.username || ' CASCADE';
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN DBMS_OUTPUT.PUT_LINE('2. Tao user ATBM_ADMIN'); END;
/

CREATE USER ATBM_ADMIN IDENTIFIED BY "Admin#12345"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

GRANT CREATE SESSION TO ATBM_ADMIN;
GRANT DBA TO ATBM_ADMIN;
GRANT SELECT ANY DICTIONARY TO ATBM_ADMIN;
GRANT CREATE PROCEDURE TO ATBM_ADMIN;
GRANT EXECUTE ON DBMS_RLS TO ATBM_ADMIN;

BEGIN
    DBMS_OUTPUT.PUT_LINE('3. Tao package PKG_ADMIN trong schema ATBM_ADMIN');
    DBMS_OUTPUT.PUT_LINE('Buoc tiep theo: ket noi bang ATBM_ADMIN va chay 01_pkg_admin.sql');
    DBMS_OUTPUT.PUT_LINE('  sql ATBM_ADMIN/"Admin#12345"@localhost:1521/XEPDB1');
    DBMS_OUTPUT.PUT_LINE('  @03-Database/Admin/01_pkg_admin.sql');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Hoan tat bootstrap.');
    DBMS_OUTPUT.PUT_LINE('Tai khoan app: ATBM_ADMIN / Admin#12345');
    DBMS_OUTPUT.PUT_LINE('Schema nghiep vu: ADMIN');
END;
/
