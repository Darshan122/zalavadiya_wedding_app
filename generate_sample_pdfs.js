const fs = require('fs');
const path = require('path');

// Function to generate a simple valid PDF 1.4 with text
function createPdfBuffer(title, typeText, groom, bride, family) {
  const content = `BT
/F1 22 Tf
50 720 Td
(${title}) Tj
/F1 16 Tf
0 -40 Td
(${family}) Tj
/F1 18 Tf
0 -35 Td
(${groom} Weds ${bride}) Tj
/F1 14 Tf
0 -40 Td
(Nimantran Prakar: ${typeText}) Tj
/F1 12 Tf
0 -30 Td
(Date: 25 & 26 January 2026) Tj
0 -25 Td
(Shree Ganeshay Namah) Tj
0 -25 Td
(Jay Shree Krishna - Saparivar Aamantran) Tj
0 -35 Td
(Venue: Zalavadiya Parivar, Ahmedabad / Mahuva) Tj
ET`;

  const streamLength = Buffer.byteLength(content, 'utf8');

  const pdf = `%PDF-1.4
1 0 obj
<<
  /Type /Catalog
  /Pages 2 0 R
>>
endobj
2 0 obj
<<
  /Type /Pages
  /Kids [3 0 R]
  /Count 1
>>
endobj
3 0 obj
<<
  /Type /Page
  /Parent 2 0 R
  /MediaBox [0 0 595 842]
  /Resources <<
    /Font <<
      /F1 4 0 R
    >>
  >>
  /Contents 5 0 R
>>
endobj
4 0 obj
<<
  /Type /Font
  /Subtype /Type1
  /BaseFont /Helvetica-Bold
>>
endobj
5 0 obj
<<
  /Length ${streamLength}
>>
stream
${content}
endstream
endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000262 00000 n 
0000000341 00000 n 
trailer
<<
  /Size 6
  /Root 1 0 R
>>
startxref
${420 + streamLength}
%%EOF`;

  return Buffer.from(pdf, 'utf8');
}

const pdfDir = path.join(__dirname, 'assets', 'pdf');
if (!fs.existsSync(pdfDir)) {
  fs.mkdirSync(pdfDir, { recursive: true });
}

// 1. Saparivar PDF
fs.writeFileSync(
  path.join(pdfDir, 'kankotri_saparivar.pdf'),
  createPdfBuffer('Lagna Kankotri - Saparivar', 'SAPARIVAR (With Family)', 'Darshan', 'Brijal', 'Zalavadiya Parivar')
);

// 2. Be Vyakti PDF
fs.writeFileSync(
  path.join(pdfDir, 'kankotri_be_vyakti.pdf'),
  createPdfBuffer('Lagna Kankotri - Be Vyakti', 'BE VYAKTI (2 Persons / Couple)', 'Darshan', 'Brijal', 'Zalavadiya Parivar')
);

// 3. Ek Vyakti PDF
fs.writeFileSync(
  path.join(pdfDir, 'kankotri_ek_vyakti.pdf'),
  createPdfBuffer('Lagna Kankotri - Ek Vyakti', 'EK VYAKTI (1 Person)', 'Darshan', 'Brijal', 'Zalavadiya Parivar')
);

console.log('Successfully generated 3 wedding invitation PDFs in assets/pdf/');
