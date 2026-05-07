# GUIDELINE TRIỂN KHAI ĐỒ ÁN HOSPITAL MANAGEMENT ATBM 2026

## 1. Mục tiêu của guideline

Tài liệu này hướng dẫn chạy lại toàn bộ đồ án từ lúc clone repo về máy, chuẩn bị Oracle, chạy database scripts, build ứng dụng WinForms và demo hai phân hệ trong cùng một ứng dụng `HospitalManagement.App`.

Phạm vi đồ án gồm:

- Phân hệ 1: Ứng dụng quản trị CSDL Oracle dành cho DBA hoặc tài khoản quản trị. Phân hệ này dùng tài khoản `ATBM_ADMIN` để tạo, sửa, xóa user hoặc role, cấp quyền, thu hồi quyền và tra cứu quyền trên Oracle.
- Phân hệ 2: Ứng dụng quản lý dữ liệu y tế. Phân hệ này dùng các tài khoản bệnh viện như `NV0001`, `NV0050`, `NV0121`, `BN000001` để demo RBAC, VPD, OLS, Audit và Backup/Restore.

Ứng dụng sử dụng WinForms .NET 8, kết nối Oracle thông qua `Oracle.ManagedDataAccess.Core` và mặc định kết nối đến `localhost:1521/XEPDB1`.

## 2. Cấu trúc repo sau khi clone

Sau khi clone repo, cấu trúc chính cần quan tâm như sau:

```text
Hospital-Management-main/
└── ATBM2026-ATBM-06/
    ├── 01-ATBM-06-SourceCode/
    │   ├── HospitalManagement.sln
    │   └── HospitalManagement.App/
    │       ├── Forms/
    │       ├── Services/
    │       ├── DataAccess/
    │       └── HospitalManagement.App.csproj
    ├── 02-Exe/
    ├── 03-Database/
    │   ├── Schema/
    │   ├── Admin/
    │   ├── RBAC/
    │   ├── VPD/
    │   ├── Audit/
    │   └── OLS/
    ├── 04-Report/
    ├── 05-Demo/
    └── 06-Guideline/
```

Ý nghĩa các thư mục:

| Thư mục | Nội dung |
|---|---|
| `01-ATBM-06-SourceCode` | Mã nguồn WinForms .NET 8 |
| `02-Exe` | Nơi đặt file exe sau khi publish |
| `03-Database/Schema` | Tạo schema `ADMIN`, bảng dữ liệu, dữ liệu mẫu, user Oracle |
| `03-Database/Admin` | Script cho Phân hệ 1, tạo `ATBM_ADMIN` và package quản trị `PKG_ADMIN` |
| `03-Database/RBAC` | Script tạo role, grant quyền và gán role |
| `03-Database/VPD` | Script tạo chính sách Virtual Private Database |
| `03-Database/Audit` | Script ghi vết, Standard Audit, Unified Audit, xem log |
| `03-Database/OLS` | Script Oracle Label Security cho bảng thông báo khẩn |

## 3. Yêu cầu môi trường

Cài trước các phần mềm sau:

| Thành phần | Khuyến nghị |
|---|---|
| Hệ điều hành | Windows 10 hoặc Windows 11 |
| IDE | Visual Studio 2022, workload `.NET desktop development` |
| SDK | .NET SDK 8 |
| Database | Oracle Database XE, có PDB `XEPDB1` |
| Công cụ SQL | Oracle SQL Developer hoặc SQLPlus/SQLcl |
| NuGet | Máy có internet để restore package `Oracle.ManagedDataAccess.Core` |

Lưu ý quan trọng: ứng dụng là WinForms và target `net8.0-windows`, vì vậy nên build và chạy trên Windows. Nếu build trên Linux hoặc macOS, project có thể không chạy được giao diện WinForms.

## 4. Clone repo về máy

Mở PowerShell hoặc Command Prompt:

```powershell
git clone <repo-url>
cd <repo-name>\ATBM2026-ATBM-06
```

Nếu không dùng Git mà nhận file zip, giải nén zip rồi mở thư mục:

```powershell
cd "<repo-name>\ATBM2026-ATBM-06"
```

Kiểm tra nhanh các thư mục bắt buộc:

```powershell
dir
```

Phải thấy các thư mục `01-ATBM-06-SourceCode`, `02-Exe`, `03-Database`.

## 5. Chuẩn bị Oracle trước khi chạy script

### 5.1. Kiểm tra Oracle Listener

Mở Command Prompt với quyền bình thường hoặc Administrator:

```cmd
lsnrctl status
```

Nếu listener chưa chạy, mở Services của Windows và start các service Oracle, ví dụ:

```text
OracleOraDBXXHomeTNSListener
OracleServiceXE
```

### 5.2. Kiểm tra kết nối vào PDB

Mở SQL Developer và tạo connection:

| Thông tin | Giá trị |
|---|---|
| Username | `SYS` |
| Password | mật khẩu SYS khi cài Oracle |
| Role | `SYSDBA` |
| Hostname | `localhost` |
| Port | `1521` |
| Service name | `XEPDB1` |

Chạy kiểm tra:

```sql
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS CONTAINER_NAME FROM dual;
```

Kết quả đúng phải là:

```text
XEPDB1
```

Không chạy script trong `CDB$ROOT`. Nếu chạy nhầm root container, các user local như `ADMIN`, `NV0001`, `BN000001` có thể bị lỗi hoặc không đúng phạm vi đồ án.

## 6. Lưu ý bắt buộc trước khi chạy script

### 6.1. Dùng F5 trong SQL Developer

Khi chạy file `.sql`, nên mở đúng file rồi bấm `F5`, tức `Run Script`. Không dùng `F9` cho các file có nhiều lệnh, PL/SQL block hoặc lệnh `@@` gọi file khác.

