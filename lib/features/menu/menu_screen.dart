import 'package:flutter/material.dart';
import 'package:ipot/app_routes.dart';
import 'package:ipot/core/models/menu_category.dart';
import 'package:ipot/features/menu/menu_provider.dart';
import 'package:ipot/features/menu/widgets/menu_item_card.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tableId = ModalRoute.of(context)?.settings.arguments as String?;
    final read = context.read<MenuProvider>();

    if (read.state == MenuState.initial) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => read.init(tableId ?? ''),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Menu - Table ${tableId ?? "Unknown"}'),
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.scanner),
        ),
      ),
      body: Consumer<MenuProvider>(
        builder: (context, provider, child) {
          if (provider.state == MenuState.initial ||
              provider.state == MenuState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == MenuState.error) {
            return _buildError(provider, tableId ?? '');
          }

          return Column(
            children: [
              // Search
              buildSearchBar(provider),

              // Category Tabs
              _buildCategoryTabs(provider),

              // Menu List
              Expanded(child: _buildMenuList(provider)),
            ],
          );
        },
      ),
    );
  }

  Center _buildError(MenuProvider provider, String tableId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Could not load menu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.init(tableId),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildSearchBar(MenuProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        onChanged: provider.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search menu...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: provider.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => provider.updateSearchQuery(''),
                )
              : null,
        ),
      ),
    );
  }

  SizedBox _buildCategoryTabs(MenuProvider provider) {
    final categories = [
      // "All" as a virtual category
      const MenuCategory(id: -1, name: 'All', sortOrder: 0),
      ...provider.categories,
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = provider.selectedCategoryId == category.id;

          return FilterChip(
            label: Text(category.name),
            selected: isSelected,
            onSelected: (value) {
              provider.selectCategory(category.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuList(MenuProvider provider) {
    final items = provider.filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'No items match "${provider.searchQuery}"'
                  : 'No items in this category',
              style: const TextStyle(color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
      itemBuilder: (context, index) => MenuItemCard(item: items[index]),
    );
  }
}
