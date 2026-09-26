import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/guest_model.dart';
import '../models/wedding_pdf_model.dart';
import '../services/whatsapp_service.dart';
import '../theme/wedding_theme.dart';

class PdfAutomationSettingsWidget extends StatefulWidget {
  final WeddingPdfConfig pdfConfig;
  final Function(WeddingPdfConfig) onSave;

  const PdfAutomationSettingsWidget({
    super.key,
    required this.pdfConfig,
    required this.onSave,
  });

  @override
  State<PdfAutomationSettingsWidget> createState() => _PdfAutomationSettingsWidgetState();
}

class _PdfAutomationSettingsWidgetState extends State<PdfAutomationSettingsWidget> {
  late TextEditingController _saparivarController;
  late TextEditingController _beVyaktiController;
  late TextEditingController _ekVyaktiController;

  @override
  void initState() {
    super.initState();
    _saparivarController = TextEditingController(text: widget.pdfConfig.saparivarUrl);
    _beVyaktiController = TextEditingController(text: widget.pdfConfig.beVyaktiUrl);
    _ekVyaktiController = TextEditingController(text: widget.pdfConfig.ekVyaktiUrl);
  }

  @override
  void dispose() {
    _saparivarController.dispose();
    _beVyaktiController.dispose();
    _ekVyaktiController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = WeddingPdfConfig(
      saparivarUrl: _saparivarController.text.trim(),
      beVyaktiUrl: _beVyaktiController.text.trim(),
      ekVyaktiUrl: _ekVyaktiController.text.trim(),
    );
    widget.onSave(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: WeddingTheme.palmGreen,
        content: Text('કંકોત્રી PDF લિંક્સ સફળતાપૂર્વક સેવ થઈ ગઈ! ✨'),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('લિંક ખોલી શકાઈ નથી: $url')),
        );
      }
    }
  }

  void _testWhatsAppMessage(String inviteType) {
    final testGuest = GuestModel(
      id: 'test_sample_1',
      name: 'રમેશભાઈ ઝાલાવડીયા',
      phone: '9876543210',
      city: 'અમદાવાદ',
      inviteType: inviteType,
      mandap: true,
      garba: true,
      haldi: true,
      jaan: true,
      lagna: true,
    );

    final config = WeddingPdfConfig(
      saparivarUrl: _saparivarController.text.trim(),
      beVyaktiUrl: _beVyaktiController.text.trim(),
      ekVyaktiUrl: _ekVyaktiController.text.trim(),
    );

    final msg = WhatsAppService.buildMessage(
      guest: testGuest,
      templateKey: 'kankotri',
      pdfConfig: config,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.mark_chat_read_rounded, color: WeddingTheme.maroonPrimary),
            const SizedBox(width: 8),
            Text('ટેસ્ટ મેસેજ પ્રિવ્યુ ($inviteType)', style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WeddingTheme.goldLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: WeddingTheme.borderSubtle),
            ),
            child: SelectableText(
              msg,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('બંધ કરો'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: msg));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('મેસેજ ક્લિપબોર્ડમાં કોપી થઈ ગયો!')),
              );
            },
            icon: const Icon(Icons.copy, size: 16, color: Colors.white),
            label: const Text('મેસેજ કોપી કરો', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [WeddingTheme.maroonPrimary, WeddingTheme.maroonDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: WeddingTheme.maroonPrimary.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WeddingTheme.goldLight.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: WeddingTheme.goldLight, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'લગ્ન કંકોત્રી PDF (૩ પ્રકાર) & ઓટોમેશન',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'મહેમાનના પ્રકાર (સપરિવાર, ૨ વ્યક્તિ, ૧ વ્યક્તિ) મુજબ સાચી PDF મોકલાશે.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WeddingTheme.goldAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: const Text('સેવ કરો', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3 PDF Type Cards
          _buildPdfCard(
            title: '૧. સપરિવાર કંકોત્રી (Full Family)',
            badge: 'સપરિવાર',
            badgeColor: WeddingTheme.maroonPrimary,
            localPath: 'assets/pdf/kankotri_saparivar.pdf',
            description: 'જે મહેમાનોના ડેટામાં "સપરિવાર" લખેલું હશે તેમને આ PDF કાર્ડ લિંક જશે.',
            controller: _saparivarController,
            onTestMsg: () => _testWhatsAppMessage('સપરિવાર'),
          ),

          const SizedBox(height: 14),

          _buildPdfCard(
            title: '૨. બે વ્યક્તિ કંકોત્રી (Couple / 2 Persons)',
            badge: 'બે વ્યક્તિ',
            badgeColor: WeddingTheme.palmGreen,
            localPath: 'assets/pdf/kankotri_be_vyakti.pdf',
            description: 'જે મહેમાનોને ફક્ત ૨ વ્યક્તિનું આમંત્રણ છે તેમને આ PDF કાર્ડ લિંક જશે.',
            controller: _beVyaktiController,
            onTestMsg: () => _testWhatsAppMessage('બે વ્યક્તિ'),
          ),

          const SizedBox(height: 14),

          _buildPdfCard(
            title: '૩. ૧ વ્યક્તિ કંકોત્રી (Single / Individual)',
            badge: '૧ વ્યક્તિ',
            badgeColor: const Color(0xFF1D3557),
            localPath: 'assets/pdf/kankotri_ek_vyakti.pdf',
            description: 'જે મહેમાનોને એકલા વ્યક્તિનું આમંત્રણ છે તેમને આ PDF કાર્ડ લિંક જશે.',
            controller: _ekVyaktiController,
            onTestMsg: () => _testWhatsAppMessage('૧ વ્યક્તિ'),
          ),

          const SizedBox(height: 24),

          // Full Step-by-Step Automation Guide
          _buildAutomationGuideCard(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPdfCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required String localPath,
    required String description,
    required TextEditingController controller,
    required VoidCallback onTestMsg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WeddingTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, color: WeddingTheme.maroonPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: WeddingTheme.maroonPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 11, color: WeddingTheme.textSub)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.folder_open_rounded, size: 13, color: WeddingTheme.textSub),
              const SizedBox(width: 4),
              Text(
                'પ્રોજેક્ટ લોકલ ફાઈલ: $localPath',
                style: const TextStyle(fontSize: 11, color: WeddingTheme.textSub, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // URL Field
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              labelText: 'ઓનલાઇન / ગૂગલ ડ્રાઈવ PDF ડાઉનલોડ લિંક',
              labelStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.link, size: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _openUrl(controller.text),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('લિંક ખોલો', style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onTestMsg,
                icon: const Icon(Icons.message_rounded, size: 14),
                label: const Text('ટેસ્ટ મેસેજ પ્રિવ્યુ', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationGuideCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WeddingTheme.goldLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WeddingTheme.goldAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_mode_rounded, color: WeddingTheme.maroonPrimary, size: 24),
              SizedBox(width: 10),
              Text(
                '૧૦૦૦ લોકોને ઓટોમેટિક WhatsApp મેસેજ મોકલવાના સ્ટેપ્સ (Full Guide)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: WeddingTheme.maroonPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '૧૦૦% મફતમાં તમારા પોતાના WhatsApp પરથી મેસેજ અને સાચી PDF મોકલવાની સંપૂર્ણ રીત:',
            style: TextStyle(fontSize: 12, color: WeddingTheme.textSub),
          ),
          const Divider(height: 24),

          _buildStepRow(
            stepNum: '૧',
            title: 'કંકોત્રી PDF ફાઈલો તૈયાર રાખો',
            description: 'તમારી પાસે જે ૩ કંકોત્રી છે તેને "assets/pdf/" ફોલ્ડરમાં મૂકી દો (kankotri_saparivar.pdf, kankotri_be_vyakti.pdf, kankotri_ek_vyakti.pdf) અથવા ગૂગલ ડ્રાઈવ લિંક ઉપર સેવ કરો.',
          ),
          _buildStepRow(
            stepNum: '૨',
            title: 'Excel / CSV ફાઈલ અપલોડ કરો',
            description: 'મહેમાનોના લિસ્ટમાં "આમંત્રણ પ્રકાર" કોલમમાં "સપરિવાર", "બે વ્યક્તિ", કે "૧ વ્યક્તિ" લખેલું હોવું જોઈએ. આ એપમાં "CSV અપલોડ કરો" બટનથી ૧૦૦૦ મહેમાનો એકસાથે આવી જશે.',
          ),
          _buildStepRow(
            stepNum: '૩',
            title: 'બેકગ્રાઉન્ડ ઓટોમેશન સ્ક્રિપ્ટ રન કરો',
            description: 'તમારા લેપટોપમાં કમાન્ડ પ્રોમ્પ્ટ / ટર્મિનલ ખોલીને પ્રોજેક્ટ ફોલ્ડરમાં લખો:\n> node send_bulk_whatsapp.js',
            isCode: true,
          ),
          _buildStepRow(
            stepNum: '૪',
            title: 'WhatsApp QR કોડ સ્કેન કરો',
            description: 'ટર્મિનલમાં QR કોડ દેખાશે. તમારા મોબાઈલમાંથી WhatsApp > Linked Devices > Link a Device કરીને QR કોડ સ્કેન કરો. કોઈ પણ પૈસા કે API ચાર્જ નથી!',
          ),
          _buildStepRow(
            stepNum: '૫',
            title: 'ઓટોમેટિક સેન્ડિંગ શરૂ થશે',
            description: 'સ્ક્રિપ્ટ દરેક મહેમાનના પ્રકાર પ્રમાણે સાચી PDF ફાઈલ સાથે ગુજરાતી આમંત્રણ કાર્ડ ૧૦ થી ૧૨ સેકન્ડના સુરક્ષિત ડિલેથી મોકલશે. દરરોજ ૧૫૦ થી ૨૦૦ મેસેજ મોકલીને નંબર સુરક્ષિત રહેશે.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNum,
    required String title,
    required String description,
    bool isCode = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: WeddingTheme.maroonPrimary,
              shape: BoxShape.circle,
            ),
            child: Text(
              stepNum,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WeddingTheme.maroonPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: WeddingTheme.textMain,
                    height: 1.35,
                    fontFamily: isCode ? 'monospace' : null,
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
