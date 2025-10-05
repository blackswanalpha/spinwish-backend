import 'package:flutter/material.dart';

import 'package:spinwishapp/services/favorites_service.dart';
import 'package:spinwishapp/services/dj_service.dart';
import 'package:spinwishapp/models/dj.dart';

import 'package:spinwishapp/utils/design_system.dart';
import 'package:spinwishapp/widgets/dj_card.dart';

class FavoriteDJsScreen extends StatefulWidget {
  const FavoriteDJsScreen({super.key});

  @override
  State<FavoriteDJsScreen> createState() => _FavoriteDJsScreenState();
}

class _FavoriteDJsScreenState extends State<FavoriteDJsScreen> {
  List<DJ> _favoriteDJs = [];
  List<DJ> _filteredDJs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavoriteDJs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteDJs() async {
    try {
      setState(() => _isLoading = true);

      // Get favorite DJ IDs
      final favoriteItems = await FavoritesService.getFavoriteDJs();
      final favoriteIds = favoriteItems.map((item) => item.favoriteId).toList();

      // Get all DJs and filter favorites
      final allDJs = await DJService.getAllDJs();
      final favoriteDJs =
          allDJs.where((dj) => favoriteIds.contains(dj.id)).toList();

      if (mounted) {
        setState(() {
          _favoriteDJs = favoriteDJs;
          _filteredDJs = favoriteDJs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load favorite DJs: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _filterDJs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredDJs = _favoriteDJs;
      } else {
        _filteredDJs = _favoriteDJs.where((dj) {
          return dj.name.toLowerCase().contains(query.toLowerCase()) ||
              dj.bio.toLowerCase().contains(query.toLowerCase()) ||
              dj.genres.any(
                  (genre) => genre.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  Future<void> _removeFavorite(DJ dj) async {
    try {
      await FavoritesService.removeFavoriteDJ(dj.id);

      if (mounted) {
        setState(() {
          _favoriteDJs.removeWhere((favDj) => favDj.id == dj.id);
          _filteredDJs.removeWhere((favDj) => favDj.id == dj.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${dj.name} removed from favorites'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _addFavorite(dj),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove favorite: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _addFavorite(DJ dj) async {
    try {
      await FavoritesService.addFavoriteDJ(dj);

      if (mounted) {
        setState(() {
          _favoriteDJs.add(dj);
          _filterDJs(_searchQuery); // Reapply filter
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${dj.name} added back to favorites')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add favorite: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite DJs',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadFavoriteDJs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(theme),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDJs.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildDJsList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusMD),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: SpinWishDesignSystem.shadowSM(theme.colorScheme.shadow),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterDJs,
        decoration: InputDecoration(
          hintText: 'Search favorite DJs...',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterDJs('');
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SpinWishDesignSystem.spaceMD,
            vertical: SpinWishDesignSystem.spaceMD,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.favorite_border,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceMD),
          Text(
            _searchQuery.isNotEmpty
                ? 'No DJs found for "$_searchQuery"'
                : 'No favorite DJs yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceSM),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Start adding DJs to your favorites to see them here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: SpinWishDesignSystem.spaceLG),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.explore),
              label: const Text('Discover DJs'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDJsList(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadFavoriteDJs,
      child: ListView.builder(
        padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
        itemCount: _filteredDJs.length,
        itemBuilder: (context, index) {
          final dj = _filteredDJs[index];
          return Padding(
            padding:
                const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
            child: DJCard(
              dj: dj,
              showFavoriteButton: true,
              isFavorite: true,
              onFavoriteToggle: () => _removeFavorite(dj),
            ),
          );
        },
      ),
    );
  }
}
