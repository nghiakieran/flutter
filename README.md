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

Project tổ chức theo hướng **feature-first** kết hợp **BLoC + Repository pattern** để dễ scale và dễ maintain.

### 7.1 Nguyên tắc tổ chức

- `core/`: các thành phần dùng chung toàn app, không phụ thuộc feature cụ thể.
- `features/`: chia theo nghiệp vụ (`auth`, `admin`), mỗi feature tự chứa data + presentation.
- `shared/`: UI component tái sử dụng giữa nhiều feature.
- Luồng dữ liệu chuẩn: `UI (Page/Widget)` -> `Bloc(Event)` -> `Repository` -> `ApiClient` -> `Bloc(State)` -> `UI`.

### 7.2 Cấu trúc thư mục chi tiết

```text
flutter/
├── lib/
│   ├── core/
│   │   ├── navigation/      # Router, shell, route constants
│   │   ├── network/         # ApiClient (Dio), endpoints, ApiResult/ApiStatus
│   │   ├── services/        # Base service, local storage, media upload, snack bar
│   │   ├── environment/     # App environment (dev/prod/testing)
│   │   ├── blocs/           # Base bloc abstractions
│   │   └── di/              # GetIt container, register repository/bloc theo module
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/          # DTO/auth models
│   │   │   │   └── repositories/    # Auth repository gọi API
│   │   │   └── presentation/
│   │   │       └── pages/           # Login/Register/OTP/Forgot/Reset
│   │   └── admin/
│   │       ├── data/
│   │       │   ├── models/          # Dashboard/order/product/coupon/user/review/report models
│   │       │   └── repositories/    # Repository từng module admin
│   │       └── presentation/
│   │           ├── bloc/            # Event/State/Bloc cho từng module
│   │           ├── pages/           # Màn quản trị
│   │           └── widgets/         # Widget chuyên biệt cho admin
│   ├── shared/
│   │   ├── ui_kit/                  # Button, style primitives
│   │   └── widgets/                 # Loading/empty/OTP và widget tái sử dụng
│   ├── constants/                   # Hằng số toàn app
│   └── theme/                       # App theme, màu sắc, typography
├── env/
│   └── dev.json
└── pubspec.yaml
```

### 7.3 Điểm mạnh kiến trúc hiện tại

- Tách lớp rõ giữa `presentation` và `data`, giúp code dễ test và thay backend dễ hơn.
- BLoC theo module nghiệp vụ nên state management rõ ràng, tránh logic dồn trong UI.
- `core/network` + `core/services` tái sử dụng tốt, giảm trùng lặp khi thêm feature mới.
- `di_container` tập trung giúp kiểm soát vòng đời dependency nhất quán.

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
