-- ==========================================
-- 1. Kích hoạt kiểm toán (Chạy bằng sysdba trên root container nếu hệ thống chưa bật)
ALTER SYSTEM SET audit_trail = DB, EXTENDED SCOPE = SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP;

ALTER SESSION SET CONTAINER = XEPDB1;

GRANT AUDIT SYSTEM TO admin;
GRANT AUDIT ANY TO admin;
GRANT CREATE ANY AUDIT POLICY TO admin;
GRANT ALTER ANY AUDIT POLICY TO admin;
GRANT DROP ANY AUDIT POLICY TO admin;

-- Đảm bảo Admin có quyền xem log kiểm toán nếu cần thiết
GRANT SELECT ANY DICTIONARY TO admin;