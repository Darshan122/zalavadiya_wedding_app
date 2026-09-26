import 'package:flutter/material.dart';
import '../models/guest_model.dart';
import '../models/wedding_event_model.dart';
import '../models/wedding_pdf_model.dart';
import '../services/guest_repository.dart';
import '../theme/wedding_theme.dart';
import '../widgets/guest_list_widget.dart';
import '../widgets/pdf_automation_settings_widget.dart';
import '../widgets/scheduler_widget.dart';
import '../widgets/venue_settings_widget.dart';
import '../widgets/whatsapp_preview_widget.dart';

class DashboardScreen extends StatefulWidget {
  final GuestRepository repository;

  const DashboardScreen({super.key, required this.repository});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  GuestModel? _selectedGuestForPreview;
  List<WeddingEventModel> _events = WeddingEventModel.getDefaultEvents();
  WeddingPdfConfig _pdfConfig = WeddingPdfConfig.defaultConfig();

  @override
  void initState() {
    super.initState();
    _loadPdfConfig();
  }

  Future<void> _loadPdfConfig() async {
    final cfg = await WeddingPdfConfig.load();
    if (mounted) {
      setState(() => _pdfConfig = cfg);
    }
  }

  void _onGuestSelectForPreview(GuestModel guest) {
    setState(() {
      _selectedGuestForPreview = guest;
      _currentIndex = 1; // switch to WhatsApp tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: WeddingTheme.ivoryBg,
          appBar: isMobile ? _buildMobileAppBar() : null,
          bottomNavigationBar: isMobile ? _buildMobileBottomNav() : null,
          body: SafeArea(
            child: Column(
              children: [
                // Luxury Pinterest Wedding Hero (Adapted for Desktop & Mobile)
                if (!isMobile) _buildDesktopHero() else _buildMobileHeroCollapsible(),

                // Desktop / Tablet Pill Navigation
                if (!isMobile) _buildDesktopNavigationPills(),

                // Active View Body - Strictly Expanded with inner scroll to eliminate overflows!
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12.0 : 24.0,
                      vertical: 10.0,
                    ),
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        GuestListWidget(
                          repository: widget.repository,
                          onSelectForPreview: _onGuestSelectForPreview,
                          pdfConfig: _pdfConfig,
                        ),
                        WhatsAppPreviewWidget(
                          repository: widget.repository,
                          initialSelectedGuest: _selectedGuestForPreview,
                          events: _events,
                          pdfConfig: _pdfConfig,
                        ),
                        PdfAutomationSettingsWidget(
                          pdfConfig: _pdfConfig,
                          onSave: (updated) {
                            setState(() => _pdfConfig = updated);
                            updated.save();
                          },
                        ),
                        SchedulerWidget(
                          repository: widget.repository,
                        ),
                        VenueSettingsWidget(
                          events: _events,
                          onSave: (updated) => setState(() => _events = updated),
                        ),
                      ],
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

  // --- Mobile App Bar ---
  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: WeddingTheme.goldBorder, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/wedding_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.favorite, color: WeddingTheme.maroonPrimary, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'દર્શન weds બ્રિજળ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: WeddingTheme.maroonPrimary,
                  ),
                ),
                Text(
                  'ઝાલાવડીયા પરિવાર • મહુવા ♾️ અમદાવાદ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: WeddingTheme.textSub),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: WeddingTheme.borderSubtle),
      ),
    );
  }

