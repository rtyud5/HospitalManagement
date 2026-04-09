-- =====================================================
-- BƯỚC 2: Chạy file này bằng tài khoản ADMIN
-- TK: ADMIN / MK: 12345
-- Ví dụ SQLPlus: sqlplus admin/12345@localhost:1521/XEPDB1
--
-- File này sẽ chạy TẤT CẢ theo thứ tự:
--   1. Insert data (170 NV + 100K BN + 100K HSBA)
--   2. Tạo user Oracle cho NV + BN
--   3. RBAC: Tạo roles
--   4. RBAC: Cấp quyền cho roles
--   5. RBAC: Gán roles cho users
--   6. RBAC: VPD Row-Level Security
--   7. RBAC: Audit trigger cho KET_QUA
--
-- ⚠️ LƯU Ý: Quá trình này mất 10-30 phút vì tạo 100K users
-- =====================================================

SET SERVEROUTPUT ON;
SET TIMING ON;

PROMPT ===================================
PROMPT BƯỚC 1/7: Insert dữ liệu mẫu...
PROMPT ===================================
@@insertData.sql

PROMPT ===================================
PROMPT BƯỚC 2/7: Tạo tài khoản Oracle users...
PROMPT (Mất nhiều thời gian - ~100K users)
PROMPT ===================================
@@createUser.sql

PROMPT ===================================
PROMPT BƯỚC 3/7: Tạo Roles RBAC...
PROMPT ===================================
@@RBAC/01_create_roles.sql

PROMPT ===================================
PROMPT BƯỚC 4/7: Cấp quyền cho Roles...
PROMPT ===================================
@@RBAC/02_grant_role_permissions.sql

PROMPT ===================================
PROMPT BƯỚC 5/7: Gán Roles cho Users...
PROMPT (Mất nhiều thời gian - ~100K users)
PROMPT ===================================
@@RBAC/03_assign_roles_to_users.sql

PROMPT ===================================
PROMPT BƯỚC 6/7: Cài đặt VPD Policies...
PROMPT ===================================
@@RBAC/04_vpd_policies.sql

PROMPT ===================================
PROMPT BƯỚC 7/7: Cài đặt Audit Trigger...
PROMPT ===================================
@@RBAC/05_audit_ketqua.sql

PROMPT ===================================
PROMPT ✅ HOÀN THÀNH TẤT CẢ!
PROMPT Bạn có thể test với:
PROMPT   - KTV: NV0121 / 123
PROMPT   - BN:  BN000001 / 123
PROMPT ===================================

SET TIMING OFF;
