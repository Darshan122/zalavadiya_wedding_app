import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/guest_model.dart';
import '../models/wedding_event_model.dart';
import '../models/wedding_pdf_model.dart';
import '../services/guest_repository.dart';
import '../services/whatsapp_service.dart';
import '../theme/wedding_theme.dart';

class WhatsAppPreviewWidget extends StatefulWidget {
  final GuestRepository repository;
  final GuestModel? initialSelectedGuest;
  final List<WeddingEventModel> events;
  final WeddingPdfConfig? pdfConfig;

  const WhatsAppPreviewWidget({
    super.key,
    required this.repository,
    this.initialSelectedGuest,
    required this.events,
    this.pdfConfig,
  });

  @override
  State<WhatsAppPreviewWidget> createState() => _WhatsAppPreviewWidgetState();
}

class _WhatsAppPreviewWidgetState extends State<WhatsAppPreviewWidget> {
  GuestModel? _selectedGuest;
  String _selectedTemplateKey = 'kankotri';
  late TextEditingController _messageController;
  int _mobileSubTab = 0; // 0: Editor, 1: Live Phone Simulator

  @override
  void initState() {
    super.initState();
    _selectedGuest = widget.initialSelectedGuest ??
        (widget.repository.guests.isNotEmpty ? widget.repository.guests.first : null);
    _messageController = TextEditingController();
    _regenerateMessage();
  }

