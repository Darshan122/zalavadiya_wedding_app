import 'package:url_launcher/url_launcher.dart';
import '../models/guest_model.dart';
import '../models/wedding_event_model.dart';
import '../models/wedding_pdf_model.dart';

class WhatsAppService {
  static const String groomName = 'દર્શન';
  static const String brideName = 'બ્રિજળ';
  static const String familyName = 'ઝાલાવડીયા પરિવાર';
  static const String community = 'લેવા પટેલ (Leva Patel)';
  static const String origin = 'Mahuva ♾️ Ahmedabad';

  /// Default message templates in pure Gujarati
  static const Map<String, String> defaultTemplates = {
    'kankotri': '''✨ શ્રી ગણેશાય નમઃ ✨

સ્નેહીશ્રી {નામ} ({ગામ})

સસ્નેહ જય શ્રી કૃષ્ણ.
અતિ હર્ષ અને આનંદ સાથે જણાવવાનું કે અમારા સુપુત્ર ચિ. દર્શન ના શુભ લગ્ન ચિ. બ્રિજળ સાથે નિર્ધારિત થયેલ છે.

આ માંગલિક અવસરે આપ શ્રી {આમંત્રણ_પ્રકાર} પધારી નવદંપતીને અંતઃકરણપૂર્વકના સ્નેહાશિષ પાઠવી અમારા આંગણની શોભા વધારશો એ જ ભાવભર્યું નિમંત્રણ.

આપના માટે આમંત્રિત કાર્યક્રમો:
{ઈવેન્ટ_યાદી}

📄 આપનું કંકોત્રી નિમંત્રણ કાર્ડ ({આમંત્રણ_પ્રકાર}):
👉 {કંકોત્રી_પીડીએફ_લિંક}

મુખ્ય સ્થળ: {મુખ્ય_સ્થળ}
ગૂગલ મેપ્સ લિંક: {સ્થળ_મેપ}

નિમંત્રક:
ઝાલાવડીયા પરિવાર (Leva Patel)
દર્શન weds બ્રિજળ''',

    'mandap_rem': '''જય શ્રી કૃષ્ણ {નામ} જી,

આજે ૨૫ જાન્યુઆરી બપોરે ૩:૦૦ કલાકે ચિ. દર્શન ના "માંડવ મુહૂર્ત" ની મંગલ વિધિ છે. 
આપ શ્રી {આમંત્રણ_પ્રકાર} સમયસર પધારી મુહૂર્તમાં સહભાગી થશો એવી નમ્ર વિનંતી.

સ્થળ: {સ્થળ_માંડવ}
લોકેશન લિંક: {મેપ_માંડવ}

- ઝાલાવડીયા પરિવાર''',

    'garba_rem': '''જય શ્રી કૃષ્ણ {નામ} જી,

આજે ૨૫ જાન્યુઆરી રાત્રે ૮:૦૦ કલાકે દર્શન & બ્રિજળ ના લગ્નોત્સવ નિમિત્તે "રાસ-ગરબા & ડીજે નાઇટ" નું ભવ્ય આયોજન કરેલ છે. 
આપ શ્રી {આમંત્રણ_પ્રકાર} રાસની રમઝટ માણવા અચૂક પધારશો.

સ્થળ: {સ્થળ_ગરબા}
લોકેશન લિંક: {મેપ_ગરબા}

- ઝાલાવડીયા પરિવાર''',

    'haldi_rem': '''જય શ્રી કૃષ્ણ {નામ} જી,

આજે ૨૬ જાન્યુઆરી સવારે ૯:૦૦ કલાકે ચિ. દર્શન ની "પીઠી / હળદર રસમ" રાખેલ છે. 
આપ શ્રી {આમંત્રણ_પ્રકાર} પધારી સ્નેહભાવ દર્શાવશો એવી વિનંતી.

સ્થળ: {સ્થળ_પીઠી}
લોકેશન લિંક: {મેપ_પીઠી}

- ઝાલાવડીયા પરિવાર''',

    'jaan_rem': '''જય શ્રી કૃષ્ણ {નામ} જી,

આજે ૨૬ જાન્યુઆરી સાંજે ૫:૦૦ કલાકે "જાન પ્રસ્થાન" નો સમય નક્કી કરેલ છે. સર્વે જાનૈયાઓએ ૪:૩૦ વાગ્યા સુધીમાં પહોંચી જવા વિનંતી.

સ્થળ: {સ્થળ_જાન}
- ઝાલાવડીયા પરિવાર''',

    'lagna_rem': '''જય શ્રી કૃષ્ણ {નામ} જી,

આજે ૨૬ જાન્યુઆરી સાંજે ૭:૦૦ કલાકે દર્શન weds બ્રિજળ નો "શુભ લગ્ન સમારોહ & પ્રીતિભોજન" રાખેલ છે. 
આપ શ્રી {આમંત્રણ_પ્રકાર} સમયસર પધારી ભોજન પ્રસાદ લઈ વર-કન્યાને આશીર્વાદ આપશો.

સ્થળ: {સ્થળ_લગ્ન}
લોકેશન લિંક: {મેપ_લગ્ન}

- ઝાલાવડીયા પરિવાર''',

    'custom_alert': '''જય શ્રી કૃષ્ણ {નામ} જી,

દર્શન & બ્રિજળ ના લગ્ન સમારોહ અંગે ખાસ સૂચના:
[અહીં તમારી જરૂરી વિગત લખો]

- ઝાલાવડીયા પરિવાર''',
  };

