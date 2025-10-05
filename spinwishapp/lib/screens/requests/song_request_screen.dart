import 'package:flutter/material.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/models/club.dart';
import 'package:spinwishapp/models/song.dart';
import 'package:spinwishapp/models/request.dart';
import 'package:spinwishapp/models/payment.dart';
import 'package:spinwishapp/services/song_api_service.dart';
import 'package:spinwishapp/services/user_requests_service.dart'
    as UserRequests;

import 'package:spinwishapp/widgets/song_tile.dart';
import 'package:spinwishapp/screens/payment/payment_screen.dart';

class SongRequestScreen extends StatefulWidget {
  final Session session;
  final DJ dj;
  final Club club;

  const SongRequestScreen({
    super.key,
    required this.session,
    required this.dj,
    required this.club,
  });

  @override
  State<SongRequestScreen> createState() => _SongRequestScreenState();
}

class _SongRequestScreenState extends State<SongRequestScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  List<Song> allSongs = [];
  List<Song> filteredSongs = [];
  List<Song> popularSongs = [];
  List<Request> myRequests = [];
  Song? selectedSong;
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Load songs from API
      final songs = await SongApiService.getAllSongs();

      // Load user's requests for this session (placeholder - would need API endpoint)
      final requests =
          <Request>[]; // TODO: Implement API call for user requests

      setState(() {
        allSongs = songs;
        filteredSongs = allSongs;
        popularSongs = allSongs.where((song) => song.popularity > 85).toList();
        myRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        allSongs = [];
        filteredSongs = [];
        popularSongs = [];
        myRequests = [];
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load songs: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterSongs(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredSongs = allSongs;
      } else {
        filteredSongs = allSongs.where((song) {
          return song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase()) ||
              song.album.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectSong(Song song) {
    setState(() {
      selectedSong = song;
    });
    _showRequestDialog(song);
  }

  void _showRequestDialog(Song song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRequestDialog(song),
    );
  }

  Widget _buildRequestDialog(Song song) {
    final theme = Theme.of(context);
    final basePrice = song.baseRequestPrice;
    final dynamicPrice =
        basePrice * (1 + (widget.session.upcomingRequests.length * 0.1));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Song info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: song.artworkUrl.isNotEmpty
                      ? Image.network(
                          song.artworkUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 80,
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.music_note,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.music_note,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 40,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            song.formattedDuration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Price info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Request Price',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'KSH ${dynamicPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (dynamicPrice > basePrice) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Base price: KSH ${basePrice.toStringAsFixed(2)} + demand surcharge',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Queue position: ~${widget.session.upcomingRequests.length + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Optional message
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Add a message (optional)',
                hintText: 'Let the DJ know why you love this song...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.message),
              ),
              maxLines: 2,
              maxLength: 100,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _proceedToPayment(song, dynamicPrice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                        'Request for KSH ${dynamicPrice.toStringAsFixed(2)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToPayment(Song song, double amount) async {
    Navigator.pop(context); // Close dialog

    try {
      // First create the song request
      final requestResult =
          await UserRequests.UserRequestsService.requestSongWithPayment(
        djId: widget.dj.id,
        songId: song.id,
        tipAmount: amount,
        paymentMethod: 'mpesa',
        message: _messageController.text.trim(),
        sessionId: widget.session.id,
      );

      final request = requestResult['request'] as UserRequests.PlaySongResponse;

      // Navigate to payment screen with the created request ID
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              type: PaymentType.songRequest,
              amount: amount,
              description: 'Song Request: ${song.title}',
              metadata: {
                'songId': song.id,
                'sessionId': widget.session.id,
                'djId': widget.dj.id,
                'requestId': request.id, // Use the actual request ID
                'message': _messageController.text.trim(),
              },
            ),
          ),
        ).then((result) {
          if (result == true) {
            // Payment successful, refresh requests
            _loadData();
            _messageController.clear();
          }
        });
      }
    } catch (e) {
      // Handle error creating request
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create request: ${e.toString()}'),
            backgroundColor: Colors.red,
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
        title: const Text('Request a Song'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSongs,
              decoration: InputDecoration(
                hintText: 'Search songs, artists, or albums...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterSongs('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Session info banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.club.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.club.imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 40,
                                  height: 40,
                                  color: theme.colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.nightlife,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                color: theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.nightlife,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.club.name} • ${widget.dj.name}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${widget.session.listeners} listeners • ${widget.session.upcomingRequests.length} in queue',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab bar
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Browse'),
                    Tab(text: 'Popular'),
                    Tab(text: 'My Requests'),
                  ],
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBrowseTab(),
                      _buildPopularTab(),
                      _buildMyRequestsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBrowseTab() {
    if (filteredSongs.isEmpty && isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No songs found'),
            Text('Try a different search term'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        final song = filteredSongs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SongTile(
            song: song,
            onRequest: () => _selectSong(song),
          ),
        );
      },
    );
  }

  Widget _buildPopularTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: popularSongs.length,
      itemBuilder: (context, index) {
        final song = popularSongs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SongTile(
            song: song,
            onRequest: () => _selectSong(song),
          ),
        );
      },
    );
  }

  Widget _buildMyRequestsTab() {
    if (myRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_music, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No requests yet'),
            Text('Request your first song!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myRequests.length,
      itemBuilder: (context, index) {
        final request = myRequests[index];
        final song = allSongs.firstWhere(
          (s) => s.id == request.songId,
          orElse: () => Song(
            id: request.songId,
            title: 'Unknown Song',
            artist: 'Unknown Artist',
            album: '',
            genre: '',
            duration: 0,
            artworkUrl: '',
            baseRequestPrice: 0.0,
            popularity: 0,
            isExplicit: false,
          ),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: song.artworkUrl.isNotEmpty
                  ? Image.network(
                      song.artworkUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.music_note,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.music_note,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),
            title: Text(song.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.artist),
                if (request.message?.isNotEmpty == true)
                  Text(
                    '"${request.message}"',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'KSH ${request.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRequestStatusColor(request.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getRequestStatusText(request.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRequestStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.accepted:
        return Colors.blue;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.played:
        return Colors.green;
    }
  }

  String _getRequestStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.played:
        return 'Played';
    }
  }
}
