import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/widgets/parent_bottom_navigation.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../children/models/child_model.dart';
import '../../children/services/children_service.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../tracking/models/trip_event.dart';
import '../../tracking/screens/live_tracking_screen.dart';
import '../../tracking/services/tracking_api_service.dart';
import '../../tracking/services/trip_id_for_child.dart';
import '../utils/date_formatter.dart';

class JourneyHistoryScreen extends StatefulWidget {
  final String? initialChild;
  final Future<List<TripEvent>> Function(String tripId)? eventLoader;

  const JourneyHistoryScreen({super.key, this.initialChild, this.eventLoader});

  @override
  State<JourneyHistoryScreen> createState() => _JourneyHistoryScreenState();
}

class _JourneyHistoryScreenState extends State<JourneyHistoryScreen>
    with WidgetsBindingObserver {
  static const _filters = ['All', 'Boarding', 'Trip status'];

  final ChildrenService _childrenService = ChildrenService();
  final TrackingApiService _apiService = TrackingApiService();

  StreamSubscription<List<ChildModel>>? _childrenSubscription;
  List<ChildModel> _children = [];
  List<TripEvent> _events = [];
  ChildModel? _selectedChild;
  String _selectedFilter = 'All';
  String? _childrenError;
  String? _error;
  String? _requestedTripKey;
  int _eventRequestGeneration = 0;
  Timer? _pollingTimer;
  bool _isChildrenLoading = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscribeToChildren();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
    } else if (state == AppLifecycleState.paused) {
      _stopPolling();
    }
  }

  void _startPolling() {
    _stopPolling();
    if (_selectedChild == null) return;
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isLoading && _selectedChild != null) {
        _loadEvents(_selectedChild!);
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _subscribeToChildren() {
    _childrenSubscription = _childrenService.getChildrenStream().listen(
      _onChildrenChanged,
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _childrenError = 'Unable to load your linked children.';
          _isChildrenLoading = false;
          _isLoading = false;
          _stopPolling();
        });
      },
    );
  }

  Future<void> _retryChildrenLoad() async {
    await _childrenSubscription?.cancel();
    if (!mounted) return;
    setState(() {
      _childrenError = null;
      _isChildrenLoading = true;
    });
    _subscribeToChildren();
  }

  void _onChildrenChanged(List<ChildModel> children) {
    if (!mounted) return;
    ChildModel? selected;
    if (children.isNotEmpty) {
      selected = children.firstWhere(
        (child) =>
            child.id == _selectedChild?.id ||
            child.name == _selectedChild?.name ||
            child.name == widget.initialChild,
        orElse: () => children.first,
      );
    }

    setState(() {
      _children = children;
      _selectedChild = selected;
      _isChildrenLoading = false;
      _childrenError = null;
      if (children.isEmpty) {
        _events = [];
        _requestedTripKey = null;
        _eventRequestGeneration++;
        _isLoading = false;
        _stopPolling();
      }
    });

    final selectedTripKey = selected == null
        ? null
        : '${selected.id}:${tripIdForChild(selected)}';
    if (selected != null && _requestedTripKey != selectedTripKey) {
      _loadEvents(selected);
    }
    if (selected != null) _startPolling();
  }

  Future<void> _loadEvents(ChildModel child) async {
    final requestGeneration = ++_eventRequestGeneration;
    final tripId = tripIdForChild(child);
    _requestedTripKey = '${child.id}:$tripId';
    if (tripId == null) {
      setState(() {
        _events = [];
        _error = 'Journey history is not available for this route yet.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final events =
          await (widget.eventLoader?.call(tripId) ??
              _apiService.fetchEvents(tripId));
      if (!mounted || requestGeneration != _eventRequestGeneration) return;
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } on TrackingApiException catch (error) {
      if (!mounted || requestGeneration != _eventRequestGeneration) return;
      setState(() {
        _events = [];
        _error = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestGeneration != _eventRequestGeneration) return;
      setState(() {
        _events = [];
        _error = 'Unable to load journey history. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  List<TripEvent> get _filteredEvents {
    switch (_selectedFilter) {
      case 'Boarding':
        return _events
            .where((event) => event.type.toUpperCase() == 'CHILD_BOARDED')
            .toList();
      case 'Trip status':
        return _events
            .where((event) => event.type.toUpperCase().startsWith('TRIP_'))
            .toList();
      default:
        return _events;
    }
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return 'Time unavailable';
    return '${formatJourneyDate(timestamp)} · ${formatTime(timestamp)}';
  }

  void _navigateToTab(int index) {
    if (index == 2) return;
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final child = _selectedChild;
    final Widget destination = switch (index) {
      1 => LiveTrackingScreen(initialChild: child),
      3 => AlertsScreen(initialChild: child),
      4 => const ProfileScreen(),
      _ => const HomeScreen(),
    };
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    _childrenSubscription?.cancel();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Journey History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isChildrenLoading
          ? const Center(child: CircularProgressIndicator())
          : _children.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _childrenError ??
                          'Link a child to view their trip history.',
                      textAlign: TextAlign.center,
                    ),
                    if (_childrenError != null) ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _retryChildrenLoad,
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: DropdownButtonFormField<ChildModel>(
                    value: _selectedChild,
                    decoration: const InputDecoration(
                      labelText: 'Child',
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    items: _children
                        .map(
                          (child) => DropdownMenuItem(
                            value: child,
                            child: Text('${child.name} · ${child.route}'),
                          ),
                        )
                        .toList(),
                    onChanged: (child) {
                      if (child == null) return;
                      setState(() => _selectedChild = child);
                      _loadEvents(child);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ChoiceChip(
                            label: Center(child: Text(filter)),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _selectedFilter = filter),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_error!, textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: _selectedChild == null
                                      ? null
                                      : () => _loadEvents(_selectedChild!),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : events.isEmpty
                      ? const Center(
                          child: Text('No trip updates are available yet.'),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _loadEvents(_selectedChild!),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: events.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return Card(
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.directions_bus_outlined),
                                  ),
                                  title: Text(event.title),
                                  subtitle: Text(
                                    [
                                      if (event.description.isNotEmpty)
                                        event.description,
                                      _formatTime(event.timestamp),
                                    ].join('\n'),
                                  ),
                                  isThreeLine: event.description.isNotEmpty,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: ParentBottomNavigation(
        currentIndex: 2,
        onTap: _navigateToTab,
      ),
    );
  }
}
