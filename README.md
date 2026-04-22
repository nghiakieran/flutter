# LS Admin App (Flutter)

Ứng dụng quản trị cho hệ thống bán laptop, xây dựng bằng Flutter, tập trung vào các nghiệp vụ vận hành dành cho admin.

## 1) Mục tiêu dự án

- Xây dựng ứng dụng quản trị di động cho đội vận hành.
- Chuẩn hóa giao tiếp frontend-backend theo nhóm API `api/v1/admin`.
- Tổ chức code theo hướng dễ mở rộng, tách rõ presentation - business - data.

## 2) Công nghệ sử dụng

- Flutter
- BLoC
- Dio
- GoRouter
- GetIt
- SharedPreferences
- Cloudinary (upload ảnh quản trị)

## 3) Chức năng chính

- Dashboard tổng quan: doanh thu, đơn hàng, người dùng, biểu đồ trạng thái đơn.
- Quản lý đơn hàng: xem danh sách, chi tiết, cập nhật trạng thái.
- Quản lý sản phẩm: CRUD sản phẩm.
- Quản lý thương hiệu: CRUD brand.
- Quản lý mã giảm giá: CRUD coupon.
- Quản lý đánh giá: duyệt ẩn/hiện và phản hồi review.
- Quản lý người dùng/staff: xác minh user, tạo/sửa/xóa staff.
- Quản lý báo cáo: xem summary và export báo cáo.
- Quản lý hồ sơ admin.

## 4) Luồng màn hình Admin

- `Splash` -> `Login` -> `AdminShell`.
- Module chính trong shell:
  - `Dashboard`
  - `Order Management`
  - `Product Management`
  - `Coupon Management`
  - `Review Management`
  - `User Management`
  - `Reports`
  - `Profile`

## 5) API chính (Admin)

Tất cả route admin đi qua middleware `authenticate` + `requireAdmin`.

- `GET /api/v1/admin/dashboard`
- `GET /api/v1/admin/orders`
- `GET /api/v1/admin/orders/:id`
- `PUT /api/v1/admin/orders/:id/status`
- `GET /api/v1/admin/products`
- `POST /api/v1/admin/products`
- `PUT /api/v1/admin/products/:id`
- `DELETE /api/v1/admin/products/:id`
- `GET /api/v1/admin/brands`
- `POST /api/v1/admin/brands`
- `PUT /api/v1/admin/brands/:id`
- `DELETE /api/v1/admin/brands/:id`
- `GET /api/v1/admin/coupons`
- `POST /api/v1/admin/coupons`
- `PUT /api/v1/admin/coupons/:id`
- `DELETE /api/v1/admin/coupons/:id`
- `GET /api/v1/admin/reviews`
- `PUT /api/v1/admin/reviews/:id/visibility`
- `PUT /api/v1/admin/reviews/:id/reply`
- `GET /api/v1/admin/reports/summary`
- `GET /api/v1/admin/reports/export`
- `GET /api/v1/admin/users`
- `PUT /api/v1/admin/users/:id/verified`
- `POST /api/v1/admin/staffs`
- `PUT /api/v1/admin/staffs/:id`
- `DELETE /api/v1/admin/staffs/:id`

## 6) Workflow các service chính

- `adminDashboardRepository`: tải số liệu dashboard.
- `adminOrderRepository`: tải danh sách đơn + cập nhật trạng thái.
- `adminProductRepository`: CRUD sản phẩm + thương hiệu.
- `adminCouponRepository`: CRUD coupon.
- `adminReviewRepository`: duyệt/ẩn và phản hồi review.
- `adminUserRepository`: quản lý user xác minh và tài khoản staff.
- `adminReportRepository`: tổng hợp và export báo cáo.

## 7) Cấu trúc chính

```text
flutter/
├── lib/
│   ├── core/
│   │   ├── navigation/      # Router, shell, constants
│   │   ├── network/         # Api client/endpoints/result
│   │   ├── services/        # Storage, media upload, snackbar...
│   │   └── di/              # Dependency injection
│   ├── features/
│   │   ├── auth/            # Login, OTP, reset password
│   │   └── admin/           # Dashboard + các module quản trị
│   └── shared/              # Widget dùng chung
├── env/
│   └── dev.json
└── pubspec.yaml
```

## 8) Setup local

### 8.1 Chạy Backend

```bash
cd ../BTVN_MOBILE/BE_BTVN
npm install
npm run dev
```

### 8.2 Chạy Admin App (Flutter)

```bash
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

## 9) Kiểm thử thủ công khuyến nghị

- Đăng nhập admin.
- Dashboard tải đúng số liệu.
- Cập nhật trạng thái đơn hàng.
- CRUD sản phẩm/brand/coupon.
- Duyệt và phản hồi review.
- Tạo/sửa/xóa staff, xác minh user.
- Export report.

## 10) Ghi chú

Dự án được phát triển theo định hướng của môn Lập trình di động nâng cao, từ phân tích yêu cầu đến triển khai thực tế.  
Nhóm mong muốn nhận thêm góp ý để tiếp tục nâng cao chất lượng ứng dụng.
