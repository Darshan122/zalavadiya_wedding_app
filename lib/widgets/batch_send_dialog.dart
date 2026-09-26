import 'dart:async';
import 'package:flutter/material.dart';
import '../models/guest_model.dart';
import '../models/wedding_pdf_model.dart';
import '../services/guest_repository.dart';
import '../services/whatsapp_service.dart';
import '../theme/wedding_theme.dart';

class BatchSendDialog extends StatefulWidget {
  final GuestRepository repository;
  final WeddingPdfConfig? pdfConfig;

  const BatchSendDialog({
    super.key,
    required this.repository,
    this.pdfConfig,
  });

  @override
  State<BatchSendDialog> createState() => _BatchSendDialogState();
}

class _BatchSendDialogState extends State<BatchSendDialog> {
  String _selectedCeremony = 'kankotri';
  int _delaySeconds = 10;
  bool _isSending = false;
  bool _isPaused = false;
  int _currentIndex = 0;
  int _countdown = 0;
  Timer? _countdownTimer;
  List<GuestModel> _targetGuests = [];

  @override
  void initState() {
    super.initState();
    _updateTargetGuests();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateTargetGuests() {
    final all = widget.repository.guests;
    setState(() {
      _targetGuests = all.where((g) {
        if (g.status == 'Sent') return false; // only pending guests
        if (_selectedCeremony == 'mandap') return g.mandap;
        if (_selectedCeremony == 'garba') return g.garba;
        if (_selectedCeremony == 'haldi') return g.haldi;
        if (_selectedCeremony == 'jaan') return g.jaan;
        if (_selectedCeremony == 'lagna') return g.lagna;
        return true; // kankotri goes to all pending
      }).toList();
    });
  }

  void _startBatchSend() {
    if (_targetGuests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('કોઈ બાકી મહેમાન મળ્યા નથી.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _isPaused = false;
      _currentIndex = 0;
    });

    _sendNextGuest();
  }

  Future<void> _sendNextGuest() async {
    if (!_isSending || _isPaused) return;

    if (_currentIndex >= _targetGuests.length) {
      setState(() {
        _isSending = false;
        _countdown = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('અભિનંદન! પસંદ કરેલા તમામ મહેમાનોને મેસેજ મોકલાઈ ગયા!'),
          ),
        );
      }
      return;
    }

    final currentGuest = _targetGuests[_currentIndex];
    final message = WhatsAppService.buildMessage(
      guest: currentGuest,
      templateKey: _selectedCeremony,
      pdfConfig: widget.pdfConfig,
    );

    // Launch WhatsApp
    await WhatsAppService.launchWhatsApp(
      phone: currentGuest.phone,
      message: message,
    );

    // Mark sent in database
    await widget.repository.markGuestSent(currentGuest.id);

    setState(() {
      _currentIndex++;
      _countdown = _delaySeconds;
    });

    // Start countdown timer for next message (Anti-Ban safety pacing)
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isPaused) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _sendNextGuest();
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    if (!_isPaused) {
      _sendNextGuest();
    }
  }

  void _stopSending() {
    _countdownTimer?.cancel();
    setState(() {
      _isSending = false;
      _isPaused = false;
      _countdown = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Color(0xFF128C7E), size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ઓટોમેટિક બેચ સેન્ડર (Auto Send)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WeddingTheme.maroonPrimary),
                      ),
                    ],
                  ),
                  if (!_isSending)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (!_isSending) ...[
                // Ceremony selector
                const Text('કઈ વિધિ માટે મેસેજ મોકલવા છે?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: WeddingTheme.ivoryBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WeddingTheme.borderSubtle),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCeremony,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'kankotri', child: Text('૧. મુખ્ય ડિજિટલ કંકોત્રી')),
                        DropdownMenuItem(value: 'mandap', child: Text('૨. માંડવ મુહૂર્ત રિમાઇન્ડર (૨૫મી ૩:૦૦ PM)')),
                        DropdownMenuItem(value: 'garba', child: Text('૩. રાસ-ગરબા & ડીજે રિમાઇન્ડર (૨૫મી ૮:૦૦ PM)')),
                        DropdownMenuItem(value: 'haldi', child: Text('૪. પીઠી રસમ રિમાઇન્ડર (૨૬મી ૯:૦૦ AM)')),
                        DropdownMenuItem(value: 'jaan', child: Text('૫. જાન પ્રસ્થાન રિમાઇન્ડર (૨૬મી ૫:૦૦ PM)')),
                        DropdownMenuItem(value: 'lagna', child: Text('૬. શુભ લગ્ન સમારોહ રિમાઇન્ડર (૨૬મી ૭:૦૦ PM)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCeremony = val);
                          _updateTargetGuests();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Audience Stat
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WeddingTheme.goldLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WeddingTheme.goldBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'આ વિધિમાં બાકી મહેમાનો:',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: WeddingTheme.textSub),
                      ),
                      Text(
                        '${_targetGuests.length} વ્યક્તિઓ',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WeddingTheme.maroonPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Delay Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('મેસેજ વચ્ચે સુરક્ષિત સમય વિલંબ (Anti-Ban):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('$_delaySeconds સેકન્ડ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Slider(
                  value: _delaySeconds.toDouble(),
                  min: 5,
                  max: 20,
                  divisions: 15,
                  activeColor: WeddingTheme.palmGreen,
                  label: '$_delaySeconds સેકન્ડ',
                  onChanged: (v) => setState(() => _delaySeconds = v.round()),
                ),
                Text(
                  'અંદાજે સમય: ${((_targetGuests.length * _delaySeconds) / 60).toStringAsFixed(1)} મિનિટ લાગશે.',
                  style: const TextStyle(fontSize: 11, color: WeddingTheme.textLight),
                ),
                const SizedBox(height: 20),

                // Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: _startBatchSend,
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text('ઓટોમેટિક મોકલવાનું શરૂ કરો', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                // Sending In Progress Screen
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WeddingTheme.ivoryBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WeddingTheme.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'મોકલાઈ રહ્યું છે: $_currentIndex / ${_targetGuests.length}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WeddingTheme.maroonPrimary),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _targetGuests.isNotEmpty ? (_currentIndex / _targetGuests.length) : 0,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF25D366)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (_currentIndex < _targetGuests.length) ...[
                        Text(
                          'હાલનો મહેમાન: ${_targetGuests[_currentIndex].name}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'મોબાઈલ: ${_targetGuests[_currentIndex].phone} (${_targetGuests[_currentIndex].city})',
                          style: const TextStyle(fontSize: 12, color: WeddingTheme.textSub),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            _isPaused ? '⏸️ થોભેલું છે (Paused)' : '⏳ આગળનો મેસેજ $_countdown સેકન્ડમાં...',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pause / Stop Controls
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _togglePause,
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 18),
                        label: Text(_isPaused ? 'ચાલુ કરો' : 'થોભો (Pause)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: _stopSending,
                        icon: const Icon(Icons.stop_rounded, size: 18),
                        label: const Text('બંધ કરો (Stop)'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
