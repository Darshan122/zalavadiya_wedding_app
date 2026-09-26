import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guest_model.dart';

class GuestRepository extends ChangeNotifier {
  static const String _storageKey = 'zalavadiya_wedding_guests_v1';
  List<GuestModel> _guests = [];
  bool _isLoading = false;

  List<GuestModel> get guests => List.unmodifiable(_guests);
  bool get isLoading => _isLoading;

  int get totalCount => _guests.length;
  int get sentCount => _guests.where((g) => g.status == 'Sent').length;
  int get pendingCount => _guests.where((g) => g.status != 'Sent').length;
  int get familyCount => _guests.where((g) => g.inviteType == 'સપરિવાર').length;
  int get coupleCount => _guests.where((g) => g.inviteType == 'બે વ્યક્તિ').length;
  int get singleCount => _guests.where((g) => g.inviteType == '૧ વ્યક્તિ').length;

  GuestRepository() {
    loadGuests();
  }

  Future<void> loadGuests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        _guests = list.map((item) => GuestModel.fromJson(item)).toList();
      } else {
        // Seed default authentic Kathiawadi Leva Patel relatives
        _seedInitialGuests();
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('Error loading guests: $e');
      _seedInitialGuests();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _seedInitialGuests() {
    _guests = [
      GuestModel(
        id: '1',
        name: 'રમેશભાઈ ગોવિંદભાઈ ઝાલાવડીયા',
        phone: '9825012345',
        city: 'સુરત',
        inviteType: 'સપરિવાર',
        mandap: true,
        garba: true,
        haldi: true,
        jaan: true,
        lagna: true,
        status: 'Sent',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      GuestModel(
        id: '2',
        name: 'હિતેશભાઈ વલ્લભભાઈ પટેલ',
        phone: '9426023456',
        city: 'રાજકોટ',
        inviteType: 'બે વ્યક્તિ',
        mandap: false,
        garba: true,
        haldi: false,
        jaan: true,
        lagna: true,
        status: 'Pending',
      ),
      GuestModel(
        id: '3',
        name: 'દિનેશભાઈ બાબુભાઈ કાકડિયા',
        phone: '9879034567',
        city: 'અમરેલી',
        inviteType: 'સપરિવાર',
        mandap: true,
        garba: true,
        haldi: false,
        jaan: false,
        lagna: true,
        status: 'Pending',
      ),
      GuestModel(
        id: '4',
        name: 'અલ્પેશભાઈ કેશવજીભાઈ મોરડીયા',
        phone: '9712045678',
        city: 'અમદાવાદ',
        inviteType: '૧ વ્યક્તિ',
        mandap: false,
        garba: false,
        haldi: false,
        jaan: false,
        lagna: true,
        status: 'Pending',
      ),
      GuestModel(
        id: '5',
        name: 'પ્રવીણભાઈ નરશીભાઈ ઝાલાવડીયા',
        phone: '9898056789',
        city: 'મહુવા',
        inviteType: 'સપરિવાર',
        mandap: true,
        garba: true,
        haldi: true,
        jaan: true,
        lagna: true,
        status: 'Sent',
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      GuestModel(
        id: '6',
        name: 'વિપુલભાઈ મનસુખભાઈ ધોળકિયા',
        phone: '9904067890',
        city: 'ભાવનગર',
        inviteType: 'બે વ્યક્તિ',
        mandap: false,
        garba: true,
        haldi: false,
        jaan: false,
        lagna: true,
        status: 'Pending',
      ),
      GuestModel(
        id: '7',
        name: 'જગદીશભાઈ રણછોડભાઈ સાવલિયા',
        phone: '9824078901',
        city: 'જુનાગઢ',
        inviteType: 'સપરિવાર',
        mandap: false,
        garba: true,
        haldi: false,
        jaan: true,
        lagna: true,
        status: 'Pending',
      ),
      GuestModel(
        id: '8',
        name: 'ભરતભાઈ હરિકૃષ્ણભાઈ પટેલ',
        phone: '9427089012',
        city: 'વડોદરા',
        inviteType: '૧ વ્યક્તિ',
        mandap: false,
        garba: false,
        haldi: false,
        jaan: false,
        lagna: true,
        status: 'Pending',
      ),
    ];
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _guests.map((g) => g.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  // --- CRUD Operations ---

  Future<void> addGuest(GuestModel guest) async {
    _guests.insert(0, guest);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> updateGuest(GuestModel updatedGuest) async {
    final idx = _guests.indexWhere((g) => g.id == updatedGuest.id);
    if (idx != -1) {
      _guests[idx] = updatedGuest;
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteGuest(String id) async {
    _guests.removeWhere((g) => g.id == id);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> toggleStatus(String id) async {
    final idx = _guests.indexWhere((g) => g.id == id);
    if (idx != -1) {
      final current = _guests[idx];
      final newStatus = current.status == 'Sent' ? 'Pending' : 'Sent';
      _guests[idx] = current.copyWith(
        status: newStatus,
        sentAt: newStatus == 'Sent' ? DateTime.now() : null,
      );
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> markGuestSent(String id) async {
    final idx = _guests.indexWhere((g) => g.id == id);
    if (idx != -1) {
      _guests[idx] = _guests[idx].copyWith(
        status: 'Sent',
        sentAt: DateTime.now(),
      );
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> importGuests(List<GuestModel> newGuests, {bool replace = false}) async {
    if (replace) {
      _guests = List.from(newGuests);
    } else {
      // Append unique by phone or name
      final existingPhones = _guests.map((g) => g.phone).toSet();
      for (var g in newGuests) {
        if (!existingPhones.contains(g.phone) || g.phone.isEmpty) {
          _guests.add(g);
        }
      }
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _guests.clear();
    await _saveToStorage();
    notifyListeners();
  }
}
