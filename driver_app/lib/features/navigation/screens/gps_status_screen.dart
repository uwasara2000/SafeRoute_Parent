import 'package:flutter/material.dart';

class GpsStatusScreen extends StatefulWidget {
  final String driverName;

  const GpsStatusScreen({
    super.key,
    this.driverName = 'Dilan',
  });

  @override
  State<GpsStatusScreen> createState() => _GpsStatusScreenState();
}

class _GpsStatusScreenState extends State<GpsStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Radar pulse animation
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Entrance slide animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(),

            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Animated Radar Rings & Target
                        _buildRadarHeader(),

                        const SizedBox(height: 18),

                        // Status Badge: STANDBY
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'STANDBY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Headline & Subtitle
                        const Text(
                          'Location sharing is off',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'GPS starts automatically during an authorized trip.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // Status Details Card (3 rows)
                        _buildStatusCard(),

                        const SizedBox(height: 18),

                        // Privacy Protected Card
                        _buildPrivacyCard(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          const Text(
            'GPS status',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarHeader() {
    return SizedBox(
      width: 190,
      height: 190,
      child: AnimatedBuilder(
        animation: _radarController,
        builder: (context, child) {
          return CustomPaint(
            painter: _RadarPulsePainter(progress: _radarController.value),
            child: Center(
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC7EBD3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.my_location_rounded,
                    size: 32,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Location permission
          _buildStatusRow(
            icon: Icons.my_location_rounded,
            title: 'Location permission',
            subtitle: 'Precise · Allow all the time',
            badgeText: 'ALLOWED',
            badgeBg: const Color(0xFFEFF6FF),
            badgeColor: const Color(0xFF2563EB),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Row 2: Last successful update
          _buildStatusRow(
            icon: Icons.access_time_rounded,
            title: 'Last successful update',
            subtitle: 'Today, 8:07 AM',
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Row 3: Connection
          _buildStatusRow(
            icon: Icons.alt_route_rounded,
            title: 'Connection',
            subtitle: 'Mobile data · strong signal',
            badgeText: 'ONLINE',
            badgeBg: const Color(0xFFEFF6FF),
            badgeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeBg,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg ?? const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: badgeColor ?? const Color(0xFF2563EB),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 22,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Privacy protected',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your location is shared only during assigned transport operations.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter that renders subtle expanding radar waves
class _RadarPulsePainter extends CustomPainter {
  final double progress;

  _RadarPulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Static ambient ring
    final staticPaint = Paint()
      ..color = const Color(0xFFD6EDE0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, 78, staticPaint);
    canvas.drawCircle(center, 58, staticPaint);

    // Dynamic pulsating wave ring 1
    final waveRadius1 = 44 + (progress * 48);
    final waveAlpha1 = (1.0 - progress).clamp(0.0, 1.0);
    final pulsePaint1 = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.35 * waveAlpha1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, waveRadius1, pulsePaint1);

    // Dynamic pulsating wave ring 2 (offset)
    final progress2 = (progress + 0.5) % 1.0;
    final waveRadius2 = 44 + (progress2 * 48);
    final waveAlpha2 = (1.0 - progress2).clamp(0.0, 1.0);
    final pulsePaint2 = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.25 * waveAlpha2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, waveRadius2, pulsePaint2);
  }

  @override
  bool shouldRepaint(covariant _RadarPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