  @override
  void didUpdateWidget(covariant WhatsAppPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool shouldRegen = false;
    if (widget.initialSelectedGuest != null &&
        widget.initialSelectedGuest?.id != oldWidget.initialSelectedGuest?.id) {
      _selectedGuest = widget.initialSelectedGuest;
      shouldRegen = true;
    }
    if (widget.pdfConfig != oldWidget.pdfConfig) {
      shouldRegen = true;
    }
    if (shouldRegen) {
      _regenerateMessage();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _regenerateMessage() {
    if (_selectedGuest == null) {
      _messageController.text = '';
      return;
    }
    final msg = WhatsAppService.buildMessage(
      guest: _selectedGuest!,
      templateKey: _selectedTemplateKey,
      events: widget.events,
      pdfConfig: widget.pdfConfig,
    );
    _messageController.text = msg;
  }

  @override
  Widget build(BuildContext context) {
    final guests = widget.repository.guests;
    if (_selectedGuest == null && guests.isNotEmpty) {
      _selectedGuest = guests.first;
      _regenerateMessage();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Column(
            children: [
              // Mobile Segmented Toggle
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: WeddingTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _mobileSubTab = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _mobileSubTab == 0 ? WeddingTheme.maroonPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '✍️ સંદેશ સંપાદન (Editor)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _mobileSubTab == 0 ? Colors.white : WeddingTheme.textSub,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _mobileSubTab = 1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _mobileSubTab == 1 ? WeddingTheme.maroonPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '📱 WhatsApp પ્રિવ્યુ (Phone)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _mobileSubTab == 1 ? Colors.white : WeddingTheme.textSub,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Active View with Scroll
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _mobileSubTab == 0
                      ? _buildEditorCard(guests)
                      : Center(child: _buildPhoneSimulator()),
                ),
              ),
            ],
          );
        }

        // Desktop Side-by-Side View
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildEditorCard(guests),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(child: _buildPhoneSimulator()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditorCard(List<GuestModel> guests) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WeddingTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WeddingTheme.greenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: WeddingTheme.palmGreen, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'વોટ્સએપ મેસેજ જનરેટર',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WeddingTheme.maroonPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Guest dropdown
          const Text('મહેમાન પસંદ કરો:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: WeddingTheme.ivoryBg,
              border: Border.all(color: WeddingTheme.borderSubtle),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGuest?.id,
                isExpanded: true,
                hint: const Text('મહેમાન પસંદ કરો'),
                items: guests.map((g) {
                  return DropdownMenuItem<String>(
                    value: g.id,
                    child: Text(
                      '${g.name} (${g.city}) - ${g.inviteType}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  );
                }).toList(),
                onChanged: (id) {

                  final g = guests.firstWhere((x) => x.id == id);
                  setState(() => _selectedGuest = g);
                  _regenerateMessage();
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Template dropdown
          const Text('આમંત્રણ / રિમાઇન્ડર પ્રકાર:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: WeddingTheme.ivoryBg,
              border: Border.all(color: WeddingTheme.borderSubtle),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTemplateKey,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'kankotri', child: Text('૧. ડિજિટલ કંકોત્રી (સંપૂર્ણ આમંત્રણ)')),
                  DropdownMenuItem(value: 'mandap_rem', child: Text('૨. માંડવ મુહૂર્ત રિમાઇન્ડર (૨૫મી ૩:૦૦ PM)')),
                  DropdownMenuItem(value: 'garba_rem', child: Text('૩. રાસ-ગરબા & ડીજે રિમાઇન્ડર (૨૫મી ૮:૦૦ PM)')),
                  DropdownMenuItem(value: 'haldi_rem', child: Text('૪. પીઠી રસમ રિમાઇન્ડર (૨૬મી ૯:૦૦ AM)')),
                  DropdownMenuItem(value: 'jaan_rem', child: Text('૫. જાન પ્રસ્થાન રિમાઇન્ડર (૨૬મી ૫:૦૦ PM)')),
                  DropdownMenuItem(value: 'lagna_rem', child: Text('૬. શુભ લગ્ન સમારોહ રિમાઇન્ડર (૨૬મી ૭:૦૦ PM)')),
                  DropdownMenuItem(value: 'custom_alert', child: Text('૭. તાત્કાલિક સૂચના (Emergency Alert)')),
                ],
                onChanged: (key) {
                  if (key != null) {
                    setState(() => _selectedTemplateKey = key);
                    _regenerateMessage();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Message Editor Area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('સંદેશો સંપાદિત કરો:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              TextButton.icon(
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                onPressed: _regenerateMessage,
                icon: const Icon(Icons.refresh, size: 14, color: WeddingTheme.maroonPrimary),
                label: const Text('રીસેટ', style: TextStyle(fontSize: 11, color: WeddingTheme.maroonPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _messageController,
            maxLines: 9,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 12.5, height: 1.4),
            decoration: const InputDecoration(
              hintText: 'મેસેજ લખો...',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: WeddingTheme.ivoryBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: WeddingTheme.borderSubtle),
            ),
            child: const Text(
              'ટેગ્સ: {નામ}, {ગામ}, {આમંત્રણ_પ્રકાર}, {ઈવેન્ટ_યાદી}, {મુખ્ય_સ્થળ}, {સ્થળ_મેપ}',
              style: TextStyle(fontSize: 10.5, color: WeddingTheme.textLight),
            ),
          ),
          const SizedBox(height: 16),

          // Send & Copy Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _sendViaWhatsApp,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'વોટ્સએપ મોકલો',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: WeddingTheme.borderSubtle),
                ),
                onPressed: _copyMessage,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('કોપી'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneSimulator() {
    final guestName = _selectedGuest?.name ?? 'મહેમાનનું નામ';
    final avatarChar = guestName.isNotEmpty ? guestName.characters.first : 'દ';

    return Container(
      width: 320,
      height: 520,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAE2),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0xFF1E293B), width: 6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // Speaker bar
            Container(
              height: 18,
              color: const Color(0xFF1E293B),
              child: Center(
                child: Container(
                  width: 60,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            // WhatsApp Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              color: const Color(0xFF075E54),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: WeddingTheme.goldLight,
                    child: Text(
                      avatarChar,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: WeddingTheme.maroonPrimary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guestName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'online • દર્શન weds બ્રિજળ',
                          style: TextStyle(color: Color(0xFF98E4B0), fontSize: 9.5),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chat area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('આજે', style: TextStyle(fontSize: 9.5, color: Colors.black54)),
                      ),
                      const SizedBox(height: 8),

                      // Outgoing bubble
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 250),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9FDD3),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                            border: Border.all(color: const Color(0xFFC0E8BA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedTemplateKey == 'kankotri' && _selectedGuest != null)
                                () {
                                  final pdfCfg = widget.pdfConfig ?? WeddingPdfConfig.defaultConfig();
                                  final pdfInfo = pdfCfg.getInfoForType(_selectedGuest!.inviteType);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: WeddingTheme.goldBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 18),
                                        ),
                                        const SizedBox(width: 7),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pdfInfo.fileName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF111B21)),
                                              ),
                                              Text(
                                                'PDF દસ્તાવેજ • ${pdfInfo.type} • 1.2 MB',
                                                style: const TextStyle(fontSize: 8.5, color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.download_rounded, size: 16, color: Color(0xFF075E54)),
                                      ],
                                    ),
                                  );
                                }(),
                              Text(
                                _messageController.text,
                                style: const TextStyle(fontSize: 10.5, height: 1.35, color: Color(0xFF111B21)),
                              ),
                              const SizedBox(height: 3),
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Spacer(),
                                  Text('૧૨:૪૫ PM', style: TextStyle(fontSize: 8.5, color: Colors.black45)),
                                  SizedBox(width: 2),
                                  Icon(Icons.done_all, color: Colors.blue, size: 12),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: const Color(0xFFF0F2F5),
              child: Row(
                children: [
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text('સંદેશ લખો...', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF00A884),
                    child: Icon(Icons.mic, color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendViaWhatsApp() async {
    if (_selectedGuest == null) return;
    if (_selectedGuest!.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('આ મહેમાનનો મોબાઈલ નંબર ઉપલબ્ધ નથી.')),
      );
      return;
    }

    await WhatsAppService.launchWhatsApp(
      phone: _selectedGuest!.phone,
      message: _messageController.text,
    );

    await widget.repository.markGuestSent(_selectedGuest!.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade800,
          content: Text('${_selectedGuest!.name} ને વોટ્સએપ મોકલાઈ ગયું.'),
        ),
      );
    }
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: _messageController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('સંદેશ સફળતાપૂર્વક કોપી થઈ ગયો!')),
    );
  }
}
