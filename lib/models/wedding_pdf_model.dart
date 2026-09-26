import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WeddingPdfConfig {
  String saparivarUrl;
  String beVyaktiUrl;
  String ekVyaktiUrl;

  WeddingPdfConfig({
    required this.saparivarUrl,
    required this.beVyaktiUrl,
    required this.ekVyaktiUrl,
  });

  /// Default config with placeholders or cloud storage URLs
  factory WeddingPdfConfig.defaultConfig() {
    return WeddingPdfConfig(
      saparivarUrl: 'https://zalavadiya-wedding.web.app/pdf/kankotri_saparivar.pdf',
      beVyaktiUrl: 'https://zalavadiya-wedding.web.app/pdf/kankotri_be_vyakti.pdf',
      ekVyaktiUrl: 'https://zalavadiya-wedding.web.app/pdf/kankotri_ek_vyakti.pdf',
    );
  }

  /// Get specific PDF info by invitation type
  WeddingPdfInfo getInfoForType(String inviteType) {
    if (inviteType.contains('બે') || inviteType.contains('2')) {
      return WeddingPdfInfo(
        type: 'બે વ્યક્તિ',
        title: 'લગ્ન કંકોત્રી (બે વ્યક્તિ / Couple)',
        fileName: 'kankotri_be_vyakti.pdf',
        assetPath: 'assets/pdf/kankotri_be_vyakti.pdf',
        url: beVyaktiUrl,
        badgeColorHex: 0xFF2D6A4F,
        description: 'પતિ-પત્ની અથવા બે વ્યક્તિઓ માટેનું ખાસ નિમંત્રણ પત્ર',
      );
    } else if (inviteType.contains('૧') || inviteType.contains('1') || inviteType.contains('એક')) {
      return WeddingPdfInfo(
        type: '૧ વ્યક્તિ',
        title: 'લગ્ન કંકોત્રી (૧ વ્યક્તિ / Individual)',
        fileName: 'kankotri_ek_vyakti.pdf',
        assetPath: 'assets/pdf/kankotri_ek_vyakti.pdf',
        url: ekVyaktiUrl,
        badgeColorHex: 0xFF1D3557,
        description: 'એકલ વ્યક્તિ માટેનું ખાસ નિમંત્રણ પત્ર',
      );
    } else {
      // Default to સપરિવાર
      return WeddingPdfInfo(
        type: 'સપરિવાર',
        title: 'લગ્ન કંકોત્રી (સપરિવાર / Family)',
        fileName: 'kankotri_saparivar.pdf',
        assetPath: 'assets/pdf/kankotri_saparivar.pdf',
        url: saparivarUrl,
        badgeColorHex: 0xFF7A1C2E,
        description: 'સમગ્ર કુટુંબ-પરિવાર સાથે પધારવા માટેનું સસ્નેહ આમંત્રણ પત્ર',
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'saparivarUrl': saparivarUrl,
      'beVyaktiUrl': beVyaktiUrl,
      'ekVyaktiUrl': ekVyaktiUrl,
    };
  }

  factory WeddingPdfConfig.fromMap(Map<String, dynamic> map) {
    return WeddingPdfConfig(
      saparivarUrl: map['saparivarUrl'] ?? 'https://zalavadiya-wedding.web.app/pdf/kankotri_saparivar.pdf',
      beVyaktiUrl: map['beVyaktiUrl'] ?? 'https://zalavadiya-wedding.web.app/pdf/kankotri_be_vyakti.pdf',
      ekVyaktiUrl: map['ekVyaktiUrl'] ?? 'https://zalavadiya-wedding.web.app/pdf/kankotri_ek_vyakti.pdf',
    );
  }

  static const String _prefKey = 'zalavadiya_wedding_pdf_config';

  static Future<WeddingPdfConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return WeddingPdfConfig.fromMap(map);
      } catch (_) {}
    }
    return WeddingPdfConfig.defaultConfig();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(toMap()));
  }
}

class WeddingPdfInfo {
  final String type;
  final String title;
  final String fileName;
  final String assetPath;
  final String url;
  final int badgeColorHex;
  final String description;

  WeddingPdfInfo({
    required this.type,
    required this.title,
    required this.fileName,
    required this.assetPath,
    required this.url,
    required this.badgeColorHex,
    required this.description,
  });
}
