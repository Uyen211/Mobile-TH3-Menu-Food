import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/supabase_service.dart';
import '../widgets/food_card.dart';
import '../widgets/error_view.dart';
import 'food_detail_screen.dart';
import '../core/theme_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _service = SupabaseService();
  late Future<List<Food>> _foodsFuture;

  @override
  void initState() {
    super.initState();
    _foodsFuture = _service.fetchFoods();
  }

  /// Hàm dùng chung để làm mới dữ liệu
  Future<void> _handleRefresh() async {
    setState(() {
      _foodsFuture = _service.fetchFoods();
    });
    // Đợi Future hoàn thành để vòng xoay RefreshIndicator biến mất đúng lúc
    await _foodsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Make title occupy full width and center-align; allow two lines so
        // the student name and id display fully on Android devices.
        title: SizedBox(
          width: double.infinity,
          child: Text(
            'TH3\nNguyễn Hà Phương Uyên - 2351170632',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 2,
            softWrap: true,
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 72,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // Theme toggle
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: ThemeController.toggle,
                tooltip: 'Toggle theme',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              // Launch search delegate; delegate will read current foods via the future
              await showSearch(
                context: context,
                delegate: _FoodSearchDelegate(() => _foodsFuture),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Food>>(
        future: _foodsFuture,
        builder: (context, snapshot) {
          // 1. Trạng thái Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái Lỗi
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _handleRefresh, // Dùng chung hàm refresh
            );
          }

          // 3. Trạng thái Thành công nhưng Trống
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text("Chưa có dữ liệu món ăn nào.")),
                ],
              ),
            );
          }

          // 4. Trạng thái Thành công có dữ liệu
          final List<Food> foods = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              // Đảm bảo GridView luôn có thể kéo được để kích hoạt RefreshIndicator
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                // Đổi từ 0.65 thành 0.6 để tăng chiều cao cho ô Grid, tránh lỗi overflow
                childAspectRatio: 0.63,
              ),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                return FoodCard(food: foods[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

/// A simple SearchDelegate that queries the provided future supplier and
/// filters foods by name (case-insensitive).
class _FoodSearchDelegate extends SearchDelegate<Food?> {
  final Future<List<Food>> Function() _fetchFoods;

  _FoodSearchDelegate(this._fetchFoods);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Food>>(
      future: _fetchFoods(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final results = snapshot.data!
            .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (results.isEmpty) {
          return const Center(child: Text('Không tìm thấy kết quả.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: results.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final food = results[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  close(context, food);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FoodDetailScreen(food: food),
                    ),
                  );
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(food.imageUrl, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '\$${food.price.toStringAsFixed(1)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Nhập tên món ăn để tìm kiếm'));
    }
    return buildResults(context);
  }
}