### 6.2. Bật DBMS Output

Trong SQL Developer:

```text
View > Dbms Output > dấu + > chọn connection đang chạy
```

Việc này giúp nhìn thấy tiến độ insert dữ liệu, tạo user và assign role.

### 6.3. Kiểm tra cuối file `insertData.sql`

Mở file:

```text
03-Database/Schema/insertData.sql
```

Nếu cuối file đang kết thúc bằng:

```sql
END;
```

thì nên sửa thành:

```sql
END;
/
```

Lý do: đây là PL/SQL block lớn sinh dữ liệu mẫu. Khi chạy bằng SQL Developer hoặc SQLPlus, dấu `/` giúp thực thi block chắc chắn hơn.

Nếu file trong repo của bạn đã có sẵn dấu `/` ở cuối block thì bỏ qua bước chỉnh sửa này.

### 6.4. Lưu ý về số lượng user bệnh nhân

Bảng `BENH_NHAN` được sinh 100000 dòng dữ liệu. Tuy nhiên file `createUser.sql` trong mã nguồn hiện đang để chế độ demo nhanh, chỉ tạo user Oracle cho 200 bệnh nhân đầu tiên. Nhân viên vẫn được tạo đủ theo dữ liệu mẫu.

Nếu cần tạo đúng 100000 tài khoản bệnh nhân theo yêu cầu đầy đủ, mở `createUser.sql`, bật lại block tạo user cho toàn bộ bệnh nhân và comment block giới hạn `ROWNUM <= 200`. Việc này sẽ chạy lâu hơn rất nhiều.

## 7. Chạy script Phân hệ 2 trước: Schema, RBAC, VPD, Audit nền

Nên chạy Phân hệ 2 trước vì Phân hệ 1 quản trị trực tiếp schema nghiệp vụ `ADMIN`. Nếu chưa có schema `ADMIN`, Phân hệ 1 vẫn mở được nhưng thiếu đối tượng nghiệp vụ để demo grant trên bảng y tế.

### 7.1. Bước 1: chạy schema bằng SYSDBA

Trong SQL Developer, dùng connection `SYS AS SYSDBA` vào `XEPDB1`.

Mở file:

```text
03-Database/Schema/run_01_as_sysdba.sql
```

Bấm `F5`.

File này gọi:

```text
03-Database/Schema/initDB.sql
```

Kết quả mong đợi:

- Tạo user `ADMIN` với mật khẩu `12345`.
- Cấp quyền `connect`, `resource`, `dba`, `unlimited tablespace` cho `ADMIN`.
- Tạo các bảng nghiệp vụ trong schema `ADMIN`: `BENH_NHAN`, `NHAN_VIEN`, `HSBA`, `HSBA_DV`, `DON_THUOC`.

Kiểm tra nhanh bằng SYS:

```sql
SELECT username FROM dba_users WHERE username = 'ADMIN';
SELECT owner, table_name FROM dba_tables WHERE owner = 'ADMIN' ORDER BY table_name;
```

### 7.2. Bước 2: tạo connection ADMIN

Tạo connection mới trong SQL Developer:

| Thông tin | Giá trị |
|---|---|
| Username | `ADMIN` |
| Password | `12345` |
| Role | Default |
| Hostname | `localhost` |
| Port | `1521` |
| Service name | `XEPDB1` |

Test connection. Nếu thành công thì mở file ở bước tiếp theo.

### 7.3. Bước 3: chạy orchestration của Phân hệ 2

Dùng connection `ADMIN / 12345`, mở file:

```text
03-Database/Schema/run_02_as_admin.sql
```

Bấm `F5`.

File này chạy lần lượt 11 nhóm script:

| Thứ tự | Script | Mục đích |
|---|---|---|
| 1 | `Schema/insertData.sql` | Sinh dữ liệu mẫu cho nhân viên, bệnh nhân, HSBA, dịch vụ, đơn thuốc |
| 2 | `Schema/createUser.sql` | Tạo tài khoản Oracle cho nhân viên và bệnh nhân demo |
| 3 | `RBAC/01_create_roles.sql` | Tạo 4 role nghiệp vụ |
| 4 | `RBAC/02_grant_ktv_bn.sql` | Grant quyền và view cho kỹ thuật viên, bệnh nhân |
| 5 | `RBAC/03_grant_dpv_bs.sql` | Grant quyền cho điều phối viên, bác sĩ và tạo materialized view hỗ trợ dropdown |
| 6 | `RBAC/04_assign_ktv_bn.sql` | Gán role kỹ thuật viên và bệnh nhân |
| 7 | `RBAC/05_assign_dpv_bs.sql` | Gán role điều phối viên và bác sĩ |
| 8 | `VPD/01_fn_get_role.sql` | Tạo hàm xác định vai trò theo user đang đăng nhập |
| 9 | `VPD/02_vpd_basic.sql` | Tạo VPD cơ bản cho thông tin cá nhân |
| 10 | `VPD/03_vpd_dpv_bs.sql` | Tạo VPD cho điều phối viên và bác sĩ trên bảng nghiệp vụ |
| 11 | `Audit/01_audit_ketqua.sql` | Tạo bảng và trigger audit kết quả dịch vụ |

Thời gian chạy có thể lâu, nhất là phần tạo user và gán role. Với cấu hình demo hiện tại, thời gian thường ngắn hơn vì chỉ tạo 200 user bệnh nhân.

### 7.4. Kiểm tra sau khi chạy Phân hệ 2

Dùng connection `ADMIN`, chạy:

