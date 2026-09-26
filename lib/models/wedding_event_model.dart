class WeddingEventModel {
  final String id;
  final String titleGujarati;
  final String englishSubtitle;
  final String dateText;
  final String timeText;
  String venueName;
  String address;
  String mapUrl;

  WeddingEventModel({
    required this.id,
    required this.titleGujarati,
    required this.englishSubtitle,
    required this.dateText,
    required this.timeText,
    required this.venueName,
    required this.address,
    required this.mapUrl,
  });

  static List<WeddingEventModel> getDefaultEvents() {
    return [
      WeddingEventModel(
        id: 'mandap',
        titleGujarati: 'માંડવ મુહૂર્ત',
        englishSubtitle: 'Mandap Muhurat',
        dateText: '૨૫ જાન્યુઆરી',
        timeText: 'બપોરે ૩:૦૦ કલાકે',
        venueName: 'ઝાલાવડીયા નિવાસ (આંગણે)',
        address: 'શ્રીજી કૃપા સોસાયટી, મહુવા / સુરત',
        mapUrl: 'https://maps.google.com/?q=Surat',
      ),
      WeddingEventModel(
        id: 'garba',
        titleGujarati: 'રાસ-ગરબા & ડીજે નાઇટ',
        englishSubtitle: 'Ras Garba & Sangeet',
        dateText: '૨૫ જાન્યુઆરી',
        timeText: 'રાત્રે ૮:૦૦ કલાકે',
        venueName: 'ઉમિયા પાર્ટી પ્લોટ',
        address: 'વી.આઈ.પી. રોડ, મહુવા / સુરત',
        mapUrl: 'https://maps.google.com/?q=Surat+Party+Plot',
      ),
      WeddingEventModel(
        id: 'haldi',
        titleGujarati: 'પીઠી / હળદર રસમ',
        englishSubtitle: 'Haldi Ceremony',
        dateText: '૨૬ જાન્યુઆરી',
        timeText: 'સવારે ૯:૦૦ કલાકે',
        venueName: 'ઝાલાવડીયા નિવાસ (આંગણે)',
        address: 'શ્રીજી કૃપા સોસાયટી',
        mapUrl: 'https://maps.google.com/?q=Surat',
      ),
      WeddingEventModel(
        id: 'jaan',
        titleGujarati: 'જાન પ્રસ્થાન',
        englishSubtitle: 'Jaan Prasthan / Departure',
        dateText: '૨૬ જાન્યુઆરી',
        timeText: 'સાંજે ૫:૦૦ કલાકે',
        venueName: 'ઝાલાવડીયા નિવાસથી પ્રસ્થાન',
        address: 'સર્વે જાનૈયાઓએ ૪:૩૦ સુધીમાં ઉપસ્થિત રહેવું',
        mapUrl: 'https://maps.google.com/?q=Surat',
      ),
      WeddingEventModel(
        id: 'lagna',
        titleGujarati: 'શુભ લગ્ન સમારોહ & પ્રીતિભોજન',
        englishSubtitle: 'Wedding Ceremony & Reception',
        dateText: '૨૬ જાન્યુઆરી',
        timeText: 'સાંજે ૭:૦૦ કલાકે',
        venueName: 'પાટીદાર ભવન / મંગલમ વાડી',
        address: 'મુખ્ય હોલ, અમદાવાદ / સુરત',
        mapUrl: 'https://maps.google.com/?q=Patidar+Bhavan',
      ),
    ];
  }
}
