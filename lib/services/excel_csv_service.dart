import 'package:csv/csv.dart';
import '../models/guest_model.dart';

class ExcelCsvService {
  /// Parses CSV string (with UTF-8 Gujarati characters) into a list of GuestModel
  static List<GuestModel> parseCsvString(String csvContent) {
    // Clean BOM if present
    String sanitized = csvContent.replaceAll('\uFEFF', '');
    final List<List<dynamic>> rows = const CsvToListConverter(
      shouldParseNumbers: false,
      allowInvalid: true,
      eol: '\n',
    ).convert(sanitized);

    if (rows.isEmpty) return [];

    // Header index detection
    final List<dynamic> headers = rows.first.map((h) => h.toString().trim().toLowerCase()).toList();
    
    int nameIdx = headers.indexWhere((h) => h.contains('નામ') || h.contains('name'));
    int phoneIdx = headers.indexWhere((h) => h.contains('મોબાઈલ') || h.contains('ફોન') || h.contains('phone') || h.contains('mobile'));
    int cityIdx = headers.indexWhere((h) => h.contains('ગામ') || h.contains('શહેર') || h.contains('city') || h.contains('village'));
    int typeIdx = headers.indexWhere((h) => h.contains('આમંત્રણ') || h.contains('પ્રકાર') || h.contains('type'));
    int mandapIdx = headers.indexWhere((h) => h.contains('માંડવ') || h.contains('mandap'));
    int garbaIdx = headers.indexWhere((h) => h.contains('ગરબા') || h.contains('garba') || h.contains('ડીજે'));
    int haldiIdx = headers.indexWhere((h) => h.contains('પીઠી') || h.contains('હળદર') || h.contains('haldi'));
    int jaanIdx = headers.indexWhere((h) => h.contains('જાન') || h.contains('jaan'));
    int lagnaIdx = headers.indexWhere((h) => h.contains('લગ્ન') || h.contains('lagna') || h.contains('marriage'));

    // Fallbacks if headers are generic
    if (nameIdx == -1) nameIdx = 0;
    if (phoneIdx == -1 && headers.length > 1) phoneIdx = 1;
    if (cityIdx == -1 && headers.length > 2) cityIdx = 2;
    if (typeIdx == -1 && headers.length > 3) typeIdx = 3;

    List<GuestModel> guests = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      String name = (nameIdx >= 0 && nameIdx < row.length) ? row[nameIdx].toString().trim() : '';
      if (name.isEmpty) continue;

      String phone = (phoneIdx >= 0 && phoneIdx < row.length) ? row[phoneIdx].toString().replaceAll(RegExp(r'[^0-9]'), '') : '';
      String city = (cityIdx >= 0 && cityIdx < row.length) ? row[cityIdx].toString().trim() : 'ગુજરાત';
      String type = (typeIdx >= 0 && typeIdx < row.length) ? row[typeIdx].toString().trim() : 'સપરિવાર';

      bool isYes(int idx) {
        if (idx < 0 || idx >= row.length) return true;
        final val = row[idx].toString().trim().toLowerCase();
        return val == 'હા' || val == 'yes' || val == 'true' || val == '1' || val == 'y';
      }

      guests.add(GuestModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_$i',
        name: name,
        phone: phone,
        city: city.isNotEmpty ? city : 'ગુજરાત',
        inviteType: type.isNotEmpty ? type : 'સપરિવાર',
        mandap: mandapIdx >= 0 ? isYes(mandapIdx) : true,
        garba: garbaIdx >= 0 ? isYes(garbaIdx) : true,
        haldi: haldiIdx >= 0 ? isYes(haldiIdx) : false,
        jaan: jaanIdx >= 0 ? isYes(jaanIdx) : true,
        lagna: lagnaIdx >= 0 ? isYes(lagnaIdx) : true,
        status: 'Pending',
      ));
    }

    return guests;
  }

  /// Exports guest list to CSV string with UTF-8 BOM so Excel opens it with Gujarati text correctly
  static String exportCsvString(List<GuestModel> guests) {
    List<List<dynamic>> rows = [
      [
        'મહેમાનનું નામ',
        'મોબાઈલ નંબર',
        'ગામ / શહેર',
        'આમંત્રણ પ્રકાર',
        'માંડવ મુહૂર્ત (૨૫મી)',
        'રાસ-ગરબા (૨૫મી)',
        'પીઠી / હળદર (૨૬મી)',
        'જાન પ્રસ્થાન (૨૬મી)',
        'લગ્ન સમારોહ (૨૬મી)',
        'સ્ટેટસ'
      ]
    ];

    for (var g in guests) {
      rows.add([
        g.name,
        g.phone,
        g.city,
        g.inviteType,
        g.mandap ? 'હા' : 'ના',
        g.garba ? 'હા' : 'ના',
        g.haldi ? 'હા' : 'ના',
        g.jaan ? 'હા' : 'ના',
        g.lagna ? 'હા' : 'ના',
        g.status
      ]);
    }

    // Prepend UTF-8 BOM for Microsoft Excel Windows compatibility
    return '\uFEFF${const ListToCsvConverter().convert(rows)}';
  }

  /// Generates sample Gujarati CSV content for the Zalavadiya family
  static String getSampleGujaratiCsv() {
    return '''\uFEFFમહેમાનનું નામ,મોબાઈલ નંબર,ગામ / શહેર,આમંત્રણ પ્રકાર,માંડવ મુહૂર્ત (૨૫મી),રાસ-ગરબા (૨૫મી),પીઠી / હળદર (૨૬મી),જાન પ્રસ્થાન (૨૬મી),લગ્ન સમારોહ (૨૬મી),સ્ટેટસ
રમેશભાઈ ગોવિંદભાઈ ઝાલાવડીયા,9825012345,સુરત,સપરિવાર,હા,હા,હા,હા,હા,Pending
હિતેશભાઈ વલ્લભભાઈ પટેલ,9426023456,રાજકોટ,બે વ્યક્તિ,ના,હા,ના,હા,હા,Pending
દિનેશભાઈ બાબુભાઈ કાકડિયા,9879034567,અમરેલી,સપરિવાર,હા,હા,ના,ના,હા,Pending
અલ્પેશભાઈ કેશવજીભાઈ મોરડીયા,9712045678,અમદાવાદ,૧ વ્યક્તિ,ના,ના,ના,ના,હા,Pending
પ્રવીણભાઈ નરશીભાઈ ઝાલાવડીયા,9898056789,મહુવા,સપરિવાર,હા,હા,હા,હા,હા,Pending
વિપુલભાઈ મનસુખભાઈ ધોળકિયા,9904067890,ભાવનગર,બે વ્યક્તિ,ના,હા,ના,ના,હા,Pending
જગદીશભાઈ રણછોડભાઈ સાવલિયા,9824078901,જુનાગઢ,સપરિવાર,ના,હા,ના,હા,હા,Pending
ભરતભાઈ હરિકૃષ્ણભાઈ પટેલ,9427089012,વડોદરા,૧ વ્યક્તિ,ના,ના,ના,ના,હા,Pending
કાંતિભાઈ શામજીભાઈ ઝાલાવડીયા,9825123456,અમદાવાદ,સપરિવાર,હા,હા,હા,હા,હા,Pending
મનસુખભાઈ રામજીભાઈ પટેલ,9428345678,સુરત,બે વ્યક્તિ,ના,હા,ના,હા,હા,Pending''';
  }
}