  /// Constructs personalized message for a guest
  static String buildMessage({
    required GuestModel guest,
    required String templateKey,
    String? customTemplateText,
    List<WeddingEventModel>? events,
    WeddingPdfConfig? pdfConfig,
  }) {
    String raw = customTemplateText ?? defaultTemplates[templateKey] ?? defaultTemplates['kankotri']!;
    final evs = events ?? WeddingEventModel.getDefaultEvents();
    final pdf = pdfConfig ?? WeddingPdfConfig.defaultConfig();
    final pdfInfo = pdf.getInfoForType(guest.inviteType);

    WeddingEventModel? eMandap = evs.firstWhere((e) => e.id == 'mandap', orElse: () => evs[0]);
    WeddingEventModel? eGarba = evs.firstWhere((e) => e.id == 'garba', orElse: () => evs[1]);
    WeddingEventModel? eHaldi = evs.firstWhere((e) => e.id == 'haldi', orElse: () => evs[2]);
    WeddingEventModel? eJaan = evs.firstWhere((e) => e.id == 'jaan', orElse: () => evs[3]);
    WeddingEventModel? eLagna = evs.firstWhere((e) => e.id == 'lagna', orElse: () => evs[4]);

    List<String> eventLines = [];
    if (guest.mandap) eventLines.add('• ${eMandap.dateText} (${eMandap.timeText}): ${eMandap.titleGujarati}');
    if (guest.garba)  eventLines.add('• ${eGarba.dateText} (${eGarba.timeText}): ${eGarba.titleGujarati}');
    if (guest.haldi)  eventLines.add('• ${eHaldi.dateText} (${eHaldi.timeText}): ${eHaldi.titleGujarati}');
    if (guest.jaan)   eventLines.add('• ${eJaan.dateText} (${eJaan.timeText}): ${eJaan.titleGujarati}');
    if (guest.lagna)  eventLines.add('• ${eLagna.dateText} (${eLagna.timeText}): ${eLagna.titleGujarati}');

    String eventListStr = eventLines.isNotEmpty
        ? eventLines.join('\n')
        : '• શુભ લગ્ન મહોત્સવ દર્શન weds બ્રિજળ';

    return raw
        .replaceAll('{નામ}', guest.name)
        .replaceAll('{ગામ}', guest.city)
        .replaceAll('{આમંત્રણ_પ્રકાર}', guest.inviteType)
        .replaceAll('{ઈવેન્ટ_યાદી}', eventListStr)
        .replaceAll('{કંકોત્રી_પીડીએફ_લિંક}', pdfInfo.url)
        .replaceAll('{પીડીએફ_ફાઈલ}', pdfInfo.fileName)
        .replaceAll('{મુખ્ય_સ્થળ}', '${eLagna.venueName}, ${eLagna.address}')
        .replaceAll('{સ્થળ_મેપ}', eLagna.mapUrl)
        .replaceAll('{સ્થળ_માંડવ}', '${eMandap.venueName}, ${eMandap.address}')
        .replaceAll('{મેપ_માંડવ}', eMandap.mapUrl)
        .replaceAll('{સ્થળ_ગરબા}', '${eGarba.venueName}, ${eGarba.address}')
        .replaceAll('{મેપ_ગરબા}', eGarba.mapUrl)
        .replaceAll('{સ્થળ_પીઠી}', '${eHaldi.venueName}, ${eHaldi.address}')
        .replaceAll('{મેપ_પીઠી}', eHaldi.mapUrl)
        .replaceAll('{સ્થળ_જાન}', eJaan.venueName)
        .replaceAll('{સ્થળ_લગ્ન}', '${eLagna.venueName}, ${eLagna.address}')
        .replaceAll('{મેપ_લગ્ન}', eLagna.mapUrl);
  }

  /// Launch WhatsApp directly with prefilled message
  static Future<bool> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }

    final encoded = Uri.encodeComponent(message);
    final urlString = 'https://wa.me/$cleanPhone?text=$encoded';
    final uri = Uri.parse(urlString);

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }
}
