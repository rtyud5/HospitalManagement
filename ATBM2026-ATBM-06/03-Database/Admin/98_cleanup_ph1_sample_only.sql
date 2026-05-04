-- 98_cleanup_ph1_sample_only.sql
-- Run as SYS AS SYSDBA inside the PDB.
-- Removes the old subsystem-1 sample users, roles, and stray sample objects.
-- Keeps ATBM_ADMIN and all subsystem-2 hospital users/roles/objects.

SET SERVEROUTPUT ON;

BEGIN
  FOR r IN (
    SELECT username
    FROM dba_users
    WHERE username IN ('LAB_OWNER','DEV_A','DEV_B','APP_USER1','APP_USER2')
  ) LOOP
    EXECUTE IMMEDIATE 'DROP USER ' || r.username || ' CASCADE';
    DBMS_OUTPUT.PUT_LINE('Dropped user ' || r.username);
  END LOOP;
END;
/

BEGIN
  FOR r IN (
    SELECT role
    FROM dba_roles
    WHERE role IN ('RL_READONLY','RL_ANALYST','RL_PROGRAM')
  ) LOOP
    EXECUTE IMMEDIATE 'DROP ROLE ' || r.role;
    DBMS_OUTPUT.PUT_LINE('Dropped role ' || r.role);
  END LOOP;
END;
/

BEGIN
  FOR r IN (
    SELECT owner, object_name, object_type
    FROM dba_objects
    WHERE owner IN ('SYS','SYSTEM')
      AND object_name IN ('DEPARTMENTS','EMPLOYEES','VW_EMP_SUMMARY','PR_RAISE_SALARY','FN_EMP_COUNT')
      AND object_type IN ('TABLE','VIEW','PROCEDURE','FUNCTION')
    ORDER BY CASE object_type
      WHEN 'VIEW' THEN 1
      WHEN 'PROCEDURE' THEN 2
      WHEN 'FUNCTION' THEN 3
      WHEN 'TABLE' THEN 4
      ELSE 5
    END
  ) LOOP
    IF r.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'DROP TABLE ' || r.owner || '.' || r.object_name || ' CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP ' || r.object_type || ' ' || r.owner || '.' || r.object_name;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Dropped stray ' || r.object_type || ' ' || r.owner || '.' || r.object_name);
  END LOOP;
END;
/

BEGIN DBMS_OUTPUT.PUT_LINE('PH1 sample cleanup completed.'); END;
/
