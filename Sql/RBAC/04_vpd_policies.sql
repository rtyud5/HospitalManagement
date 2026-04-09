-- =====================================================
-- 04_vpd_policies.sql
-- Virtual Private Database - Row Level Security
-- Enforce RBAC ở tầng database (an toàn nhất)
-- Chạy bằng tài khoản ADMIN (DBA)
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 1. Policy Function cho HSBA_DV
-- KTV chỉ thấy dòng mà MA_KTV = SESSION_USER
-- ADMIN (DBA) thấy tất cả
-- =====================================================
CREATE OR REPLACE FUNCTION fn_policy_hsba_dv (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_user VARCHAR2(30) := SYS_CONTEXT('USERENV', 'SESSION_USER');
BEGIN
    -- DBA ADMIN thấy tất cả
    IF v_user = 'ADMIN' THEN
        RETURN '';
    END IF;

    -- Kỹ thuật viên chỉ thấy dòng được phân công
    RETURN 'MA_KTV = ''' || v_user || '''';
END;
/

-- =====================================================
-- 2. Policy Function cho NHAN_VIEN
-- Mỗi nhân viên chỉ thấy row của chính mình
-- ADMIN (DBA) thấy tất cả
-- =====================================================
CREATE OR REPLACE FUNCTION fn_policy_nhanvien (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_user VARCHAR2(30) := SYS_CONTEXT('USERENV', 'SESSION_USER');
BEGIN
    IF v_user = 'ADMIN' THEN
        RETURN '';
    END IF;

    RETURN 'MA_NV = ''' || v_user || '''';
END;
/

-- =====================================================
-- 3. Policy Function cho BENH_NHAN
-- Mỗi bệnh nhân chỉ thấy row của chính mình
-- ADMIN (DBA) thấy tất cả
-- =====================================================
CREATE OR REPLACE FUNCTION fn_policy_benhnhan (
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_user VARCHAR2(30) := SYS_CONTEXT('USERENV', 'SESSION_USER');
BEGIN
    IF v_user = 'ADMIN' THEN
        RETURN '';
    END IF;

    RETURN 'MA_BN = ''' || v_user || '''';
END;
/

-- =====================================================
-- 4. Đăng ký VPD Policies bằng DBMS_RLS
-- =====================================================

-- Policy cho HSBA_DV: áp dụng SELECT và UPDATE
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'ADMIN',
        object_name     => 'HSBA_DV',
        policy_name     => 'POL_HSBA_DV_KTV',
        function_schema => 'ADMIN',
        policy_function => 'FN_POLICY_HSBA_DV',
        statement_types => 'SELECT,UPDATE',
        update_check    => TRUE,
        enable          => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo VPD policy cho HSBA_DV.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Policy HSBA_DV đã tồn tại hoặc lỗi: ' || SQLERRM);
END;
/

-- Policy cho NHAN_VIEN: áp dụng SELECT và UPDATE
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'ADMIN',
        object_name     => 'NHAN_VIEN',
        policy_name     => 'POL_NHANVIEN_SELF',
        function_schema => 'ADMIN',
        policy_function => 'FN_POLICY_NHANVIEN',
        statement_types => 'SELECT,UPDATE',
        update_check    => TRUE,
        enable          => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo VPD policy cho NHAN_VIEN.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Policy NHAN_VIEN đã tồn tại hoặc lỗi: ' || SQLERRM);
END;
/

-- Policy cho BENH_NHAN: áp dụng SELECT và UPDATE
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'ADMIN',
        object_name     => 'BENH_NHAN',
        policy_name     => 'POL_BENHNHAN_SELF',
        function_schema => 'ADMIN',
        policy_function => 'FN_POLICY_BENHNHAN',
        statement_types => 'SELECT,UPDATE',
        update_check    => TRUE,
        enable          => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo VPD policy cho BENH_NHAN.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Policy BENH_NHAN đã tồn tại hoặc lỗi: ' || SQLERRM);
END;
/

DBMS_OUTPUT.PUT_LINE('=== Hoàn thành cài đặt VPD Policies ===');