```sql
SELECT COUNT(*) AS SO_NV FROM ADMIN.NHAN_VIEN;
SELECT COUNT(*) AS SO_BN FROM ADMIN.BENH_NHAN;
SELECT COUNT(*) AS SO_HSBA FROM ADMIN.HSBA;
SELECT COUNT(*) AS SO_DV FROM ADMIN.HSBA_DV;
SELECT COUNT(*) AS SO_DON_THUOC FROM ADMIN.DON_THUOC;
```

Kiểm tra user demo:

```sql
SELECT username
FROM dba_users
WHERE username IN ('NV0001', 'NV0050', 'NV0121', 'BN000001')
ORDER BY username;
```

Kiểm tra role:

```sql
SELECT grantee, granted_role
FROM dba_role_privs
WHERE grantee IN ('NV0001', 'NV0050', 'NV0121', 'BN000001')
ORDER BY grantee, granted_role;
```

Kết quả mong đợi:

| User | Mật khẩu | Vai trò | Form mở trong app |
|---|---|---|---|
| `NV0001` | `123` | Điều phối viên | `DieuPhoiVienForm` |
| `NV0050` | `123` | Bác sĩ/Y sĩ | `BacSiForm` |
| `NV0121` | `123` | Kỹ thuật viên | `KyThuatVienForm` |
| `BN000001` | `123` | Bệnh nhân | `BenhNhanForm` |

## 8. Chạy script Phân hệ 1: Quản trị Oracle

Phân hệ 1 dùng tài khoản riêng `ATBM_ADMIN`. Tài khoản này mở màn hình `AdminMainForm` trong ứng dụng.

### 8.1. Bước 1: tạo ATBM_ADMIN bằng SYSDBA

Dùng connection `SYS AS SYSDBA` vào `XEPDB1`.

Mở file:

```text
03-Database/Admin/00_bootstrap_demo.sql
```

Bấm `F5`.

Kết quả mong đợi:

- Tạo user `ATBM_ADMIN`.
- Mật khẩu: `Admin#12345`.
- Cấp quyền cần thiết để quản trị user, role, privilege và đọc dictionary.
- Phân hệ 1 sẽ quản trị schema nghiệp vụ thật là `ADMIN`.

### 8.2. Bước 2: tạo package quản trị bằng ATBM_ADMIN

Tạo connection mới:

| Thông tin | Giá trị |
|---|---|
| Username | `ATBM_ADMIN` |
| Password | `Admin#12345` |
| Role | Default |
| Hostname | `localhost` |
| Port | `1521` |
| Service name | `XEPDB1` |

Mở file:

```text
03-Database/Admin/01_pkg_admin.sql
```

Bấm `F5`.

Kết quả mong đợi:

- Tạo bảng `APP_VPD_COL_GRANTS`.
- Tạo package `PKG_ADMIN`.
- Package này phục vụ các chức năng trong tab Users, Roles, Grant, Revoke, Tra cứu quyền của Phân hệ 1.

Lưu ý kỹ thuật: Oracle hỗ trợ `GRANT UPDATE(cột)` nhưng không hỗ trợ `GRANT SELECT(cột)` trực tiếp như một số bạn thường hiểu nhầm. Trong mã nguồn này, quyền SELECT mức cột được xử lý bằng cơ chế VPD che cột và bảng `APP_VPD_COL_GRANTS`.

### 8.3. Bước 3: kiểm tra Phân hệ 1

Dùng connection `ATBM_ADMIN`, chạy:

```sql
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'PKG_ADMIN';
```

Có thể chạy thêm:

```text
03-Database/Admin/10_verify_demo.sql
```

Nếu cần demo nhanh các tình huống grant, revoke bằng script thì chạy:

```text
03-Database/Admin/30_demo_scenarios.sql
```

## 9. Chạy thêm Audit đầy đủ cho Yêu cầu 3

File `run_02_as_admin.sql` đã chạy `Audit/01_audit_ketqua.sql`, tức mới có trigger audit riêng cho cập nhật `KET_QUA` trong `HSBA_DV`.

Để demo đầy đủ hơn phần kiểm toán, dùng connection `ADMIN` và chạy thêm:

```text
03-Database/Audit/02_audit.sql
03-Database/Audit/03_view_audit_logs.sql
```

Ý nghĩa:

| File | Mục đích |
|---|---|
| `01_audit_ketqua.sql` | Tạo bảng `AUDIT_KETQUA` và trigger ghi vết cập nhật kết quả dịch vụ |
| `02_audit.sql` | Cấu hình Standard Audit và policy audit bổ sung (bao gồm FGA/Unified policy tùy phiên bản Oracle) |
| `03_view_audit_logs.sql` | Truy vấn log từ `DBA_AUDIT_TRAIL` và `DBA_FGA_AUDIT_TRAIL` |
| `04_show_log.sql` | Dùng cho màn hình `AuditLogForm` trong app |
| `05_disable_audit.sql` | Tắt audit khi cần |
| `99_drop_audit.sql` | Xóa cấu hình audit demo |

Nếu Oracle báo chưa bật audit trail, cần chạy bằng SYSDBA và restart database:

```sql
ALTER SYSTEM SET audit_trail = db, extended SCOPE = SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP;
```

Sau đó chạy lại script audit.

## 10. Chạy thêm OLS cho Yêu cầu 2

OLS dùng để demo cơ chế phát tán thông báo khẩn theo nhãn bảo mật. Phần này nên chạy sau khi đã có các user `NV0001`, `NV0021`, `NV0022`, `NV0121`, `NV0122`, `NV0002`, `NV0003`, `NV0123`.

### 10.1. Chạy bằng SYS

Dùng connection `SYS AS SYSDBA` vào `XEPDB1`, chạy lần lượt:

