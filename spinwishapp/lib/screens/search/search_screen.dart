import 'package:flutter/material.dart';
import 'package:spinwishapp/services/dj_service.dart';
import 'package:spinwishapp/services/song_api_service.dart';
import 'package:spinwishapp/services/live_session_service.dart';
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/models/song.dart';
import 'package:spinwishapp/models/dj_session.dart';
import 'package:spinwishapp/utils/design_system.dart';
import 'package:spinwishapp/widgets/dj_card.dart';
import 'package:spinwishapp/widgets/song_card.dart';
import 'package:spinwishapp/widgets/session_card_compact.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  bool _isLoading = false;
  
  List<DJ> _djResults = [];
  List<Song> _songResults = [];
  List<DJSession> _sessionResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _djResults.clear();
        _songResults.clear();
        _sessionResults.clear();
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      // Search in parallel
      final futures = await Future.wait([
        _searchDJs(query),
        _searchSongs(query),
        _searchSessions(query),
      ]);

      if (mounted) {
        setState(() {
          _djResults = futures[0] as List<DJ>;
          _songResults = futures[1] as List<Song>;
          _sessionResults = futures[2] as List<DJSession>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<List<DJ>> _searchDJs(String query) async {
    try {
      final allDJs = await DJService.getAllDJs();
      final lowerQuery = query.toLowerCase();
      return allDJs.where((dj) {
        return dj.name.toLowerCase().contains(lowerQuery) ||
            dj.bio.toLowerCase().contains(lowerQuery) ||
            dj.genres.any((genre) => genre.toLowerCase().contains(lowerQuery));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Song>> _searchSongs(String query) async {
    try {
      return await SongApiService.searchSongs(query);
    } catch (e) {
      return [];
    }
  }

  Future<List<DJSession>> _searchSessions(String query) async {
    try {
      final liveSessionService = LiveSessionService();
      return liveSessionService.searchLiveSessions(query);
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              _buildSearchBar(theme),
              
              // Tab Bar
              if (_searchQuery.isNotEmpty) _buildTabBar(theme),
            ],
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildInitialState(theme)
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildSearchResults(theme),
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
        onChanged: _performSearch,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search DJs, songs, or sessions...',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
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

  Widget _buildTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: 'DJs (${_djResults.length})'),
        Tab(text: 'Songs (${_songResults.length})'),
        Tab(text: 'Sessions (${_sessionResults.length})'),
      ],
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
      indicatorColor: theme.colorScheme.primary,
    );
  }

  Widget _buildInitialState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceMD),
          Text(
            'Search SpinWish',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceSM),
          Text(
            'Find DJs, songs, and live sessions',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_djResults.isEmpty && _songResults.isEmpty && _sessionResults.isEmpty) {
      return _buildNoResults(theme);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildDJResults(theme),
        _buildSongResults(theme),
        _buildSessionResults(theme),
      ],
    );
  }

  Widget _buildNoResults(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceMD),
          Text(
            'No results found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: SpinWishDesignSystem.spaceSM),
          Text(
            'Try a different search term',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDJResults(ThemeData theme) {
    if (_djResults.isEmpty) {
      return const Center(child: Text('No DJs found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      itemCount: _djResults.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
          child: DJCard(dj: _djResults[index]),
        );
      },
    );
  }

  Widget _buildSongResults(ThemeData theme) {
    if (_songResults.isEmpty) {
      return const Center(child: Text('No songs found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      itemCount: _songResults.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
          child: SongCard(song: _songResults[index]),
        );
      },
    );
  }

  Widget _buildSessionResults(ThemeData theme) {
    if (_sessionResults.isEmpty) {
      return const Center(child: Text('No sessions found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(SpinWishDesignSystem.spaceMD),
      itemCount: _sessionResults.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceMD),
          child: SessionCardCompact(session: _sessionResults[index]),
        );
      },
    );
  }
}
