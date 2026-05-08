SET SERVEROUTPUT ON;

DECLARE
    v_audit_time  TIMESTAMP;
    v_target_time TIMESTAMP;
BEGIN
    BEGIN
        SELECT EVENT_TIMESTAMP 
        INTO v_audit_time
        FROM (
            SELECT EVENT_TIMESTAMP
            FROM UNIFIED_AUDIT_TRAIL
            WHERE OBJECT_SCHEMA = 'ADMIN' 
              AND OBJECT_NAME = 'DON_THUOC' 
              AND ACTION_NAME = 'UPDATE'
            ORDER BY EVENT_TIMESTAMP DESC
        )
        WHERE ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Không tìm thấy log Audit nào cho hành động UPDATE trên bảng DON_THUOC.');
            RETURN; 
    END;

    v_target_time := v_audit_time - INTERVAL '1' SECOND;
    
    DBMS_OUTPUT.PUT_LINE('--- BẮT ĐẦU KHÔI PHỤC ---');
    DBMS_OUTPUT.PUT_LINE('Thời điểm ghi nhận lỗi: ' || TO_CHAR(v_audit_time, 'DD-MM-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('Sẽ khôi phục bảng về:   ' || TO_CHAR(v_target_time, 'DD-MM-YYYY HH24:MI:SS'));

    EXECUTE IMMEDIATE 'ALTER TABLE admin.don_thuoc ENABLE ROW MOVEMENT';
    DBMS_OUTPUT.PUT_LINE('> Đã bật ROW MOVEMENT.');

    EXECUTE IMMEDIATE 'FLASHBACK TABLE admin.don_thuoc TO TIMESTAMP :1' USING v_target_time;
    DBMS_OUTPUT.PUT_LINE('> Khôi phục (FLASHBACK) thành công.');

    EXECUTE IMMEDIATE 'ALTER TABLE admin.don_thuoc DISABLE ROW MOVEMENT';
    DBMS_OUTPUT.PUT_LINE('> Đã tắt ROW MOVEMENT.');
    DBMS_OUTPUT.PUT_LINE('--- HOÀN TẤT ---');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Có lỗi bất ngờ xảy ra: ' || SQLERRM);
        EXECUTE IMMEDIATE 'ALTER TABLE admin.don_thuoc DISABLE ROW MOVEMENT';
END;
/

SELECT OBJECT_NAME, CREATED, LAST_DDL_TIME 
FROM USER_OBJECTS 
WHERE OBJECT_NAME = 'DON_THUOC';