```text
03-Database/OLS/00_reset_ols.sql
03-Database/OLS/01_sys_setup.sql
```

### 10.2. Chạy bằng ADMIN

Dùng connection `ADMIN / 12345`, chạy:

```text
03-Database/OLS/02_admin_table_policy.sql
```

Sau file này, ngắt kết nối ADMIN rồi kết nối lại ADMIN. Tiếp tục chạy:

```text
03-Database/OLS/03_admin_policy_components.sql
03-Database/OLS/04_admin_data_apply.sql
```

### 10.3. Test OLS bằng user thường

Mở connection hoặc đăng nhập trong app bằng các user sau, mật khẩu đều là `123`:

| User | Kết quả mong đợi khi xem `ADMIN.THONGBAO` |
|---|---|
| `NV0001` | Thấy `T1 T2 T3 T4 T5 T6 T7`, count = 7 |
| `NV0021` | Thấy `T1 T3`, count = 2 |
| `NV0022` | Thấy `T1 T3`, count = 2 |
| `NV0121` | Thấy `T1`, count = 1 |
| `NV0122` | Thấy `T1`, count = 1 |
| `NV0002` | Thấy `T1 T3`, count = 2 |
| `NV0003` | Thấy `T1 T3 T4 T5 T6 T7`, count = 6 |
| `NV0123` | Thấy `T1 T6`, count = 2 |

Câu lệnh test:

```sql
SELECT MA_TB, NOI_DUNG, NGAY_GIO, DIA_DIEM
FROM ADMIN.THONGBAO
ORDER BY MA_TB;

SELECT COUNT(*) AS SO_DONG_NHIN_THAY
FROM ADMIN.THONGBAO;
```

Trong app, người dùng bấm biểu tượng chuông thông báo để mở `ThongBaoKhanForm`.

## 11. Build ứng dụng bằng Visual Studio

### 11.1. Mở solution

Mở Visual Studio 2022, chọn:

```text
Open a project or solution
```

Mở file:

```text
ATBM2026-ATBM-06/01-ATBM-06-SourceCode/HospitalManagement.sln
```

### 11.2. Restore NuGet

Visual Studio thường tự restore package. Nếu chưa restore:

```text
Right click solution > Restore NuGet Packages
```

Package chính cần có:

```text
Oracle.ManagedDataAccess.Core 23.26.100
```

### 11.3. Build

Chọn cấu hình:

```text
Release | Any CPU
```

Sau đó chọn:

```text
Build > Build Solution
```

Nếu build thành công, Visual Studio sẽ tạo output trong thư mục:

```text
01-ATBM-06-SourceCode/HospitalManagement.App/bin/Release/net8.0-windows/
```

### 11.4. Chạy app

Bấm `Start` trong Visual Studio hoặc chạy file exe trong thư mục output:

```text
HospitalManagement.App.exe
```

Màn hình đầu tiên là `LoginForm`.

## 12. Build và chạy bằng command line

Mở PowerShell tại thư mục:

```powershell
cd Hospital-Management-main\ATBM2026-ATBM-06\01-ATBM-06-SourceCode
```

Restore:

```powershell
dotnet restore .\HospitalManagement.sln
```

Build Release:

```powershell
dotnet build .\HospitalManagement.sln -c Release
```

Chạy app:

```powershell
dotnet run --project .\HospitalManagement.App\HospitalManagement.App.csproj -c Release
```

Publish ra thư mục `02-Exe`:

```powershell
dotnet publish .\HospitalManagement.App\HospitalManagement.App.csproj -c Release -r win-x64 --self-contained false -o ..\02-Exe
```

Nếu muốn máy khác không cần cài .NET Runtime, dùng self-contained:

```powershell
dotnet publish .\HospitalManagement.App\HospitalManagement.App.csproj -c Release -r win-x64 --self-contained true -o ..\02-Exe
```

Sau khi publish, chạy:

```text
ATBM2026-ATBM-06/02-Exe/HospitalManagement.App.exe
```

## 13. Cách app điều hướng form sau khi đăng nhập

Mã nguồn `LoginForm.cs` xử lý như sau:

| Tài khoản đăng nhập | Điều kiện | Form mở |
|---|---|---|
| `ATBM_ADMIN` | Đăng nhập thành công bằng `ATBM_ADMIN / Admin#12345` | `AdminMainForm` |
| User có role `RL_DIEUPHOIVIEN` | Ví dụ `NV0001 / 123` | `DieuPhoiVienForm` |
| User có role `RL_BACSI` | Ví dụ `NV0050 / 123` | `BacSiForm` |
| User có role `RL_KYTHUATVIEN` | Ví dụ `NV0121 / 123` | `KyThuatVienForm` |
| User có role `RL_BENHNHAN` | Ví dụ `BN000001 / 123` | `BenhNhanForm` |

Ứng dụng kết nối bằng chính tài khoản người dùng đang đăng nhập. Điều này rất quan trọng vì `SESSION_USER` phải đúng thì VPD, self-view và OLS mới lọc dữ liệu đúng.

## 14. Kịch bản demo tổng quát

Nên demo theo thứ tự sau để người chấm dễ hiểu:

1. Giới thiệu kiến trúc một app gồm hai phân hệ.
2. Chứng minh database đã được cài trên Oracle.
3. Demo Phân hệ 1 bằng `ATBM_ADMIN`.
4. Demo Phân hệ 2 bằng từng vai trò nghiệp vụ.
5. Demo OLS bằng màn hình thông báo.
6. Demo Audit bằng cập nhật dữ liệu và xem log.
7. Demo Backup/Restore bằng Data Pump hoặc SQL Developer Export/Import.

