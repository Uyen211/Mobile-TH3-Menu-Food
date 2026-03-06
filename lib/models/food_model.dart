class Food {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final double price;

  // Constructor sử dụng 'const' để tối ưu hiệu năng render
  const Food({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
  });

  /// Factory method để chuyển đổi từ JSON (Map) sang đối tượng Food
  /// Giúp đảm bảo tính đóng gói và an toàn kiểu dữ liệu
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      // Ép kiểu an toàn cho int
      id: json['id'] as int,

      // Sử dụng toán tử ?? để tránh lỗi Null nếu dữ liệu DB bị thiếu
      name: json['name'] as String? ?? 'Chưa có tên',

      // Map đúng tên cột image_url từ Supabase
      imageUrl: json['image_url'] as String? ?? '',

      description: json['description'] as String? ?? '',

      // Xử lý giá tiền: Supabase có thể trả về int hoặc double
      // Ép kiểu qua 'num' trước khi toDouble() là cách an toàn nhất
      price: (json['price'] as num).toDouble(),
    );
  }

  /// Ghi đè phương thức toString để hỗ trợ việc Debug nhanh chóng
  @override
  String toString() {
    return 'Food(id: $id, name: $name, price: \$$price)';
  }
}