  // --- Mobile Collapsible Hero Card ---
  Widget _buildMobileHeroCollapsible() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WeddingTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildMobileMetric('કુલ મહેમાનો', widget.repository.totalCount.toString(), WeddingTheme.maroonPrimary)),
          Container(height: 24, width: 1, color: WeddingTheme.borderSubtle),
          Expanded(child: _buildMobileMetric('મોકલાઈ ગયા', widget.repository.sentCount.toString(), Colors.green.shade700)),
          Container(height: 24, width: 1, color: WeddingTheme.borderSubtle),
          Expanded(child: _buildMobileMetric('બાકી (Pending)', widget.repository.pendingCount.toString(), Colors.amber.shade900)),
        ],
      ),
    );
  }

  Widget _buildMobileMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10.5, color: WeddingTheme.textSub)),
      ],
    );
  }

  // --- Mobile Bottom Navigation Bar ---
  Widget _buildMobileBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: WeddingTheme.borderSubtle)),
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: Colors.white,
        indicatorColor: WeddingTheme.goldLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt_rounded, color: WeddingTheme.maroonPrimary),
            label: 'મહેમાનો',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded, color: WeddingTheme.maroonPrimary),
            label: 'WhatsApp',
          ),
          NavigationDestination(
            icon: Icon(Icons.picture_as_pdf_outlined),
            selectedIcon: Icon(Icons.picture_as_pdf_rounded, color: WeddingTheme.maroonPrimary),
            label: 'કંકોત્રી PDF',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded, color: WeddingTheme.maroonPrimary),
            label: 'શિડ્યુલર',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on_rounded, color: WeddingTheme.maroonPrimary),
            label: 'સ્થળ વિગત',
          ),
        ],
      ),
    );
  }

  // --- Desktop Luxury Pinterest Hero ---
  Widget _buildDesktopHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF550E1C),
            Color(0xFF7A1C2E),
            Color(0xFF8E283A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: WeddingTheme.maroonPrimary.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo in Luxury Gold Ring
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: WeddingTheme.goldAccent, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                'assets/images/wedding_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => const Center(
                  child: Text('દ ♾️ બ', style: TextStyle(color: WeddingTheme.maroonPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: WeddingTheme.goldAccent.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        '✨ મહુવા ♾️ અમદાવાદ • ઝાલાવડીયા પરિવાર',
                        style: TextStyle(color: WeddingTheme.goldLight, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text('Leva Patel Wedding', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                  ],
                ),

                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'દર્શન ',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextSpan(
                        text: 'weds ',
                        style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: WeddingTheme.goldLight),
                      ),
                      TextSpan(
                        text: 'બ્રિજળ',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '📅 ૨૫ જાન્યુઆરી: માંડવ (૩:૦૦ PM) | ગરબા (૮:૦૦ PM)  •  ૨૬ જાન્યુઆરી: પીઠી (૯:૦૦ AM) | જાન (૫:૦૦ PM) | લગ્ન (૭:૦૦ PM)',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ),

          // Glassmorphic Stats Counters
          _buildDesktopStat('કુલ મહેમાનો', widget.repository.totalCount.toString(), Colors.white),
          const SizedBox(width: 10),
          _buildDesktopStat('મોકલાઈ ગયા', widget.repository.sentCount.toString(), const Color(0xFF6EE7B7)),
          const SizedBox(width: 10),
          _buildDesktopStat('બાકી (Pending)', widget.repository.pendingCount.toString(), const Color(0xFFFCA5A5)),
        ],
      ),
    );
  }

  Widget _buildDesktopStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- Desktop Navigation Pills ---
  Widget _buildDesktopNavigationPills() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildNavPill(0, Icons.people_alt_rounded, 'મહેમાનોની યાદી (${widget.repository.totalCount})'),
            const SizedBox(width: 10),
            _buildNavPill(1, Icons.chat_bubble_rounded, 'WhatsApp લાઈવ પ્રિવ્યુ'),
            const SizedBox(width: 10),
            _buildNavPill(2, Icons.picture_as_pdf_rounded, '📄 કંકોત્રી PDF (૩ પ્રકાર) & ઓટોમેશન'),
            const SizedBox(width: 10),
            _buildNavPill(3, Icons.shield_rounded, '૧૦૦૦ મેસેજ શિડ્યુલર (Anti-Ban)'),
            const SizedBox(width: 10),
            _buildNavPill(4, Icons.location_on_rounded, 'વિધિ સમય & સ્થળ વિગત'),
          ],
        ),
      ),
    );
  }


  Widget _buildNavPill(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? WeddingTheme.goldBorder : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? WeddingTheme.maroonPrimary : WeddingTheme.textSub,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: isSelected ? WeddingTheme.maroonPrimary : WeddingTheme.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