## 15. Demo Phân hệ 1: Ứng dụng quản trị Oracle

### 15.1. Đăng nhập

Mở app, nhập:

```text
Username: ATBM_ADMIN
Password: Admin#12345
```

Kết quả: app mở `Phân hệ 1 - Ứng dụng quản trị CSDL Oracle`.

### 15.2. Tab Tổng quan

Demo nội dung:

- Hiển thị thông tin phiên kết nối.
- Hiển thị thông tin Oracle Database.
- Chứng minh app đang đọc được metadata cần thiết.

Có thể nói khi thuyết trình:

```text
Phân hệ 1 dùng tài khoản ATBM_ADMIN để thao tác với metadata và privilege của Oracle. Các thao tác trên giao diện được đóng gói qua package PKG_ADMIN để tránh viết SQL trực tiếp ở UI.
```

### 15.3. Tab Users

Demo các thao tác:

1. Bấm `Làm mới` để xem danh sách user.
2. Tìm `NV0001`, `NV0050`, `BN000001` để chứng minh user bệnh viện đã được tạo.
3. Tạo user demo, ví dụ:

```text
Username: DEMO_USER01
Password: Demo#123
```

4. Sửa password user demo.
5. Lock/Unlock user demo.
6. Drop user demo nếu không cần nữa.

### 15.4. Tab Roles

Demo các thao tác:

1. Bấm `Làm mới` để xem danh sách role.
2. Tìm các role nghiệp vụ:

```text
RL_DIEUPHOIVIEN
RL_BACSI
RL_KYTHUATVIEN
RL_BENHNHAN
```

3. Tạo role demo:

```text
DEMO_ROLE01
```

4. Sửa password role nếu cần.
5. Drop role demo sau khi test.

### 15.5. Tab Objects demo

Demo nội dung:

1. Owner filter nhập `ADMIN`.
2. Bấm `Làm mới object`.
3. Chỉ ra các bảng nghiệp vụ: `BENH_NHAN`, `NHAN_VIEN`, `HSBA`, `HSBA_DV`, `DON_THUOC`.

### 15.6. Tab Grant

Demo cấp quyền cho user hoặc role.

Ví dụ cấp quyền SELECT trên bảng `ADMIN.BENH_NHAN` cho `DEMO_USER01`:

| Trường | Giá trị demo |
|---|---|
| Principal | `DEMO_USER01` |
| Owner | `ADMIN` |
| Object | `BENH_NHAN` |
| Object type | `TABLE` |
| Privilege | `SELECT` |
| Columns | chọn một số cột nếu demo SELECT mức cột |
| WITH GRANT OPTION | tích nếu muốn user được cấp tiếp quyền |

Ví dụ cấp quyền UPDATE mức cột:

```text
Object: ADMIN.BENH_NHAN
Privilege: UPDATE
Columns: SO_NHA, TEN_DUONG, QUAN_HUYEN, TINH_TP
```

Sau khi cấp quyền, sang tab `Tra cứu quyền` để kiểm tra.

### 15.7. Tab Revoke

Demo thu hồi quyền vừa cấp:

| Trường | Giá trị demo |
|---|---|
| Principal | `DEMO_USER01` |
| Owner | `ADMIN` |
| Object | `BENH_NHAN` |
| Privilege | `SELECT` hoặc `UPDATE` |

Bấm `Thực hiện REVOKE`, sau đó sang tab `Tra cứu quyền` để xác nhận quyền đã mất.

### 15.8. Tab Tra cứu quyền

Demo tra cứu quyền theo user hoặc role:

```text
Principal type: USER
Principal: NV0050
```

hoặc:

```text
Principal type: ROLE
Principal: RL_BACSI
```

Các nhóm quyền hiển thị:

- System Privileges.
- Role Grants.
- Object Privileges.
- Column Privileges.

## 16. Demo Phân hệ 2: Quản lý dữ liệu y tế

### 16.1. Demo Điều phối viên

Đăng nhập:

```text
Username: NV0001
Password: 123
```

Form mở: `DieuPhoiVienForm`.

Demo các tab:

| Tab | Nội dung demo |
|---|---|
| Bệnh nhân | Xem danh sách bệnh nhân, tìm kiếm, thêm bệnh nhân, sửa thông tin được phép |
| Hồ sơ bệnh án | Tạo HSBA, cập nhật `MA_KHOA`, `MA_BS` để điều phối bác sĩ |
| Dịch vụ | Tạo dịch vụ hỗ trợ chẩn đoán, cập nhật `MA_KTV` để điều phối kỹ thuật viên |
| Thông tin cá nhân | Xem và sửa thông tin cá nhân được phép |
| Chuông thông báo | Mở thông báo khẩn theo OLS nếu đã chạy OLS |

Ý chính cần nói:

```text
Điều phối viên được cấp quyền bằng RBAC trên các bảng cần thao tác. Với các bảng nghiệp vụ, VPD đảm bảo các chính sách dòng dữ liệu được áp dụng tự động ở tầng database.
```

### 16.2. Demo Bác sĩ/Y sĩ

Đăng nhập:

```text
Username: NV0050
Password: 123
```

Form mở: `BacSiForm`.

Demo các tab:

| Tab | Nội dung demo |
|---|---|
| Hồ sơ bệnh án | Chỉ thấy HSBA do bác sĩ này phụ trách, sửa `CHUAN_DOAN`, `DIEU_TRI`, `KET_LUAN` |
| Dịch vụ | Thêm hoặc xóa dịch vụ liên quan HSBA của mình |
| Bệnh nhân | Chỉ thấy bệnh nhân liên quan HSBA mình điều trị, sửa tiền sử bệnh và dị ứng thuốc |
| Đơn thuốc | Thêm, sửa, xóa đơn thuốc liên quan HSBA của mình |
| Thông tin cá nhân | Sửa thông tin cá nhân được phép |

