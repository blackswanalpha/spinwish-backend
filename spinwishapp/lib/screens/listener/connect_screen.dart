import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinwishapp/services/listener_service.dart';
import 'package:spinwishapp/services/location_service.dart';
import 'package:spinwishapp/services/dj_discovery_service.dart';
import 'package:spinwishapp/models/dj_session.dart';
import 'package:spinwishapp/screens/listener/session_detail_screen.dart';
import 'package:spinwishapp/widgets/nearby_dj_card.dart';
import 'package:spinwishapp/widgets/discovery_filters_widget.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>
    with TickerProviderStateMixin {
  final _linkController = TextEditingController();
  late TabController _tabController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListenerService>(context, listen: false).startDiscovery();
      Provider.of<DJDiscoveryService>(context, listen: false).startDiscovery();
    });
  }

  @override
  void dispose() {
    _linkController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connect to DJ',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<DJDiscoveryService>(
            builder: (context, discoveryService, child) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                ),
                tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nearby', icon: Icon(Icons.location_on)),
            Tab(text: 'All Sessions', icon: Icon(Icons.radio)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filters (if shown)
          if (_showFilters) ...[
            Consumer<DJDiscoveryService>(
              builder: (context, discoveryService, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: DiscoveryFiltersWidget(
                    discoveryService: discoveryService,
                    onFiltersChanged: () {
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ],

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNearbyDJsTab(),
                _buildAllSessionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyDJsTab() {
    return Consumer2<DJDiscoveryService, LocationService>(
      builder: (context, discoveryService, locationService, child) {
        final theme = Theme.of(context);

        if (!locationService.hasLocationPermission) {
          return _buildLocationPermissionRequired(theme, locationService);
        }

        if (discoveryService.isDiscovering &&
            discoveryService.nearbyDJs.isEmpty) {
          return _buildDiscoveringState(theme);
        }

        if (discoveryService.error != null) {
          return _buildErrorState(theme, discoveryService.error!);
        }

        if (discoveryService.nearbyDJs.isEmpty) {
          return _buildNoNearbyDJsState(theme);
        }

        return Column(
          children: [
            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: DiscoveryStatsWidget(discoveryService: discoveryService),
            ),

            // Nearby DJs List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: discoveryService.nearbyDJs.length,
                itemBuilder: (context, index) {
                  final nearbyDJ = discoveryService.nearbyDJs[index];
                  return NearbyDJCard(
                    nearbyDJ: nearbyDJ,
                    onTap: () => _viewDJProfile(nearbyDJ),
                    onConnect: () =>
                        _connectToNearbyDJ(nearbyDJ, discoveryService),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllSessionsTab() {
    return Consumer<ListenerService>(
      builder: (context, listenerService, child) {
        final theme = Theme.of(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Join by Link Section
              _buildJoinByLinkSection(theme, listenerService),
              const SizedBox(height: 32),

              // Discover Sessions Section
              _buildDiscoverSection(theme, listenerService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJoinByLinkSection(
      ThemeData theme, ListenerService listenerService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Join by Link',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Have a session link? Paste it here to join directly.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _linkController,
            decoration: InputDecoration(
              hintText: 'https://spinwish.app/session/...',
              prefixIcon: Icon(Icons.link, color: theme.colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _joinByLink(listenerService),
              icon: const Icon(Icons.login),
              label: const Text('Join Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverSection(
      ThemeData theme, ListenerService listenerService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Discover Live Sessions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (listenerService.isDiscovering)
              IconButton(
                onPressed: () => listenerService.stopDiscovery(),
                icon: const Icon(Icons.stop),
                tooltip: 'Stop Discovery',
              )
            else
              IconButton(
                onPressed: () => listenerService.startDiscovery(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (listenerService.isDiscovering &&
            listenerService.availableSessions.isEmpty)
          _buildLoadingState(theme)
        else if (listenerService.availableSessions.isEmpty)
          _buildEmptyState(theme)
        else
          _buildSessionsList(theme, listenerService),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Discovering live sessions...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No live sessions found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later or join using a session link',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(ThemeData theme, ListenerService listenerService) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listenerService.availableSessions.length,
      itemBuilder: (context, index) {
        final session = listenerService.availableSessions[index];
        return _buildSessionCard(theme, session, listenerService);
      },
    );
  }

  Widget _buildSessionCard(
      ThemeData theme, DJSession session, ListenerService listenerService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _joinSession(session, listenerService),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.description ?? 'Live DJ session',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'LIVE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${session.listenerCount} listening',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    session.type == SessionType.club
                        ? Icons.location_on
                        : Icons.wifi,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.type == SessionType.club ? 'Club' : 'Online',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              if (session.genres.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: session.genres.take(3).map((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        genre,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _joinByLink(ListenerService listenerService) async {
    final link = _linkController.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session link')),
      );
      return;
    }

    final session = await listenerService.getSessionByLink(link);
    if (session != null) {
      _joinSession(session, listenerService);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid session link')),
        );
      }
    }
  }

  void _joinSession(DJSession session, ListenerService listenerService) async {
    final success = await listenerService.connectToSession(session.id);
    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SessionDetailScreen(session: session),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join session')),
      );
    }
  }

  // Nearby DJs helper methods
  Widget _buildLocationPermissionRequired(
      ThemeData theme, LocationService locationService) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_disabled,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Location Permission Required',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Enable location access to discover nearby DJs and connect to live sessions in your area.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final granted =
                    await locationService.requestLocationPermission();
                if (granted && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Location permission granted! Discovering nearby DJs...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Enable Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveringState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Discovering nearby DJs...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Searching for live sessions in your area',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Discovery Error',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<DJDiscoveryService>(context, listen: false)
                    .startDiscovery();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoNearbyDJsState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_searching,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Nearby DJs',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no live DJs in your area right now. Try expanding your search radius or check back later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showFilters = true;
                });
              },
              icon: const Icon(Icons.tune),
              label: const Text('Adjust Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewDJProfile(NearbyDJ nearbyDJ) {
    // Navigate to DJ profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${nearbyDJ.name}\'s profile')),
    );
  }

  void _connectToNearbyDJ(
      NearbyDJ nearbyDJ, DJDiscoveryService discoveryService) async {
    if (!nearbyDJ.isLive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DJ is not currently live')),
      );
      return;
    }

    final success = await discoveryService.connectToNearbyDJ(nearbyDJ);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${nearbyDJ.name}!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to session screen
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to connect to DJ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
