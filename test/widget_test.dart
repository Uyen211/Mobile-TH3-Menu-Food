import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:th3_menu_food/main.dart';
import 'package:th3_menu_food/core/constants.dart';

void main() {
  // setUpAll sẽ chạy một lần duy nhất trước toàn bộ các test case trong file này
  setUpAll(() async {
    // Đảm bảo môi trường Test của Flutter đã sẵn sàng
    TestWidgetsFlutterBinding.ensureInitialized();

    // Khởi tạo Supabase cho môi trường test.
    // Chúng ta dùng try-catch để tránh lỗi nếu Supabase đã được khởi tạo trước đó.
    try {
      await Supabase.initialize(
        url: Constants.supabaseUrl,
        anonKey: Constants.supabaseAnonKey,
      );
    } catch (e) {
      // Bỏ qua nếu đã khởi tạo
    }
  });

  testWidgets('Food Menu App Smoke Test', (WidgetTester tester) async {
    // 1. Xây dựng ứng dụng và kích hoạt frame đầu tiên
    await tester.pumpWidget(const MyApp());

    // 2. Kiểm tra tiêu đề AppBar
    // Tìm bất kỳ text nào có chứa "TH3" để xác nhận đúng format yêu cầu
    expect(find.textContaining('TH3'), findsOneWidget);

    // 3. Kiểm tra trạng thái Loading
    // Khi mới vào, FutureBuilder sẽ ở trạng thái chờ và hiện vòng xoay
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 4. Kích hoạt render lại để cập nhật các thay đổi bất đồng bộ (nếu có)
    await tester.pump();

    // Lưu ý: Trong môi trường test, do không có dữ liệu thực từ mạng trả về,
    // thông thường app sẽ rơi vào trạng thái Error hoặc Empty State sau khi pump().
  });
}
