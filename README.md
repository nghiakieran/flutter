# LS Admin App (Flutter)

Ứng dụng quản trị cho hệ thống LaptopStore, xây bằng Flutter, tập trung vào các tác vụ vận hành dành cho admin.

## Chức năng chính

- Xác thực tài khoản admin: đăng nhập, đăng ký, quên mật khẩu, xác thực OTP, đặt lại mật khẩu.
- Dashboard tổng quan: thống kê nhanh và biểu đồ trạng thái đơn hàng.
- Quản lý đơn hàng: xem danh sách, lọc/trạng thái, cập nhật trạng thái đơn.
- Quản lý sản phẩm: CRUD sản phẩm và các thông tin liên quan.
- Quản lý người dùng, đánh giá, mã giảm giá.
- Báo cáo và hồ sơ admin.
- Upload ảnh lên Cloudinary cho luồng quản trị nội dung.

## Cấu trúc thư mục

- `lib/features/auth`: màn hình và luồng xác thực.
- `lib/features/admin`: dashboard và các trang quản trị.
- `lib/core/navigation`: router, hằng số route, shell cho admin.
- `lib/core/network`: API client, endpoint, chuẩn hóa kết quả gọi API.
- `lib/core/services`: dịch vụ dùng chung (storage, media upload, snackbar...).
- `lib/core/di`: cấu hình dependency injection.

## Cấu hình môi trường

Project dùng `String.fromEnvironment`, nên chạy bằng file define:

1. Tạo file `env/dev.json`:

```json
{
  "ENV": "dev",
  "CLOUDINARY_CLOUD_NAME": "your_cloud_name",
  "CLOUDINARY_UPLOAD_PRESET": "your_upload_preset"
}
```

2. Chạy app:

```bash
flutter run --dart-define-from-file=env/dev.json
```

## Cài đặt và chạy local

```bash
flutter clean
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```
