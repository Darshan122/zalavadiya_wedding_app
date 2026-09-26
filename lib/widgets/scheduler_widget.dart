import 'package:flutter/material.dart';
import '../services/guest_repository.dart';
import '../theme/wedding_theme.dart';

class SchedulerWidget extends StatelessWidget {
  final GuestRepository repository;

  const SchedulerWidget({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final total = repository.totalCount;
    final sent = repository.sentCount;
    final pending = repository.pendingCount;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF550E1C), WeddingTheme.maroonPrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: WeddingTheme.maroonPrimary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: WeddingTheme.goldAccent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'વોટ્સએપ એન્ટી-બેન (Anti-Ban) સુરક્ષા મોડ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            label: Text('સક્રિય (Active)', style: TextStyle(fontSize: 10, color: Colors.white)),
                            backgroundColor: Colors.green,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '૧૦૦૦ મહેમાનોને એકપણ રૂપિયો ખર્ચ્યા વિના તમારા પર્સનલ વોટ્સએપ પરથી સુરક્ષિત રીતે મેસેજ મોકલવા માટે સિસ્ટમ હ્યુમન-ડિલે (૮-૧૫ સેકન્ડ) અને દૈનિક બેચિંગ વાપરે છે.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 Shield Cards (Column on mobile, Row on desktop)
          if (isMobile) ...[
            _buildShieldCard(
              icon: Icons.timer_outlined,
              title: '૧. રેન્ડમ ડિલે (Human Delay)',
              desc: 'દરેક મેસેજ વચ્ચે ૭ થી ૧૨ સેકન્ડનો આપોઆપ સમય વિલંબ, જેથી WhatsApp ને કોઈ રોબોટિક સ્પામની શંકા ન જાય.',
              status: '૮-૧૨ સેકન્ડ સક્રિય',
            ),
            const SizedBox(height: 10),
            _buildShieldCard(
              icon: Icons.auto_awesome_motion_outlined,
              title: '૨. દૈનિક બેચ વિભાજન',
              desc: '૧૦૦૦ મેસેજને ૧ જ દિવસમાં મોકલવાને બદલે રોજના ૧૫૦ લોકોના નાના જૂથમાં ૫-૬ દિવસમાં મોકલાય છે.',
              status: 'મહત્તમ ૧૫૦ / દિવસ',
            ),
            const SizedBox(height: 10),
            _buildShieldCard(
              icon: Icons.fingerprint_rounded,
              title: '૩. ૧૦૦% અસલ ટેક્સ્ટ',
              desc: 'દરેક મેસેજમાં મહેમાનનું નામ, ગામ અને ચોક્કસ વિધિઓ અલગ હોવાથી કોઈ મેસેજનો ડિજિટલ હેશ ડુપ્લિકેટ બનતો નથી.',
              status: 'પર્સનલાઇઝ્ડ ટેક્સ્ટ',
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildShieldCard(
                    icon: Icons.timer_outlined,
                    title: '૧. રેન્ડમ ડિલે (Human Delay)',
                    desc: 'દરેક મેસેજ વચ્ચે ૭ થી ૧૨ સેકન્ડનો આપોઆપ સમય વિલંબ, જેથી WhatsApp ને કોઈ રોબોટિક સ્પામની શંકા ન જાય.',
                    status: '૮-૧૨ સેકન્ડ સક્રિય',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShieldCard(
                    icon: Icons.auto_awesome_motion_outlined,
                    title: '૨. દૈનિક બેચ વિભાજન',
                    desc: '૧૦૦૦ મેસેજને ૧ જ દિવસમાં મોકલવાને બદલે રોજના ૧૫૦ લોકોના નાના જૂથમાં ૫-૬ દિવસમાં મોકલાય છે.',
                    status: 'મહત્તમ ૧૫૦ / દિવસ',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShieldCard(
                    icon: Icons.fingerprint_rounded,
                    title: '૩. ૧૦૦% અસલ ટેક્સ્ટ',
                    desc: 'દરેક મેસેજમાં મહેમાનનું નામ, ગામ અને ચોક્કસ વિધિઓ અલગ હોવાથી કોઈ મેસેજનો ડિજિટલ હેશ ડુપ્લિકેટ બનતો નથી.',
                    status: 'પર્સનલાઇઝ્ડ ટેક્સ્ટ',
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),

          // Delivery Progress
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: WeddingTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'લગ્ન આમંત્રણ ડિલિવરી પ્રોગ્રેસ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: WeddingTheme.maroonPrimary),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: total > 0 ? (sent / total) : 0,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation(WeddingTheme.palmGreen),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text('કુલ મહેમાનો: $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('મોકલાઈ ગયા: $sent (${total > 0 ? ((sent / total) * 100).toStringAsFixed(1) : 0}%)',
                        style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('બાકી: $pending',
                        style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Chronological Timeline Schedule
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: WeddingTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ઓટોમેટિક સમયપત્રક (Wedding Automation Timeline)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: WeddingTheme.maroonPrimary),
                ),
                const SizedBox(height: 14),

                _buildTimelineItem(
                  phase: 'તબક્કો ૧',
                  title: 'મુખ્ય ડિજિટલ કંકોત્રી (આમંત્રણ કાર્ડ)',
                  timing: 'લગ્નના ૧૫ દિવસ પહેલાં • રોજના ૧૫૦ મેસેજ',
                  target: 'બધા મહેમાનોને',
                  color: WeddingTheme.maroonPrimary,
                ),
                _buildTimelineItem(
                  phase: 'તબક્કો ૨',
                  title: 'માંડવ મુહૂર્ત રિમાઇન્ડર + લોકેશન',
                  timing: '૨૫ જાન્યુઆરી સવારે ૧૧:૦૦ વાગ્યે',
                  target: 'માંડવ = હા વાળા (~૮૦ સભ્યો)',
                  color: WeddingTheme.goldAccent,
                ),
                _buildTimelineItem(
                  phase: 'તબક્કો ૩',
                  title: 'રાસ-ગરબા & ડીજે નાઇટ રિમાઇન્ડર + મેપ',
                  timing: '૨૫ જાન્યુઆરી સાંજે ૫:૦૦ વાગ્યે',
                  target: 'ગરબા = હા વાળા (~૪૫૦ સભ્યો)',
                  color: Colors.purple.shade700,
                ),
                _buildTimelineItem(
                  phase: 'તબક્કો ૪',
                  title: 'પીઠી / હળદર રસમ રિમાઇન્ડર',
                  timing: '૨૬ જાન્યુઆરી સવારે ૭:૦૦ વાગ્યે',
                  target: 'પીઠી = હા વાળા (~૫૦ સભ્યો)',
                  color: Colors.orange.shade800,
                ),
                _buildTimelineItem(
                  phase: 'તબક્કો ૫',
                  title: 'જાન પ્રસ્થાન & શુભ લગ્ન સમારોહ રિમાઇન્ડર',
                  timing: '૨૬ જાન્યુઆરી બપોરે ૨:૦૦ વાગ્યે',
                  target: 'જાન / લગ્ન = હા વાળા',
                  color: WeddingTheme.palmGreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShieldCard({
    required IconData icon,
    required String title,
    required String desc,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WeddingTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: WeddingTheme.maroonPrimary, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 11.5, color: WeddingTheme.textSub, height: 1.3)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 13),
              const SizedBox(width: 4),
              Text(status, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String phase,
    required String title,
    required String timing,
    required String target,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              phase,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                Text(timing, style: const TextStyle(fontSize: 11, color: WeddingTheme.textSub)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(target, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