Tình huống kiểm chứng VPD:

1. Đăng nhập `NV0050`, xem số HSBA.
2. Đăng nhập một bác sĩ khác, ví dụ `NV0051`, xem số HSBA khác.
3. Kết luận: cùng một câu SELECT trên bảng `ADMIN.HSBA` nhưng kết quả khác nhau theo `SESSION_USER`.

### 16.3. Demo Kỹ thuật viên

Đăng nhập:

```text
Username: NV0121
Password: 123
```

Form mở: `KyThuatVienForm`.

Demo:

1. Tab `Dịch vụ phân công` chỉ hiển thị các dòng `HSBA_DV` có `MA_KTV` là chính kỹ thuật viên đang đăng nhập.
2. Sửa cột `KET_QUA`.
3. Bấm `Lưu kết quả`.
4. Kiểm tra log audit trong bảng `ADMIN.AUDIT_KETQUA`.

Câu SQL kiểm tra:

```sql
SELECT *
FROM ADMIN.AUDIT_KETQUA
ORDER BY THOI_GIAN_CAP_NHAT DESC
FETCH FIRST 20 ROWS ONLY;
```

Ý chính cần nói:

```text
Kỹ thuật viên không được grant trực tiếp trên base table. Hệ thống dùng RBAC kết hợp view self-scope để chỉ cho kỹ thuật viên thấy và cập nhật dịch vụ được phân công cho chính mình.
```

### 16.4. Demo Bệnh nhân

Đăng nhập:

```text
Username: BN000001
Password: 123
```

Form mở: `BenhNhanForm`.

Demo:

1. Bệnh nhân chỉ xem được thông tin của chính mình.
2. Bệnh nhân chỉ sửa được các trường được phép như địa chỉ, tiền sử bệnh, tiền sử bệnh gia đình, dị ứng thuốc.
3. Các trường định danh như mã bệnh nhân, họ tên, phái, ngày sinh, CCCD không cho sửa.

Ý chính cần nói:

```text
Bệnh nhân dùng RBAC kết hợp view lọc theo SESSION_USER. Điều này đáp ứng yêu cầu mỗi bệnh nhân đăng nhập chỉ nhìn thấy dòng dữ liệu của chính mình.
```

## 17. Demo OLS trên màn hình thông báo khẩn

Điều kiện: đã chạy các script trong thư mục `OLS`.

Cách demo:

1. Đăng nhập từng user OLS bằng app.
2. Bấm nút chuông thông báo.
3. So sánh số dòng thông báo mỗi user thấy.

Bảng demo nhanh:

| User | Vai trò mô phỏng | Số thông báo kỳ vọng |
|---|---|---|
| `NV0001` | Giám đốc | 7 |
| `NV0021` | Lãnh đạo khoa | 2 |
| `NV0121` | Nhân viên | 1 |
| `NV0003` | Lãnh đạo phòng phạm vi rộng hơn | 6 |
| `NV0123` | Nhân viên khoa tiêu hóa tại Hà Nội | 2 |

Ý chính cần nói:

```text
OLS được dùng cho bài toán phát tán thông báo khẩn. Dữ liệu thông báo được gán nhãn, user cũng được gán nhãn đọc. Oracle tự lọc dòng thông báo theo label, không cần viết điều kiện lọc thủ công trong app.
```

## 18. Demo Audit

### 18.1. Demo custom audit cho KET_QUA

Bước 1: đăng nhập `NV0121 / 123`.

Bước 2: sửa `KET_QUA` trong tab dịch vụ.

Bước 3: dùng SQL Developer connection `ADMIN`, chạy:

```sql
SELECT *
FROM ADMIN.AUDIT_KETQUA
ORDER BY THOI_GIAN_CAP_NHAT DESC
FETCH FIRST 20 ROWS ONLY;
```

Kết quả cần chỉ ra:

- User nào sửa.
- Thời gian sửa.
- Giá trị cũ.
- Giá trị mới.
- Dòng dữ liệu liên quan.

### 18.2. Demo Standard Audit và Unified Audit

Bước 1: chạy script:

```text
03-Database/Audit/02_audit.sql
```

Bước 2: tạo hành vi được audit, ví dụ:

- `SELECT` trên `ADMIN.HSBA`.
- `UPDATE` thất bại trên `ADMIN.DON_THUOC`.
- `DELETE` thành công trên `ADMIN.HSBA_DV` nếu có dòng demo phù hợp.
- `INSERT` thành công trên `ADMIN.BENH_NHAN`.

Bước 3: xem log bằng:

```text
03-Database/Audit/03_view_audit_logs.sql
03-Database/Audit/04_show_log.sql
```

Trong app, đăng nhập `ATBM_ADMIN`, bấm `Xem Audit Log` để mở `AuditLogForm` nếu đã có dữ liệu log phù hợp.

## 19. Demo Backup và Restore cho Yêu cầu 4

Trong mã nguồn hiện tại chưa có giao diện riêng cho Backup/Restore. Vì đề bài không yêu cầu giao diện cho yêu cầu này, có thể demo bằng Oracle Data Pump hoặc SQL Developer Export/Import.

### 19.1. Tạo thư mục backup trên Windows

Tạo thư mục:

```cmd
mkdir C:\oracle_backup
```

### 19.2. Tạo DIRECTORY object trong Oracle

Đăng nhập SYSDBA vào `XEPDB1`, chạy:

```sql
CREATE OR REPLACE DIRECTORY ATBM_BACKUP_DIR AS 'C:\oracle_backup';
GRANT READ, WRITE ON DIRECTORY ATBM_BACKUP_DIR TO ADMIN;
```

