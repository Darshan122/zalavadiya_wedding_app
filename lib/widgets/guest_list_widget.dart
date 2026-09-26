import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/guest_model.dart';
import '../services/excel_csv_service.dart';
import '../services/guest_repository.dart';
import '../models/wedding_pdf_model.dart';
import '../theme/wedding_theme.dart';
import 'add_edit_guest_dialog.dart';
import 'batch_send_dialog.dart';

class GuestListWidget extends StatefulWidget {
  final GuestRepository repository;
  final Function(GuestModel) onSelectForPreview;
  final WeddingPdfConfig? pdfConfig;

  const GuestListWidget({
    super.key,
    required this.repository,
    required this.onSelectForPreview,
    this.pdfConfig,
  });

  @override
  State<GuestListWidget> createState() => _GuestListWidgetState();
}

class _GuestListWidgetState extends State<GuestListWidget> {
  String _searchQuery = '';
  String _eventFilter = 'all';
  bool _isTableView = false; // default to Pinterest Cards view

  @override
  Widget build(BuildContext context) {
    final allGuests = widget.repository.guests;
    final filtered = _getFilteredGuests(allGuests);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Responsive Toolbar
            _buildToolbar(isMobile),
            const SizedBox(height: 12),

            // Horizontal Filter Chips
            _buildFilterRow(allGuests),
            const SizedBox(height: 14),

            // View Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'મહેમાનો (${filtered.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: WeddingTheme.maroonPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: WeddingTheme.goldLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: WeddingTheme.goldBorder),
                      ),
                      child: Text(
                        _eventFilter == 'all' ? 'બધા' : _getFilterLabel(_eventFilter),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WeddingTheme.textSub),
                      ),
                    ),
                  ],
                ),
                if (!isMobile)
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Pinterest કાર્ડ્સ વ્યૂ',
                        icon: Icon(
                          Icons.grid_view_rounded,
                          color: !_isTableView ? WeddingTheme.maroonPrimary : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _isTableView = false),
                      ),
                      IconButton(
                        tooltip: 'કોમ્પેક્ટ ટેબલ વ્યૂ',
                        icon: Icon(
                          Icons.table_rows_rounded,
                          color: _isTableView ? WeddingTheme.maroonPrimary : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _isTableView = true),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Scrollable Content Area (Pinterest Cards or Table) - Zero Overflow Guaranteed!
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : (!isMobile && _isTableView)
                      ? _buildTableView(filtered)
                      : _buildCardListView(filtered, isMobile),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WeddingTheme.borderSubtle),
      ),
      child: isMobile
          ? Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'નામ, ગામ કે ફોનથી શોધો...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: WeddingTheme.textLight),
                    isDense: true,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WeddingTheme.palmGreen,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: _pickAndImportCsv,
                        icon: const Icon(Icons.file_upload_outlined, size: 16),
                        label: const Text('CSV અપલોડ', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WeddingTheme.maroonPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _openAddEditDialog(null),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('નવો મહેમાન', style: TextStyle(fontSize: 12)),

                      ),
                    ),
                  ],
                ),
              ],
            )
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'નામ, ગામ કે ફોનથી શોધો...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: WeddingTheme.textLight),
                      isDense: true,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: WeddingTheme.palmGreen),
                      onPressed: _pickAndImportCsv,
                      icon: const Icon(Icons.file_upload_outlined, size: 18),
                      label: const Text('CSV અપલોડ'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WeddingTheme.textSub,
                        side: const BorderSide(color: WeddingTheme.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _loadSampleData,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('સેમ્પલ ડેટા'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WeddingTheme.textSub,
                        side: const BorderSide(color: WeddingTheme.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _exportCsv,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('એક્સપોર્ટ CSV'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                      onPressed: _openBatchSendDialog,
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: const Text('ઓટોમેટિક મોકલો'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: WeddingTheme.maroonPrimary),
                      onPressed: () => _openAddEditDialog(null),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('નવો મહેમાન ઉમેરો'),
                    ),
                  ],
                ),
              ],
            ),

    );
  }

  Widget _buildFilterRow(List<GuestModel> allGuests) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('બધા (${allGuests.length})', 'all'),
          _buildFilterChip('માંડવ મુહૂર્ત (૨૫મી)', 'mandap'),
          _buildFilterChip('રાસ-ગરબા & ડીજે (૨૫મી)', 'garba'),
          _buildFilterChip('પીઠી રસમ (૨૬મી)', 'haldi'),
          _buildFilterChip('જાન પ્રસ્થાન (૨૬મી)', 'jaan'),
          _buildFilterChip('લગ્ન સમારોહ (૨૬મી)', 'lagna'),
          _buildFilterChip('સપરિવાર (${widget.repository.familyCount})', 'family'),
          _buildFilterChip('બે વ્યક્તિ (${widget.repository.coupleCount})', 'couple'),
          _buildFilterChip('બાકી (${widget.repository.pendingCount})', 'pending'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _eventFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _eventFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? WeddingTheme.maroonPrimary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? WeddingTheme.maroonPrimary : WeddingTheme.borderSubtle,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: WeddingTheme.maroonPrimary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : WeddingTheme.textSub,
            ),
          ),
        ),
      ),
    );
  }

  // --- Pinterest Wedding Cards View (Mobile & Responsive) ---
  Widget _buildCardListView(List<GuestModel> guests, bool isMobile) {
    if (isMobile) {
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: guests.length,
        separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
        itemBuilder: (ctx, idx) => _buildPinterestCard(guests[idx]),

      );
    }

    // Grid for tablet / desktop
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 220,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: guests.length,
      itemBuilder: (ctx, idx) => _buildPinterestCard(guests[idx]),
    );
  }

  Widget _buildPinterestCard(GuestModel guest) {
    final avatarChar = guest.name.isNotEmpty ? guest.name.characters.first : 'દ';
    final isSent = guest.status == 'Sent';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSent ? Colors.green.shade200 : WeddingTheme.borderSubtle,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Name + City + 3-Dot Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: WeddingTheme.goldLight,
                child: Text(
                  avatarChar,
                  style: const TextStyle(
                    color: WeddingTheme.maroonPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guest.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: WeddingTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: WeddingTheme.textLight),
                        const SizedBox(width: 2),
                        Text(
                          guest.city,
                          style: const TextStyle(fontSize: 11, color: WeddingTheme.textSub),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          guest.phone,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: WeddingTheme.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu Popup
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                onSelected: (val) {
                  if (val == 'edit') _openAddEditDialog(guest);
                  if (val == 'delete') _confirmDelete(guest);
                  if (val == 'status') widget.repository.toggleStatus(guest.id);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'status',
                    child: Text(isSent ? 'સ્ટેટસ બાકી કરો' : 'સ્ટેટસ મોકલાઈ ગયું કરો'),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('વિગત સુધારો')),
                  const PopupMenuItem(value: 'delete', child: Text('ડિલીટ કરો', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Second Row: Invite Type & Ceremonies Badges
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: guest.inviteType == 'સપરિવાર'
                      ? WeddingTheme.goldLight
                      : (guest.inviteType == 'બે વ્યક્તિ' ? Colors.blue.shade50 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: guest.inviteType == 'સપરિવાર'
                        ? WeddingTheme.goldBorder
                        : (guest.inviteType == 'બે વ્યક્તિ' ? Colors.blue.shade200 : Colors.grey.shade300),
                  ),
                ),
                child: Text(
                  guest.inviteType,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: guest.inviteType == 'સપરિવાર'
                        ? WeddingTheme.maroonPrimary
                        : (guest.inviteType == 'બે વ્યક્તિ' ? Colors.blue.shade800 : WeddingTheme.textSub),
                  ),
                ),
              ),
              if (guest.mandap) _buildCeremonyTag('માંડવ', Colors.amber.shade50, Colors.amber.shade900),
              if (guest.garba)  _buildCeremonyTag('ગરબા', Colors.purple.shade50, Colors.purple.shade800),
              if (guest.haldi)  _buildCeremonyTag('પીઠી', Colors.yellow.shade100, Colors.orange.shade900),
              if (guest.jaan)   _buildCeremonyTag('જાન', Colors.cyan.shade50, Colors.cyan.shade900),
              if (guest.lagna)  _buildCeremonyTag('લગ્ન', WeddingTheme.maroonLight, WeddingTheme.maroonPrimary),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom Action Row
          const Divider(height: 14, color: WeddingTheme.borderSubtle),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Indicator
              InkWell(
                onTap: () => widget.repository.toggleStatus(guest.id),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSent ? Colors.green.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSent ? Colors.green.shade300 : Colors.amber.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSent ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        size: 13,
                        color: isSent ? Colors.green.shade700 : Colors.amber.shade900,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSent ? 'મોકલાઈ ગયું' : 'બાકી',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isSent ? Colors.green.shade700 : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // WhatsApp One-Click Direct Send
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  widget.onSelectForPreview(guest);
                },
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text('WhatsApp', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCeremonyTag(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  // --- Desktop Table View ---
  Widget _buildTableView(List<GuestModel> guests) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WeddingTheme.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 22,
                horizontalMargin: 16,
                headingRowColor: WidgetStateProperty.all(WeddingTheme.ivoryBg),
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('મહેમાનનું નામ', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('મોબાઈલ', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ગામ/શહેર', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('પ્રકાર', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('માંડવ', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ગરબા', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('પીઠી', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('જાન', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('લગ્ન', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('સ્ટેટસ', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('એક્શન', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: guests.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final g = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('$idx', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                      DataCell(Text(g.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      DataCell(Text(g.phone, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                      DataCell(Text(g.city, style: const TextStyle(fontSize: 12))),
                      DataCell(Text(g.inviteType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      DataCell(Text(g.mandap ? '✅' : '—')),
                      DataCell(Text(g.garba ? '✅' : '—')),
                      DataCell(Text(g.haldi ? '✅' : '—')),
                      DataCell(Text(g.jaan ? '✅' : '—')),
                      DataCell(Text(g.lagna ? '✅' : '—')),
                      DataCell(
                        InkWell(
                          onTap: () => widget.repository.toggleStatus(g.id),
                          child: Text(
                            g.status == 'Sent' ? '✓ મોકલાઈ ગયું' : '⌛ બાકી',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: g.status == 'Sent' ? Colors.green.shade800 : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.send_rounded, color: Colors.green, size: 16),
                              onPressed: () => widget.onSelectForPreview(g),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 16),
                              onPressed: () => _openAddEditDialog(g),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
                              onPressed: () => _confirmDelete(g),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline_rounded, size: 48, color: WeddingTheme.textLight),
          const SizedBox(height: 12),
          const Text('કોઈ મહેમાન મળ્યા નથી.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('શોધ શબ્દ બદલી જુઓ અથવા નવો મહેમાન ઉમેરો.', style: TextStyle(color: WeddingTheme.textSub, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              _searchQuery = '';
              _eventFilter = 'all';
            }),
            child: const Text('બધા મહેમાનો બતાવો'),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(String val) {
    switch (val) {
      case 'mandap': return 'માંડવ મુહૂર્ત';
      case 'garba': return 'રાસ-ગરબા';
      case 'haldi': return 'પીઠી રસમ';
      case 'jaan': return 'જાન પ્રસ્થાન';
      case 'lagna': return 'લગ્ન સમારોહ';
      case 'family': return 'સપરિવાર';
      case 'couple': return 'બે વ્યક્તિ';
      case 'pending': return 'બાકી';
      default: return 'બધા';
    }
  }

  List<GuestModel> _getFilteredGuests(List<GuestModel> guests) {
    return guests.where((g) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = g.name.toLowerCase().contains(q) ||
            g.city.toLowerCase().contains(q) ||
            g.phone.contains(q);
        if (!match) return false;
      }

      switch (_eventFilter) {
        case 'mandap': return g.mandap;
        case 'garba': return g.garba;
        case 'haldi': return g.haldi;
        case 'jaan': return g.jaan;
        case 'lagna': return g.lagna;
        case 'family': return g.inviteType == 'સપરિવાર';
        case 'couple': return g.inviteType == 'બે વ્યક્તિ';
        case 'pending': return g.status != 'Sent';
        default: return true;
      }
    }).toList();
  }

  void _openBatchSendDialog() {
    showDialog(
      context: context,
      builder: (ctx) => BatchSendDialog(
        repository: widget.repository,
        pdfConfig: widget.pdfConfig,
      ),
    );
  }

  void _openAddEditDialog(GuestModel? guest) {

    showDialog(
      context: context,
      builder: (ctx) => AddEditGuestDialog(
        existingGuest: guest,
        onSave: (saved) {
          if (guest == null) {
            widget.repository.addGuest(saved);
          } else {
            widget.repository.updateGuest(saved);
          }
        },
      ),
    );
  }

  void _confirmDelete(GuestModel guest) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('મહેમાન ડિલીટ કરો?'),
        content: Text('શું તમે ખરેખર "${guest.name}" ને યાદીમાંથી દૂર કરવા માંગો છો?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ના')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              widget.repository.deleteGuest(guest.id);
              Navigator.pop(ctx);
            },
            child: const Text('હા, ડિલીટ કરો'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndImportCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final bytes = result.files.first.bytes;
        if (bytes != null) {
          final content = utf8.decode(bytes);
          final parsed = ExcelCsvService.parseCsvString(content);
          if (parsed.isNotEmpty) {
            await widget.repository.importGuests(parsed);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green.shade800,
                  content: Text('સફળતા! ${parsed.length} મહેમાનો ઉમેરાઈ ગયા.'),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ફાઈલ વાંચવામાં ભૂલ: $e')),
        );
      }
    }
  }

  void _loadSampleData() {
    final sample = ExcelCsvService.getSampleGujaratiCsv();
    final parsed = ExcelCsvService.parseCsvString(sample);
    widget.repository.importGuests(parsed, replace: true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('૧૫ કાઠિયાવાડી લેવા પટેલ મહેમાનોની યાદી લોડ થઈ ગઈ.')),
    );
  }

  void _exportCsv() {
    final csvStr = ExcelCsvService.exportCsvString(widget.repository.guests);
    Clipboard.setData(ClipboardData(text: csvStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV ડેટા ક્લિપબોર્ડમાં કોપી થઈ ગયો!')),
    );
  }
}
