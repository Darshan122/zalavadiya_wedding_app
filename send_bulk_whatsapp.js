/**
 * ============================================================================
 * શ્રી ગણેશાય નમઃ • ઝાલાવડીયા પરિવાર (Leva Patel)
 * દર્શન weds બ્રિજળ - લગ્ન કંકોત્રી ઓટોમેશન સ્ક્રિપ્ટ (WhatsApp Bulk Sender with PDF)
 * ============================================================================
 * 
 * ✨ વિશેષતાઓ (Features):
 * 1. ૧૦૦% ફ્રી અને ઓપન સોર્સ (ઝીરો ખર્ચ, કોઈ પેઇડ Meta API વગર).
 * 2. ૩ પ્રકારની PDF કંકોત્રી સપોર્ટ:
 *    - 'સપરિવાર' -> assets/pdf/kankotri_saparivar.pdf
 *    - 'બે વ્યક્તિ' -> assets/pdf/kankotri_be_vyakti.pdf
 *    - '૧ વ્યક્તિ' -> assets/pdf/kankotri_ek_vyakti.pdf
 * 3. સાચી PDF ફાઈલ સીધી જ અટેચમેન્ટ ડોક્યુમેન્ટ તરીકે વોટ્સએપ પર જશે!
 * 4. ગુજરાતી ટેક્સ્ટ મેસેજ PDF કેપ્શન તરીકે મોકલાશે.
 * 5. Anti-Ban સેફ્ટી: 10 થી 14 સેકન્ડનો રેન્ડમ ડિલે જેથી નંબર બ્લોક ન થાય.
 * 6. ડુપ્લિકેશન રોકવા માટે 'sent_history.json' માં લોગ સેવ થશે.
 * 
 * ----------------------------------------------------------------------------
 * 🚀 શરૂ કરવાના સંપૂર્ણ સ્ટેપ્સ (Full Setup Steps):
 * ----------------------------------------------------------------------------
 * સ્ટેપ ૧: પ્રોજેક્ટ ફોલ્ડરમાં જરૂરી પેકેજ ઇન્સ્ટોલ કરો:
 *    npm install @whiskeysockets/baileys qrcode-terminal
 * 
 * સ્ટેપ ૨: આ સ્ક્રિપ્ટ રન કરો:
 *    node send_bulk_whatsapp.js
 * 
 * સ્ટેપ ૩: કન્સોલ / ટર્મિનલમાં QR કોડ આવશે. તમારા ફોનના WhatsApp માં જઈને:
 *    Settings > Linked Devices > Link a Device પર ક્લિક કરી QR કોડ સ્કેન કરો.
 * 
 * સ્ટેપ ૪: સ્ક્રિપ્ટ આપોઆપ CSV ફાઈલ વાંચીને દરેક મહેમાનને તેમની કંકોત્રી PDF
 *    સાથે મેસેજ મોકલવાનું શરૂ કરી દેશે!
 * ============================================================================
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Config paths
const CSV_FILE = path.join(__dirname, 'sample_gujarati_guests.csv');
const HISTORY_FILE = path.join(__dirname, 'sent_history.json');
const PDF_DIR = path.join(__dirname, 'assets', 'pdf');

const PDF_MAP = {
  'સપરિવાર': path.join(PDF_DIR, 'kankotri_saparivar.pdf'),
  'બે વ્યક્તિ': path.join(PDF_DIR, 'kankotri_be_vyakti.pdf'),
  '૧ વ્યક્તિ': path.join(PDF_DIR, 'kankotri_ek_vyakti.pdf'),
};

// Sleep helper
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Load sent history
function loadHistory() {
  if (fs.existsSync(HISTORY_FILE)) {
    try {
      return JSON.parse(fs.readFileSync(HISTORY_FILE, 'utf8'));
    } catch (e) {
      return {};
    }
  }
  return {};
}

// Save sent history
function recordSent(phone, name, inviteType, pdfFile) {
  const history = loadHistory();
  history[phone] = {
    name,
    inviteType,
    pdfFile,
    sentAt: new Date().toISOString(),
  };
  fs.writeFileSync(HISTORY_FILE, JSON.stringify(history, null, 2), 'utf8');
}

// Parse CSV manually with UTF-8 support
function parseGuestsCSV(filePath) {
  if (!fs.existsSync(filePath)) {
    console.error(`❌ ભૂલ: CSV ફાઈલ મળી નથી: ${filePath}`);
    return [];
  }
  let content = fs.readFileSync(filePath, 'utf8');
  // Strip UTF-8 BOM if present
  if (content.charCodeAt(0) === 0xFEFF) {
    content = content.slice(1);
  }
  const lines = content.split(/\r?\n/).filter((l) => l.trim().length > 0);
  if (lines.length < 2) return [];

  const headers = lines[0].split(',').map((h) => h.trim());
  const guests = [];

  for (let i = 1; i < lines.length; i++) {
    const cols = lines[i].split(',').map((c) => c.trim());
    if (cols.length < 2) continue;

    const row = {};
    headers.forEach((h, idx) => {
      row[h] = cols[idx] || '';
    });

    guests.push({
      name: row['મહેમાનનું નામ'] || row['નામ'] || row['Name'] || cols[0] || '',
      phone: row['મોબાઈલ નંબર'] || row['મોબાઈલ'] || row['Mobile'] || row['Phone'] || cols[1] || '',
      city: row['ગામ / શહેર'] || row['ગામ'] || row['શહેર'] || row['City'] || cols[2] || 'અમદાવાદ',
      inviteType: row['આમંત્રણ પ્રકાર'] || row['InviteType'] || cols[3] || 'સપરિવાર',
      mandap: (row['માંડવ મુહૂર્ત (૨૫મી)'] || row['માંડવ'] || cols[4] || 'હા') === 'હા',
      garba: (row['રાસ-ગરબા (૨૫મી)'] || row['ગરબા'] || cols[5] || 'હા') === 'હા',
      haldi: (row['પીઠી / હળદર (૨૬મી)'] || row['પીઠી'] || cols[6] || 'હા') === 'હા',
      jaan: (row['જાન પ્રસ્થાન (૨૬મી)'] || row['જાન'] || cols[7] || 'હા') === 'હા',
      lagna: (row['લગ્ન સમારોહ (૨૬મી)'] || row['લગ્ન'] || cols[8] || 'હા') === 'હા',
    });
  }
  return guests;
}

// Generate Personalized Gujarati Invitation Message
function generateGujaratiMessage(guest) {
  let eventLines = [];
  if (guest.mandap) eventLines.push('• ૨૫ જાન્યુઆરી (બપોરે ૩:૦૦): માંડવ મુહૂર્ત');
  if (guest.garba)  eventLines.push('• ૨૫ જાન્યુઆરી (રાત્રે ૮:૦૦): રાસ-ગરબા & ડીજે નાઇટ');
  if (guest.haldi)  eventLines.push('• ૨૬ જાન્યુઆરી (સવારે ૯:૦૦): પીઠી / હળદર રસમ');
  if (guest.jaan)   eventLines.push('• ૨૬ જાન્યુઆરી (સાંજે ૫:૦૦): જાન પ્રસ્થાન');
  if (guest.lagna)  eventLines.push('• ૨૬ જાન્યુઆરી (સાંજે ૭:૦૦): શુભ લગ્ન સમારોહ & પ્રીતિભોજન');

  const eventList = eventLines.length > 0 ? eventLines.join('\n') : '• શુભ લગ્ન મહોત્સવ દર્શન weds બ્રિજળ';

  return `✨ શ્રી ગણેશાય નમઃ ✨

સ્નેહીશ્રી ${guest.name} (${guest.city})

સસ્નેહ જય શ્રી કૃષ્ણ.
અતિ હર્ષ અને આનંદ સાથે જણાવવાનું કે અમારા સુપુત્ર ચિ. દર્શન ના શુભ લગ્ન ચિ. બ્રિજળ સાથે નિર્ધારિત થયેલ છે.

આ માંગલિક અવસરે આપ શ્રી ${guest.inviteType} પધારી નવદંપતીને અંતઃકરણપૂર્વકના સ્નેહાશિષ પાઠવી અમારા આંગણની શોભા વધારશો એ જ ભાવભર્યું નિમંત્રણ.

આપના માટે આમંત્રિત કાર્યક્રમો:
${eventList}

📄 સાથે આપનું કંકોત્રી નિમંત્રણ કાર્ડ (${guest.inviteType}) જોડેલ છે.

મુખ્ય સ્થળ: ખોડલધામ પાર્ટી પ્લોટ, નિકોલ - નરોડા રોડ, અમદાવાદ
ગૂગલ મેપ્સ લિંક: https://maps.google.com/?q=Nikol+Ahmedabad

નિમંત્રક:
ઝાલાવડીયા પરિવાર (Leva Patel)
દર્શન weds બ્રિજળ`;
}

// Select PDF for guest
function getPdfForGuest(inviteType) {
  if (inviteType.includes('બે') || inviteType.includes('2')) {
    return {
      type: 'બે વ્યક્તિ',
      fileName: 'kankotri_be_vyakti.pdf',
      filePath: PDF_MAP['બે વ્યક્તિ'],
    };
  } else if (inviteType.includes('૧') || inviteType.includes('1') || inviteType.includes('એક')) {
    return {
      type: '૧ વ્યક્તિ',
      fileName: 'kankotri_ek_vyakti.pdf',
      filePath: PDF_MAP['૧ વ્યક્તિ'],
    };
  } else {
    return {
      type: 'સપરિવાર',
      fileName: 'kankotri_saparivar.pdf',
      filePath: PDF_MAP['સપરિવાર'],
    };
  }
}

// Main execution logic
async function main() {
  console.clear();
  console.log('================================================================');
  console.log('       ✨ શ્રી ગણેશાય નમઃ • ઝાલાવડીયા પરિવાર ✨');
  console.log('         દર્શન weds બ્રિજળ - લગ્ન કંકોત્રી WhatsApp Bot');
  console.log('================================================================\n');

  // Verify PDF files exist
  console.log('📂 કંકોત્રી PDF ફાઈલ ચકાસણી:');
  for (const [key, p] of Object.entries(PDF_MAP)) {
    if (fs.existsSync(p)) {
      const stats = fs.statSync(p);
      console.log(`  ✅ [${key}]: ${path.basename(p)} (${(stats.size / 1024).toFixed(1)} KB)`);
    } else {
      console.log(`  ⚠️ ચેતવણી: ${p} મળ્યું નથી. 'node generate_sample_pdfs.js' રન કરો.`);
    }
  }
  console.log('');

  // Load guests
  const allGuests = parseGuestsCSV(CSV_FILE);
  if (allGuests.length === 0) {
    console.log(`❌ ${CSV_FILE} માં કોઈ મહેમાન મળ્યા નથી!`);
    return;
  }

  const history = loadHistory();
  const pendingGuests = allGuests.filter((g) => {
    const cleanPhone = g.phone.replace(/[^0-9]/g, '');
    return !history[cleanPhone] && !history[`91${cleanPhone}`];
  });

  console.log(`📊 મહેમાનોની સ્થિતિ:`);
  console.log(`  • કુલ મહેમાનો: ${allGuests.length}`);
  console.log(`  • અગાઉ મોકલાઈ ગયેલ: ${allGuests.length - pendingGuests.length}`);
  console.log(`  • બાકી મોકલવાના: ${pendingGuests.length}\n`);

  if (pendingGuests.length === 0) {
    console.log('🎉 બધા મહેમાનોને કંકોત્રી અગાઉ મોકલાઈ ગયેલ છે!');
    return;
  }

  // Check if Baileys is installed
  let makeWASocket, useMultiFileAuthState, DisconnectReason;
  let qrcode;
  try {
    const baileys = require('@whiskeysockets/baileys');
    makeWASocket = baileys.default || baileys.makeWASocket;
    useMultiFileAuthState = baileys.useMultiFileAuthState;
    DisconnectReason = baileys.DisconnectReason;
    qrcode = require('qrcode-terminal');
  } catch (err) {
    console.log('⚠️ @whiskeysockets/baileys અથવા qrcode-terminal ઇન્સ્ટોલ કરેલ નથી.');
    console.log('👉 નીચેનો કમાન્ડ રન કરો:');
    console.log('   npm install @whiskeysockets/baileys qrcode-terminal\n');
    console.log('----------------------------------------------------------------');
    console.log('💡 ડેમો મોડ (Simulator Mode) - પ્રિવ્યુ ચાલુ છે:');
    console.log('----------------------------------------------------------------');
    
    // Demonstrate how the PDF matching and message will work for first 3 guests
    for (let i = 0; i < Math.min(3, pendingGuests.length); i++) {
      const g = pendingGuests[i];
      const pdf = getPdfForGuest(g.inviteType);
      console.log(`\n[${i + 1}/${pendingGuests.length}] મોકલવાની વિગત:`);
      console.log(`  👤 મહેમાન: ${g.name} (${g.city})`);
      console.log(`  📱 મોબાઈલ: ${g.phone}`);
      console.log(`  🏷️ આમંત્રણ પ્રકાર: ${g.inviteType}`);
      console.log(`  📄 અટેચ થતી PDF ફાઈલ: ${pdf.fileName}`);
      console.log(`  ✉️ કેપ્શન મેસેજ: દર્શન weds બ્રિજળ શુભ લગ્ન નિમંત્રણ...`);
    }

    console.log('\n================================================================');
    console.log('તમારી Flutter એપમાં પણ "ઓટોમેટિક મોકલો" બટન ઉપલબ્ધ છે');
    console.log('જે સીધું બ્રાઉઝર/ફોનથી એક પછી એક WhatsApp ખોલીને મોકલે છે!');
    console.log('================================================================\n');
    return;
  }

  // Connect to WhatsApp via Baileys
  console.log('🔄 WhatsApp સાથે કનેક્ટ થઈ રહ્યું છે...');
  const authDir = path.join(__dirname, '.baileys_auth');
  const { state, saveCreds } = await useMultiFileAuthState(authDir);

  const sock = makeWASocket({
    auth: state,
    printQRInTerminal: true,
  });

  sock.ev.on('creds.update', saveCreds);

  sock.ev.on('connection.update', async (update) => {
    const { connection, lastDisconnect, qr } = update;
    if (qr) {
      console.log('\n📲 કૃપા કરીને નીચેનો QR કોડ તમારા WhatsApp માંથી Scan કરો:');
      qrcode.generate(qr, { small: true });
    }
    if (connection === 'close') {
      const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== DisconnectReason.loggedOut;
      console.log('⚠️ કનેક્શન ડિસ્કનેક્ટ થયું. રીકનેક્ટ થઈ રહ્યું છે:', shouldReconnect);
      if (shouldReconnect) main();
    } else if (connection === 'open') {
      console.log('\n✅ WhatsApp સફળતાપૂર્વક કનેક્ટ થઈ ગયું! 🚀');
      console.log('📤 કંકોત્રી PDF અને મેસેજ મોકલવાનું શરૂ થઈ રહ્યું છે...\n');

      for (let i = 0; i < pendingGuests.length; i++) {
        const guest = pendingGuests[i];
        let phone = guest.phone.replace(/[^0-9]/g, '');
        if (phone.length === 10) phone = `91${phone}`;
        const jid = `${phone}@s.whatsapp.net`;

        const pdf = getPdfForGuest(guest.inviteType);
        const captionMessage = generateGujaratiMessage(guest);

        console.log(`[${i + 1}/${pendingGuests.length}] મોકલાઈ રહ્યું છે -> ${guest.name} (${guest.inviteType}) [${guest.phone}]`);

        try {
          if (fs.existsSync(pdf.filePath)) {
            // Send actual PDF document with invitation caption
            await sock.sendMessage(jid, {
              document: fs.readFileSync(pdf.filePath),
              mimetype: 'application/pdf',
              fileName: `લગ્ન_કંકોત્રી_${guest.name.replace(/\s+/g, '_')}.pdf`,
              caption: captionMessage,
            });
            console.log(`  ✅ PDF અટેચમેન્ટ સાથે સફળતાપૂર્વક મોકલાઈ ગયું: ${pdf.fileName}`);
          } else {
            // Fallback to text message if PDF missing
            await sock.sendMessage(jid, { text: captionMessage });
            console.log(`  ✅ મેસેજ મોકલાઈ ગયો (PDF ફાઈલ મળી નથી)`);
          }

          recordSent(phone, guest.name, guest.inviteType, pdf.fileName);
        } catch (sendErr) {
          console.error(`  ❌ મોકલવામાં ભૂલ (${guest.name}):`, sendErr.message);
        }

        // Anti-ban delay: 10-14 seconds randomized
        if (i < pendingGuests.length - 1) {
          const delaySec = 10 + Math.floor(Math.random() * 5); // 10 to 14s
          console.log(`  ⏳ Anti-Ban સુરક્ષા માટે ${delaySec} સેકન્ડ રાહ જુઓ...\n`);
          await sleep(delaySec * 1000);
        }
      }

      console.log('\n🎉 અભિનંદન! તમામ બાકી મહેમાનોને કંકોત્રી PDF મોકલાઈ ગઈ છે! ✨');
    }
  });
}

main().catch((err) => console.error('Fatal Error:', err));
