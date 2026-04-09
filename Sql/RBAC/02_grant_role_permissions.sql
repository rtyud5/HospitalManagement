-- =====================================================
-- 02_grant_role_permissions.sql
-- Cấp quyền object-level cho từng Role (RBAC)
-- Chạy bằng tài khoản ADMIN (DBA)
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- ROLE: RL_KYTHUATVIEN
-- TC#4: KTV thực hiện dịch vụ, ghi kết quả HSBA_DV
--       Chỉ xem dòng mình được phân công (VPD sẽ xử lý)
--       Chỉ cập nhật trường KET_QUA
-- TC#5: Xem + sửa thông tin cá nhân trên NHAN_VIEN
-- =====================================================

-- Quyền SELECT trên HSBA_DV (VPD sẽ lọc row)
GRANT SELECT ON ADMIN.HSBA_DV TO RL_KYTHUATVIEN;

-- Quyền UPDATE chỉ trên cột KET_QUA của HSBA_DV
GRANT UPDATE (KET_QUA) ON ADMIN.HSBA_DV TO RL_KYTHUATVIEN;

-- Quyền SELECT trên NHAN_VIEN (VPD sẽ lọc row - chỉ thấy mình)
GRANT SELECT ON ADMIN.NHAN_VIEN TO RL_KYTHUATVIEN;

-- Quyền UPDATE chỉ trên các trường cho phép chỉnh sửa của NHAN_VIEN
-- Trừ: MA_NV, HO_TEN, PHAI, NGAY_SINH, CMND, VAI_TRO, CHUYEN_KHOA
GRANT UPDATE (QUE_QUAN, SDT) ON ADMIN.NHAN_VIEN TO RL_KYTHUATVIEN;

DBMS_OUTPUT.PUT_LINE('Đã cấp quyền cho RL_KYTHUATVIEN.');

-- =====================================================
-- ROLE: RL_BENHNHAN
-- TC#5: Xem + sửa thông tin cá nhân trên BENH_NHAN
--       Trừ: MA_BN, TEN_BN, PHAI, NGAY_SINH, CCCD
-- =====================================================

-- Quyền SELECT trên BENH_NHAN (VPD sẽ lọc row - chỉ thấy mình)
GRANT SELECT ON ADMIN.BENH_NHAN TO RL_BENHNHAN;

-- Quyền UPDATE chỉ trên các trường cho phép
GRANT UPDATE (SO_NHA, TEN_DUONG, QUAN_HUYEN, TINH_TP, TIEN_SU_BENH, TIEN_SU_BENH_GD, DI_UNG_THUOC) ON ADMIN.BENH_NHAN TO RL_BENHNHAN;

DBMS_OUTPUT.PUT_LINE('Đã cấp quyền cho RL_BENHNHAN.');
DBMS_OUTPUT.PUT_LINE('=== Hoàn thành cấp quyền cho Roles ===');
