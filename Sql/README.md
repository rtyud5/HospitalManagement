# Thứ tự chạy khi khởi tạo dữ liệu

## Đăng nhập bằng SYSDBA (PDB)

Chạy file `initDB.sql`

## Đăng nhập bằng ADMIN

Tài khoản: `ADMIN`

Mật khẩu: `12345`

Chạy lần lượt 2 file `insertData.sql` để insert Data và `createUser.sql` để tạo người dùng (tạo người dùng mất rất nhiều thời gian).

# Thứ tự chạy khi muốn xoá toàn bộ dữ liệu

## Đăng nhập bằng ADMIN

Tài khoản: `ADMIN`

Mật khẩu: `12345`

Chạy lần lượt 2 file `dropAllUser.sql` và `dropAllTable.sql` (drop user cũng mất rất nhiều thời gian).
