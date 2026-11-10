import 'dart:async';
import 'package:flutter/material.dart';
import 'package:saferoute_parent/models/child_model.dart';
import 'package:saferoute_parent/models/journey_model.dart';
import 'package:saferoute_parent/services/api_client.dart';
import 'package:saferoute_parent/services/journey_service.dart';
import 'package:saferoute_parent/services/mock_journey_service.dart';
import 'package:saferoute_parent/theme/app_theme.dart';
import 'package:saferoute_parent/widgets/child_selector.dart';
import 'package:saferoute_parent/widgets/journey_card.dart';
import 'package:saferoute_parent/widgets/journey_filter_tabs.dart';

class JourneyHistoryScreen extends StatefulWidget {
  final JourneyService? journeyService;

  const JourneyHistoryScreen({super.key, this.journeyService});

  @override
  State<JourneyHistoryScreen> createState() => _JourneyHistoryScreenState();
}

class _JourneyHistoryScreenState extends State<JourneyHistoryScreen>
    with WidgetsBindingObserver {
  List<Child> _children = [];
  Child? _selectedChild;
  JourneyFilter _selectedFilter = JourneyFilter.all;
  List<Journey> _journeys = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  late JourneyService _journeyService;
  Timer? _pollingTimer;
  static const _pollInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _journeyService = widget.journeyService ?? MockJourneyService();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
    } else if (state == AppLifecycleState.paused) {
      _stopPolling();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final children = await _journeyService.getChildren();
      if (!mounted) return;

      if (children.isNotEmpty) {
        _children = children;
        _selectedChild = children.first;
        final journeys = await _journeyService.getJourneys(
          _selectedChild!.id,
          filter: _selectedFilter,
        );
        if (!mounted) return;
        setState(() {
          _journeys = journeys;
        });
      } else {
        _children = [];
        _selectedChild = null;
        _journeys = [];
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.type) {
          case ApiErrorType.unauthorized:
            _errorMessage = 'Session expired. Please log in again.';
            break;
          case ApiErrorType.network:
            _errorMessage = 'No internet connection. Please check your network.';
            break;
          case ApiErrorType.server:
          case ApiErrorType.unknown:
            _errorMessage = 'Something went wrong. Please try again.';
            break;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _startPolling();
      }
    }
  }

  Future<void> _loadJourneys() async {
    if (_selectedChild == null) return;

    try {
      final journeys = await _journeyService.getJourneys(
        _selectedChild!.id,
        filter: _selectedFilter,
      );
      if (!mounted) return;
      setState(() {
        _journeys = journeys;
        _errorMessage = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.type) {
        case ApiErrorType.unauthorized:
          message = 'Session expired. Please log in again.';
          break;
        case ApiErrorType.network:
          message = 'No internet connection. Please check your network.';
          break;
        case ApiErrorType.server:
        case ApiErrorType.unknown:
          message = 'Something went wrong. Please try again.';
          break;
      }
      _handleLoadJourneysError(message);
    } catch (_) {
      if (!mounted) return;
      _handleLoadJourneysError('An unexpected error occurred');
    }
  }

  void _handleLoadJourneysError(String message) {
    if (_isRefreshing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  Future<void> _onRefresh() async {
    _isRefreshing = true;
    await _loadJourneys();
    _isRefreshing = false;
  }

  void _startPolling() {
    _stopPolling();
    _pollingTimer = Timer.periodic(_pollInterval, (_) => _loadJourneys());
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.statusCancelled,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_bus_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No journeys found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null && _journeys.isEmpty) {
      return _buildErrorView();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _onRefresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ChildSelector(
              children: _children,
              selectedChild: _selectedChild,
              onChanged: (Child child) {
                setState(() {
                  _selectedChild = child;
                });
                _loadJourneys();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: JourneyFilterTabs(
              selectedFilter: _selectedFilter,
              onFilterChanged: (JourneyFilter filter) {
                setState(() {
                  _selectedFilter = filter;
                });
                _loadJourneys();
              },
            ),
          ),
          const SizedBox(height: 8),
          if (_journeys.isEmpty)
            _buildEmptyView()
          else
            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _journeys.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'THIS WEEK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }
                  final journey = _journeys[index - 1];
                  return JourneyCard(
                    journey: journey,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey History'),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
    );
  }
}