### 19.3. Backup schema ADMIN bằng Data Pump

Mở Command Prompt:

```cmd
expdp admin/12345@localhost:1521/XEPDB1 schemas=ADMIN directory=ATBM_BACKUP_DIR dumpfile=admin_backup.dmp logfile=admin_backup.log
```

Kết quả mong đợi:

```text
admin_backup.dmp
admin_backup.log
```

xuất hiện trong thư mục:

```text
C:\oracle_backup
```

### 19.4. Tạo sự cố demo

Ví dụ tạo một thay đổi sai trên dữ liệu bệnh nhân:

```sql
UPDATE ADMIN.BENH_NHAN
SET TINH_TP = N'DU_LIEU_SAI_DEMO'
WHERE MA_BN = 'BN000001';
COMMIT;
```

Kiểm tra:

```sql
SELECT MA_BN, TEN_BN, TINH_TP
FROM ADMIN.BENH_NHAN
WHERE MA_BN = 'BN000001';
```

### 19.5. Restore toàn schema

Chỉ dùng khi chấp nhận ghi đè schema demo:

```cmd
impdp admin/12345@localhost:1521/XEPDB1 schemas=ADMIN directory=ATBM_BACKUP_DIR dumpfile=admin_backup.dmp logfile=admin_restore.log table_exists_action=replace
```

### 19.6. Restore an toàn theo bảng tạm

Nếu không muốn ghi đè ngay, restore bảng ra tên khác:

```cmd
impdp admin/12345@localhost:1521/XEPDB1 tables=ADMIN.BENH_NHAN directory=ATBM_BACKUP_DIR dumpfile=admin_backup.dmp logfile=benh_nhan_restore.log remap_table=BENH_NHAN:BENH_NHAN_RESTORE
```

Sau đó so sánh:

```sql
SELECT a.MA_BN, a.TINH_TP AS DU_LIEU_HIEN_TAI, b.TINH_TP AS DU_LIEU_BACKUP
FROM ADMIN.BENH_NHAN a
JOIN ADMIN.BENH_NHAN_RESTORE b ON a.MA_BN = b.MA_BN
WHERE a.MA_BN = 'BN000001';
```

Khôi phục lại dòng sai:

```sql
UPDATE ADMIN.BENH_NHAN a
SET a.TINH_TP = (
    SELECT b.TINH_TP
    FROM ADMIN.BENH_NHAN_RESTORE b
    WHERE b.MA_BN = a.MA_BN
)
WHERE a.MA_BN = 'BN000001';
COMMIT;
```

Ý chính cần nói:

```text
Backup được thực hiện trước khi xảy ra sự cố. Sau khi audit log giúp xác định dữ liệu hoặc thao tác bất thường, nhóm có thể phục hồi toàn schema hoặc phục hồi từng bảng/từng dòng bằng dữ liệu backup.
```

## 20. Checklist trước khi quay video demo

Trước khi quay demo, kiểm tra đủ các mục sau:

| Mục kiểm tra | Câu lệnh hoặc thao tác |
|---|---|
| Oracle chạy | `lsnrctl status` |
| Đang ở PDB đúng | `SELECT SYS_CONTEXT('USERENV','CON_NAME') FROM dual;` |
| Schema ADMIN tồn tại | `SELECT username FROM dba_users WHERE username='ADMIN';` |
| Bảng nghiệp vụ có dữ liệu | `SELECT COUNT(*) FROM ADMIN.BENH_NHAN;` |
| User demo tồn tại | kiểm tra `NV0001`, `NV0050`, `NV0121`, `BN000001` |
| Role đã gán | query `DBA_ROLE_PRIVS` |
| VPD active | query `DBA_POLICIES` |
| OLS chạy nếu demo thông báo | query `ADMIN.THONGBAO` bằng từng user |
| Audit có log | query `ADMIN.AUDIT_KETQUA` hoặc chạy `04_show_log.sql` |
| App build được | `dotnet build .\HospitalManagement.sln -c Release` |
| App kết nối được Oracle | đăng nhập thử bằng `ATBM_ADMIN` và `NV0001` |

## 21. Lỗi thường gặp và cách xử lý

### 21.1. ORA-01017: invalid username/password

Nguyên nhân:

- Sai mật khẩu.
- User chưa được tạo.
- Đăng nhập sai service name.

Cách xử lý:

```sql
SELECT username, account_status FROM dba_users WHERE username = 'NV0001';
```

Nếu user bị lock:

```sql
ALTER USER NV0001 ACCOUNT UNLOCK;
ALTER USER NV0001 IDENTIFIED BY 123;
```

### 21.2. ORA-12541 hoặc ORA-12170

Nguyên nhân: Oracle listener chưa chạy hoặc host/port/service sai.

Cách xử lý:

```cmd
lsnrctl status
```

Kiểm tra app đang dùng:

```text
Host: localhost
Port: 1521
ServiceName: XEPDB1
```

Nếu Oracle không dùng `XEPDB1`, sửa trong:

```text
HospitalManagement.App/Models/DbConnectionSettings.cs
HospitalManagement.App/DataAccess/OracleHelper.cs
HospitalManagement.App/Forms/LoginForm.cs
```

### 21.3. ORA-65096: invalid common user or role name

Nguyên nhân: chạy tạo user trong `CDB$ROOT`.

Cách xử lý: kết nối vào PDB `XEPDB1`, không chạy ở root container.

Kiểm tra:

```sql
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') FROM dual;
```

### 21.4. ORA-00942: table or view does not exist

Nguyên nhân:

