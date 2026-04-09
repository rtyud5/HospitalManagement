# RBAC Scripts – Hướng dẫn chạy

## Đăng nhập bằng ADMIN (DBA)

Tài khoản: `ADMIN`  
Mật khẩu: `12345`

## Thứ tự chạy:

1. `01_create_roles.sql` – Tạo 2 role: RL_KYTHUATVIEN, RL_BENHNHAN
2. `02_grant_role_permissions.sql` – Cấp quyền object-level cho từng role
3. `03_assign_roles_to_users.sql` – Gán role cho users (mất thời gian vì 100K bệnh nhân)
4. `04_vpd_policies.sql` – Cài đặt VPD Row-Level Security
5. `05_audit_ketqua.sql` – Tạo bảng audit + trigger ghi vết KET_QUA

## Rollback (nếu cần):

Chạy `06_drop_rbac.sql` để xóa toàn bộ RBAC objects.

## Chi tiết chính sách:

### TC#4 – Kỹ thuật viên (RL_KYTHUATVIEN)
- SELECT trên HSBA_DV (VPD: chỉ thấy rows MA_KTV = mình)
- UPDATE(KET_QUA) trên HSBA_DV (VPD + audit trigger)
- SELECT trên NHAN_VIEN (VPD: chỉ thấy row mình)
- UPDATE(QUE_QUAN, SDT) trên NHAN_VIEN

### TC#5 – Bệnh nhân (RL_BENHNHAN)
- SELECT trên BENH_NHAN (VPD: chỉ thấy row mình)
- UPDATE(SO_NHA, TEN_DUONG, QUAN_HUYEN, TINH_TP, TIEN_SU_BENH, TIEN_SU_BENH_GD, DI_UNG_THUOC) trên BENH_NHAN
