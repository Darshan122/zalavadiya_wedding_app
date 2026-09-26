import 'package:flutter/material.dart';
import '../models/wedding_event_model.dart';
import '../theme/wedding_theme.dart';

class VenueSettingsWidget extends StatefulWidget {
  final List<WeddingEventModel> events;
  final Function(List<WeddingEventModel>) onSave;

  const VenueSettingsWidget({
    super.key,
    required this.events,
    required this.onSave,
  });

  @override
  State<VenueSettingsWidget> createState() => _VenueSettingsWidgetState();
}

class _VenueSettingsWidgetState extends State<VenueSettingsWidget> {
  late List<TextEditingController> _venueControllers;
  late List<TextEditingController> _addressControllers;
  late List<TextEditingController> _mapControllers;

  @override
  void initState() {
    super.initState();
    _venueControllers = widget.events.map((e) => TextEditingController(text: e.venueName)).toList();
    _addressControllers = widget.events.map((e) => TextEditingController(text: e.address)).toList();
    _mapControllers = widget.events.map((e) => TextEditingController(text: e.mapUrl)).toList();
  }

  @override
  void dispose() {
    for (var c in _venueControllers) {
      c.dispose();
    }
    for (var c in _addressControllers) {
      c.dispose();
    }
    for (var c in _mapControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: WeddingTheme.goldLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on_rounded, color: WeddingTheme.maroonPrimary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'વિધિઓ & Google Maps લોકેશન',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: WeddingTheme.maroonPrimary),
                            ),
                            Text(
                              'આ લિંક્સ બધા મહેમાનોના વોટ્સએપ મેસેજમાં જોડાશે.',
                              style: TextStyle(fontSize: 11, color: WeddingTheme.textSub),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WeddingTheme.maroonPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: const Text('સેવ કરો', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Events
                ...widget.events.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ev = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: WeddingTheme.ivoryBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: WeddingTheme.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: WeddingTheme.maroonPrimary,
                              child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${ev.titleGujarati} (${ev.englishSubtitle})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WeddingTheme.maroonPrimary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: WeddingTheme.goldBorder),
                              ),
                              child: Text('${ev.dateText} • ${ev.timeText}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Form fields (stacked on mobile, row on desktop)
                        if (isMobile) ...[
                          TextField(
                            controller: _venueControllers[idx],
                            decoration: const InputDecoration(
                              labelText: 'સ્થળનું નામ (Venue Name)',
                              prefixIcon: Icon(Icons.home_work_outlined, size: 16),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _addressControllers[idx],
                            decoration: const InputDecoration(
                              labelText: 'સરનામું / વિગત (Address)',
                              prefixIcon: Icon(Icons.place_outlined, size: 16),
                              isDense: true,
                            ),
                          ),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _venueControllers[idx],
                                  decoration: const InputDecoration(
                                    labelText: 'સ્થળનું નામ (Venue Name)',
                                    prefixIcon: Icon(Icons.home_work_outlined, size: 16),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _addressControllers[idx],
                                  decoration: const InputDecoration(
                                    labelText: 'સરનામું / વિગત (Address)',
                                    prefixIcon: Icon(Icons.place_outlined, size: 16),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _mapControllers[idx],
                          decoration: const InputDecoration(
                            labelText: 'Google Maps Link',
                            prefixIcon: Icon(Icons.map_outlined, size: 16),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _saveSettings() {
    for (int i = 0; i < widget.events.length; i++) {
      widget.events[i].venueName = _venueControllers[i].text.trim();
      widget.events[i].address = _addressControllers[i].text.trim();
      widget.events[i].mapUrl = _mapControllers[i].text.trim();
    }
    widget.onSave(widget.events);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('સ્થળ અને Google Maps લિંક્સ સાચવી લેવાઈ છે.'),
      ),
    );
  }
}