- Chưa chạy `Schema/run_01_as_sysdba.sql`.
- Chưa chạy `Schema/run_02_as_admin.sql`.
- Đăng nhập nhầm user.
- Thiếu prefix `ADMIN.` khi query bằng user khác.

Cách xử lý:

```sql
SELECT owner, table_name FROM dba_tables WHERE owner='ADMIN';
```

### 21.5. ORA-01031: insufficient privileges

Nguyên nhân:

- Chạy script bằng sai user.
- Script OLS hoặc Admin bootstrap chưa chạy bằng SYSDBA.

Cách xử lý:

- Script `Schema/run_01_as_sysdba.sql`, `Admin/00_bootstrap_demo.sql`, `OLS/00_reset_ols.sql`, `OLS/01_sys_setup.sql` phải chạy bằng SYSDBA.
- Script nghiệp vụ còn lại đa số chạy bằng `ADMIN` hoặc `ATBM_ADMIN` đúng theo hướng dẫn.

### 21.6. Script chạy nhưng không thấy dữ liệu insert

Nguyên nhân thường gặp: PL/SQL block thiếu dấu `/` cuối file.

Cách xử lý: kiểm tra `insertData.sql`, đảm bảo cuối file có:

```sql
END;
/
```

### 21.7. Chạy OLS bị ORA-12407 hoặc ORA-12446

Cách xử lý:

1. Chạy lại `OLS/00_reset_ols.sql` bằng SYS.
2. Chạy lại `OLS/01_sys_setup.sql` bằng SYS.
3. Chạy `OLS/02_admin_table_policy.sql` bằng ADMIN.
4. Disconnect ADMIN rồi connect lại.
5. Chạy tiếp `OLS/03_admin_policy_components.sql` và `OLS/04_admin_data_apply.sql`.

### 21.8. Build lỗi thiếu Oracle.ManagedDataAccess.Core

Cách xử lý:

```powershell
cd Hospital-Management-main\ATBM2026-ATBM-06\01-ATBM-06-SourceCode
dotnet restore .\HospitalManagement.sln
```

Hoặc trong Visual Studio:

```text
Right click Solution > Restore NuGet Packages
```

### 21.9. App mở được nhưng user không vào đúng form

Nguyên nhân: user chưa được gán role.

Cách kiểm tra:

```sql
SELECT grantee, granted_role
FROM dba_role_privs
WHERE grantee = 'NV0050';
```

Nếu thiếu role, chạy lại script assign role tương ứng:

```text
RBAC/04_assign_ktv_bn.sql
RBAC/05_assign_dpv_bs.sql
```

## 22. Thứ tự chạy nhanh để ghi vào README nộp bài

Nếu chỉ cần một checklist ngắn để nộp kèm repo, dùng thứ tự sau:

```text
1. Clone repo.
2. Cài Oracle XE và bảo đảm PDB XEPDB1 chạy ở localhost:1521.
3. SQL Developer, đăng nhập SYS AS SYSDBA vào XEPDB1.
4. F5: 03-Database/Schema/run_01_as_sysdba.sql.
5. Đăng nhập ADMIN / 12345.
6. F5: 03-Database/Schema/run_02_as_admin.sql.
7. Đăng nhập SYS AS SYSDBA.
8. F5: 03-Database/Admin/00_bootstrap_demo.sql.
9. Đăng nhập ATBM_ADMIN / Admin#12345.
10. F5: 03-Database/Admin/01_pkg_admin.sql.
11. Nếu demo Audit đầy đủ, đăng nhập ADMIN và F5 Audit/02_audit.sql, Audit/03_view_audit_logs.sql.
12. Nếu demo OLS, chạy OLS/00_reset_ols.sql và OLS/01_sys_setup.sql bằng SYS, sau đó chạy OLS/02_admin_table_policy.sql, OLS/03_admin_policy_components.sql, OLS/04_admin_data_apply.sql bằng ADMIN.
13. Mở 01-ATBM-06-SourceCode/HospitalManagement.sln bằng Visual Studio 2022.
14. Restore NuGet, build Release.
15. Chạy app và demo bằng ATBM_ADMIN, NV0001, NV0050, NV0121, BN000001.
```

## 23. Tài khoản demo chính

| Tài khoản | Mật khẩu | Dùng để demo |
|---|---|---|
| `ADMIN` | `12345` | Chạy script schema, RBAC, VPD, Audit, OLS phần ADMIN |
| `ATBM_ADMIN` | `Admin#12345` | Đăng nhập Phân hệ 1 quản trị Oracle |
| `NV0001` | `123` | Điều phối viên |
| `NV0050` | `123` | Bác sĩ/Y sĩ |
| `NV0121` | `123` | Kỹ thuật viên |
| `BN000001` | `123` | Bệnh nhân |
| `NV0021`, `NV0022`, `NV0002`, `NV0003`, `NV0123` | `123` | Test OLS thông báo khẩn |

## 24. Gợi ý lời dẫn demo ngắn

```text
Đồ án của nhóm được triển khai trên Oracle Database và WinForms .NET 8. Ứng dụng gồm hai phân hệ trong cùng một chương trình. Phân hệ 1 phục vụ người quản trị cơ sở dữ liệu, cho phép quản lý user, role, cấp quyền, thu hồi quyền và tra cứu quyền. Phân hệ 2 phục vụ nghiệp vụ quản lý dữ liệu y tế, trong đó mỗi người dùng đăng nhập bằng tài khoản Oracle riêng để cơ chế RBAC, VPD, OLS và Audit được thực thi trực tiếp tại tầng database. Nhóm cũng chuẩn bị phần backup và restore bằng Oracle Data Pump để đáp ứng yêu cầu sao lưu, phục hồi dữ liệu sau sự cố.
```
