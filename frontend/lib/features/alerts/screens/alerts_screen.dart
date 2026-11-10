import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/widgets/parent_bottom_navigation.dart';
import '../../children/models/child_model.dart';
import '../../children/services/children_service.dart';
import '../../history/screens/journey_history_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../tracking/models/trip_event.dart';
import '../../tracking/screens/live_tracking_screen.dart';
import '../../tracking/services/tracking_api_service.dart';
import '../../tracking/services/trip_id_for_child.dart';

class AlertsScreen extends StatefulWidget {
  final ChildModel? initialChild;

  const AlertsScreen({super.key, this.initialChild});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ChildrenService _childrenService = ChildrenService();
  final TrackingApiService _apiService = TrackingApiService();

  StreamSubscription<List<ChildModel>>? _childrenSubscription;
  List<ChildModel> _children = [];
  List<TripEvent> _events = [];
  ChildModel? _selectedChild;
  String? _childrenError;
  String? _error;
  String? _requestedTripKey;
  int _eventRequestGeneration = 0;
  bool _isChildrenLoading = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedChild = widget.initialChild;
    _subscribeToChildren();
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
      final selectedId = _selectedChild?.id;
      selected = children.firstWhere(
        (child) => child.id == selectedId,
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
      }
    });

    final selectedTripKey = selected == null
        ? null
        : '${selected.id}:${tripIdForChild(selected)}';
    if (selected != null && _requestedTripKey != selectedTripKey) {
      _loadEvents(selected);
    }
  }

  Future<void> _loadEvents(ChildModel child) async {
    final requestGeneration = ++_eventRequestGeneration;
    final tripId = tripIdForChild(child);
    _requestedTripKey = '${child.id}:$tripId';
    if (tripId == null) {
      setState(() {
        _events = [];
        _error = 'Alerts are not available for this child’s route yet.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final events = await _apiService.fetchEvents(tripId);
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
        _error =
            'Unable to load trip updates. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return 'Time unavailable';
    final local = timestamp.toLocal().toString();
    return local.length >= 16 ? local.substring(0, 16) : local;
  }

  void _navigateToTab(int index) {
    if (index == 3) return;
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final child = _selectedChild;
    final Widget destination = switch (index) {
      1 => LiveTrackingScreen(initialChild: child),
      2 => JourneyHistoryScreen(initialChild: child?.name),
      4 => const ProfileScreen(),
      _ => HomeScreen(),
    };
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  void dispose() {
    _childrenSubscription?.cancel();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_children.isNotEmpty)
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
          Expanded(
            child: _isChildrenLoading
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
                                'Link a child to see their trip alerts.',
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
                : _isLoading
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
                : _events.isEmpty
                ? const Center(
                    child: Text('No trip updates are available yet.'),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadEvents(_selectedChild!),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.notifications_active_outlined),
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
        currentIndex: 3,
        onTap: _navigateToTab,
      ),
    );
  }
}
