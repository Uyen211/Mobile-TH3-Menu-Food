import 'dart:io'; // Bắt buộc phải thêm để nhận diện SocketException
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Food>> fetchFoods() async {
    try {
      // Gọi dữ liệu từ Supabase
      final response = await _client.from('foods').select();

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        response,
      );

      return data.map((json) => Food.fromJson(json)).toList();
    } on PostgrestException catch (error) {
      // Lỗi từ phía Database (Ví dụ: Sai tên bảng, sai quyền RLS)
      throw Exception("Lỗi dữ liệu: Không thể truy cập danh sách món ăn.");
    } on SocketException {
      // Lỗi mất kết nối mạng thực tế (Thường xảy ra trên Mobile)
      throw Exception(
        "Mất kết nối Internet. Vui lòng kiểm tra lại WiFi hoặc 3G/4G.",
      );
    } catch (e) {
      // Kiểm tra lỗi mạng thông qua chuỗi string nếu SocketException không bắt được
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('socketexception') ||
          errorString.contains('connection failed') ||
          errorString.contains('network_error')) {
        throw Exception("Không có kết nối mạng. Vui lòng thử lại sau.");
      }

      // Các lỗi logic khác
      throw Exception("Đã xảy ra lỗi khi tải dữ liệu món ăn.");
    }
  }
}
