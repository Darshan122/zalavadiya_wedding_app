import 'package:flutter/material.dart';
import '../models/guest_model.dart';
import '../theme/wedding_theme.dart';

class AddEditGuestDialog extends StatefulWidget {
  final GuestModel? existingGuest;
  final Function(GuestModel) onSave;

  const AddEditGuestDialog({
    super.key,
    this.existingGuest,
    required this.onSave,
  });

  @override
  State<AddEditGuestDialog> createState() => _AddEditGuestDialogState();
}

class _AddEditGuestDialogState extends State<AddEditGuestDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late String _inviteType;
  late bool _mandap;
  late bool _garba;
  late bool _haldi;
  late bool _jaan;
  late bool _lagna;

  @override
  void initState() {
    super.initState();
    final g = widget.existingGuest;
    _nameController = TextEditingController(text: g?.name ?? '');
    _phoneController = TextEditingController(text: g?.phone ?? '');
    _cityController = TextEditingController(text: g?.city ?? 'સુરત');
    _inviteType = g?.inviteType ?? 'સપરિવાર';
    _mandap = g?.mandap ?? true;
    _garba = g?.garba ?? true;
    _haldi = g?.haldi ?? false;
    _jaan = g?.jaan ?? true;
    _lagna = g?.lagna ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingGuest != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: WeddingTheme.maroonPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: WeddingTheme.maroonPrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEdit ? 'મહેમાનની વિગતમાં સુધારો કરો' : 'નવા મહેમાન ઉમેરો',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: WeddingTheme.maroonPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name field
                const Text('મહેમાનનું નામ (ગુજરાતીમાં)*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'દા.ત. રમેશભાઈ ગોવિંદભાઈ ઝાલાવડીયા',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 14),

                // Phone & City Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('મોબાઈલ નંબર*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '9825012345',
                              prefixIcon: Icon(Icons.phone_outlined, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ગામ / શહેર', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              hintText: 'દા.ત. સુરત / રાજકોટ',
                              prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Invite type dropdown
                const Text('આમંત્રણ પ્રકાર*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WeddingTheme.borderSubtle),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _inviteType,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'સપરિવાર', child: Text('👨‍👩‍👧‍👦 સપરિવાર (Full Family)')),
                        DropdownMenuItem(value: 'બે વ્યક્તિ', child: Text('👫 બે વ્યક્તિ (Couple)')),
                        DropdownMenuItem(value: '૧ વ્યક્તિ', child: Text('👤 ૧ વ્યક્તિ (Single)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _inviteType = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Ceremonies checklist
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WeddingTheme.ivoryBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WeddingTheme.borderSubtle),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'કયા કયા કાર્યક્રમમાં આમંત્રણ આપવું છે?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: WeddingTheme.maroonPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCheckbox('માંડવ મુહૂર્ત (૨૫ જાન્યુઆરી, ૩:૦૦ PM)', _mandap, (v) => setState(() => _mandap = v!)),
                      _buildCheckbox('રાસ-ગરબા & ડીજે (૨૫ જાન્યુઆરી, ૮:૦૦ PM)', _garba, (v) => setState(() => _garba = v!)),
                      _buildCheckbox('પીઠી / હળદર રસમ (૨૬ જાન્યુઆરી, ૯:૦૦ AM)', _haldi, (v) => setState(() => _haldi = v!)),
                      _buildCheckbox('જાન પ્રસ્થાન (૨૬ જાન્યુઆરી, ૫:૦૦ PM)', _jaan, (v) => setState(() => _jaan = v!)),
                      _buildCheckbox('શુભ લગ્ન સમારોહ (૨૬ જાન્યુઆરી, ૭:૦૦ PM)', _lagna, (v) => setState(() => _lagna = v!)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('રદ કરો', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(isEdit ? 'સાચવો (Save)' : 'ઉમેરો (Add)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              activeColor: WeddingTheme.maroonPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('કૃપા કરીને મહેમાનનું નામ અને મોબાઈલ નંબર લખો.')),
      );
      return;
    }

    final newGuest = GuestModel(
      id: widget.existingGuest?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'ગુજરાત',
      inviteType: _inviteType,
      mandap: _mandap,
      garba: _garba,
      haldi: _haldi,
      jaan: _jaan,
      lagna: _lagna,
      status: widget.existingGuest?.status ?? 'Pending',
    );

    widget.onSave(newGuest);
    Navigator.of(context).pop();
  }
}
