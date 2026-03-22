# Tài liệu Hướng dẫn Thực hiện - Bài tập 01: App Manager

Tài liệu này hướng dẫn chi tiết các bước từ khi khởi tạo dự án đến khi hoàn thiện 02 màn hình theo yêu cầu của Bài tập 01.

## 1. Các bước khởi tạo dự án

1. **Kiểm tra môi trường**: 
   Đảm bảo Flutter SDK và Dart đã được cài đặt đúng cách bằng lệnh:
   ```bash
   flutter --version
   ```

2. **Khởi tạo dự án**:
   Mở terminal tại thư mục làm việc (`/Users/sunshine/Desktop/Mobile/flutter`) và chạy lệnh khởi tạo:
   ```bash
   flutter create --project-name app_manager .
   ```

3. **Cấu trúc thư mục**:
   Tạo thư mục `lib/screens` để quản lý các màn hình của ứng dụng:
   ```bash
   mkdir -p lib/screens
   ```

## 2. Xây dựng các màn hình và Logic

### Bước 1: Thiết lập Hệ thống Route (Navigation)
Tại file `lib/main.dart`, tiến hành cấu hình `MaterialApp` để quản lý các màn hình:
- Sử dụng `initialRoute: '/'` để đặt `SplashScreen` là màn hình khởi động.
- Khai báo danh sách các `routes` để điều hướng dễ dàng.

### Bước 2: Xây dựng Trang Giới thiệu (SplashScreen)
Tại file `lib/screens/splash_screen.dart`:
1. Sử dụng một `StatefulWidget`.
2. Trình bày danh sách thành viên nhóm (Sỹ Thuần, v.v.).
3. **Thiết lập Timer**: Tại hàm `initState()`, sử dụng lớp `Timer` từ thư viện `dart:async` để đếm ngược 10 giây.
   ```dart
   Timer(const Duration(seconds: 10), () {
     Navigator.of(context).pushReplacementNamed('/login');
   });
   ```
4. Sử dụng `pushReplacementNamed` để ngăn người dùng quay lại trang giới thiệu sau khi đã chuyển sang trang đăng nhập.

### Bước 3: Xây dựng Trang Đăng nhập (LoginScreen)
Tại file `lib/screens/login_screen.dart`:
1. Thiết kế giao diện chuyên nghiệp cho Manager với `TextField` (Email, Password).
2. Thêm các thành phần hỗ trợ: Quên mật khẩu, Đăng ký, Icon đại diện.
3. Sử dụng `SingleChildScrollView` giúp giao diện không bị lỗi khi bàn phím ảo hiện lên.

## 3. Tổng kết Luồng Hoạt động
- **Mở App** -> Hiện **Màn hình giới thiệu** (10 giây) -> **Trang Đăng nhập**.
- Toàn bộ giao diện được thiết kế theo chuẩn Material 3 với bảng màu Blue chủ đạo, mang lại cảm giác chuyên nghiệp cho một ứng dụng quản lý.

---
*Ghi chú: Luồng xử lý được hiện thực hóa dựa trên yêu cầu của Bài tập 01 - Lớp Di động.*
