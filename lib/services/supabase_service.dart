import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_model.dart';

class SupabaseService {
  // Lấy client đã được khởi tạo từ main.dart
  final SupabaseClient _client = Supabase.instance.client;

  /// Lấy danh sách món ăn từ bảng 'foods'
  Future<List<Food>> fetchFoods() async {
    try {
      // 1. Thực hiện truy vấn dữ liệu
      final response = await _client.from('foods').select();

      // 2. (response is non-nullable from Supabase client)

      // 3. Ép kiểu an toàn sang List các Map
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        response,
      );

      // 4. Map dữ liệu từ JSON sang đối tượng Food và trả về
      return data.map((json) => Food.fromJson(json)).toList();
    } on PostgrestException catch (error) {
      // Bắt lỗi riêng biệt từ phía Database (ví dụ: sai tên bảng)
      throw Exception("Lỗi Database: ${error.message}");
    } catch (e) {
      // Bắt các lỗi không xác định khác (ví dụ: lỗi kết nối mạng)
      throw Exception("Lỗi không xác định: $e");
    }
  }
}
