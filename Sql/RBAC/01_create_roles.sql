-- =====================================================
-- 01_create_roles.sql
-- Tạo các Role cho hệ thống RBAC
-- Chạy bằng tài khoản ADMIN (DBA)
-- =====================================================

SET SERVEROUTPUT ON;

-- 1. Tạo role cho Kỹ thuật viên
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM dba_roles WHERE role = 'RL_KYTHUATVIEN';
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE ROLE RL_KYTHUATVIEN';
        DBMS_OUTPUT.PUT_LINE('Đã tạo role RL_KYTHUATVIEN.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Role RL_KYTHUATVIEN đã tồn tại.');
    END IF;
END;
/

-- 2. Tạo role cho Bệnh nhân
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM dba_roles WHERE role = 'RL_BENHNHAN';
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE ROLE RL_BENHNHAN';
        DBMS_OUTPUT.PUT_LINE('Đã tạo role RL_BENHNHAN.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Role RL_BENHNHAN đã tồn tại.');
    END IF;
END;
/

DBMS_OUTPUT.PUT_LINE('=== Hoàn thành tạo Roles ===');
