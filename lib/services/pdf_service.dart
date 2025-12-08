import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/bill.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<File> createInvoicePdf(Bill bill) async {
    final pdf = pw.Document();
    final df = DateFormat('dd-MM-yyyy');

    // Calculate totals
    final totalQty = bill.items.fold(0, (sum, item) => sum + item.qty);
    final taxableValue = bill.subtotal;
    final totalCGST = bill.gstAmount;
    final totalSGST = bill.sgstAmount;
    final gstAt18 = totalCGST + totalSGST; // Combined GST at 18%
    final floodCess = bill.total * 0.01; // 1% of total
    final grandTotal = bill.total + floodCess;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - CASCO
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'CASCO',
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Accessories',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Near Arts College,Meenchanda | 9995606883',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // TAX INVOICE Title
              pw.Center(
                child: pw.Text(
                  'TAX INVOICE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),

              // Horizontal line under TAX INVOICE
              pw.Container(
                height: 1,
                color: PdfColors.black,
              ),
              pw.SizedBox(height: 12),

              // Invoice# and Date table (no borders, bold text)
              pw.Table(
                border: pw.TableBorder(
                  left: pw.BorderSide.none,
                  right: pw.BorderSide.none,
                  top: pw.BorderSide.none,
                  bottom: pw.BorderSide.none,
                  horizontalInside: pw.BorderSide.none,
                  verticalInside: pw.BorderSide.none,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Invoice#: ${bill.invoiceNumber}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Date: ${df.format(bill.date)}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // TO:
              pw.Text(
                'TO:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                bill.customerName.toUpperCase(),
                style: const pw.TextStyle(fontSize: 11),
              ),
              if (bill.whatsappNumber.isNotEmpty)
                pw.Text(
                  bill.whatsappNumber,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              pw.SizedBox(height: 15),

              // Main Items Table
              pw.Table(
                border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3.5), // Item
                  1: const pw.FlexColumnWidth(0.8), // Qty
                  2: const pw.FlexColumnWidth(1.0), // Rate
                  3: const pw.FlexColumnWidth(1.2), // Gross Value
                  4: const pw.FlexColumnWidth(0.8), // CGST %
                  5: const pw.FlexColumnWidth(1.2), // CGST Value
                  6: const pw.FlexColumnWidth(0.8), // SGST %
                  7: const pw.FlexColumnWidth(1.2), // SGST Value
                  8: const pw.FlexColumnWidth(1.3), // Net Amount
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    children: [
                      _buildHeaderCell('Item'),
                      _buildHeaderCell('Qty'),
                      _buildHeaderCell('Rate'),
                      _buildHeaderCell('Gross\nValue'),
                      _buildHeaderCell('CGST\n%'),
                      _buildHeaderCell('CGST\nValue'),
                      _buildHeaderCell('SGST\n%'),
                      _buildHeaderCell('SGST\nValue'),
                      _buildHeaderCell('Net\nAmount'),
                    ],
                  ),

                  // Item Rows
                  ...bill.items.map((item) {
                    final gross = item.qty * item.price;
                    final cgstVal = gross * (bill.gstPercent / 100);
                    final sgstVal = gross * (bill.sgstPercent / 100);
                    final net = gross + cgstVal + sgstVal;

                    return pw.TableRow(
                      children: [
                        _buildCell(item.name, align: pw.TextAlign.left),
                        _buildCell(item.qty.toString()),
                        _buildCell(item.price.toStringAsFixed(2)),
                        _buildCell(gross.toStringAsFixed(2)),
                        _buildCell('${bill.gstPercent.toStringAsFixed(0)}%'),
                        _buildCell(cgstVal.toStringAsFixed(2)),
                        _buildCell('${bill.sgstPercent.toStringAsFixed(0)}%'),
                        _buildCell(sgstVal.toStringAsFixed(2)),
                        _buildCell(net.toStringAsFixed(2)),
                      ],
                    );
                  }),

                  // Empty rows to fill space
                  ...List.generate(
                    8 - bill.items.length > 0 ? 8 - bill.items.length : 0,
                    (index) => pw.TableRow(
                      children: [
                        _buildCell(''),
                        _buildCell(''),
                        _buildCell(''),
                        _buildCell(''),
                        _buildCell(''),
                        _buildCell(''),
                        _buildCell(''),
                        _buildCell(''),
                        _buildCell(''),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),

              // Totals Table - Updated structure
              pw.Table(
                border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    children: [
                      _buildTotalHeaderCell(''),
                      _buildTotalHeaderCell('Qty'),
                      _buildTotalHeaderCell('Taxable'),
                      _buildTotalHeaderCell('CGST'),
                      _buildTotalHeaderCell('SGST'),
                    ],
                  ),
                  // Total row
                  pw.TableRow(
                    children: [
                      _buildTotalCell('Total', isLabel: true, isBold: true),
                      _buildTotalCell(totalQty.toString()),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                    ],
                  ),
                  // GST @ 18%
                  pw.TableRow(
                    children: [
                      _buildTotalCell('GST @ 18%', isLabel: true, isBold: true),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                    ],
                  ),
                  // Kerala Flood Cess
                  pw.TableRow(
                    children: [
                      _buildTotalCell('Kerala Flood Cess @1%',
                          isLabel: true, isBold: true),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                    ],
                  ),
                  // Grand Total
                  pw.TableRow(
                    children: [
                      _buildTotalCell('Grand Total',
                          isLabel: true, isBold: true),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                      _buildTotalCell(''),
                    ],
                  ),
                  // Amount in words
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'AMOUNT (IN WORDS):',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          '',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // Authorized Sign
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text(
                    'Authorized Sign ___________________',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_${bill.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Download PDF to Downloads folder
  Future<String> downloadInvoicePdf(Bill bill) async {
    try {
      // Generate PDF first
      final pdfFile = await createInvoicePdf(bill);
      final bytes = await pdfFile.readAsBytes();

      // Create file name with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName =
          'CASCO_Invoice_${bill.customerName.replaceAll(' ', '_')}_$timestamp.pdf';

      if (Platform.isAndroid) {
        // For Android, request appropriate permissions based on version
        final androidInfo = await _getAndroidVersion();

        if (androidInfo >= 33) {
          // Android 13+ doesn't need storage permissions for Downloads folder
          // We can write directly to app-specific external storage
          final directory = await getExternalStorageDirectory();
          if (directory == null) {
            throw Exception('Could not access external storage');
          }

          // Create Downloads folder in app-specific storage
          final downloadsPath = '${directory.path}/Downloads';
          final downloadsDir = Directory(downloadsPath);
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }

          final savedFile = File('$downloadsPath/$fileName');
          await savedFile.writeAsBytes(bytes);
          return savedFile.path;
        } else {
          // Android 12 and below - use traditional approach
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              // Try manageExternalStorage for Android 11+
              if (androidInfo >= 30) {
                status = await Permission.manageExternalStorage.request();
              }
              if (!status.isGranted) {
                throw Exception(
                    'Storage permission denied. Please grant storage permission in app settings.');
              }
            }
          }

          // Try to save to public Downloads folder
          Directory? downloadsDir;
          final publicDownloads = Directory('/storage/emulated/0/Download');

          if (await publicDownloads.exists()) {
            downloadsDir = publicDownloads;
          } else {
            // Fallback to app-specific external storage
            downloadsDir = await getExternalStorageDirectory();
            if (downloadsDir != null) {
              final customDownloads =
                  Directory('${downloadsDir.path}/Downloads');
              if (!await customDownloads.exists()) {
                await customDownloads.create(recursive: true);
              }
              downloadsDir = customDownloads;
            }
          }

          if (downloadsDir == null) {
            throw Exception('Could not access downloads directory');
          }

          final savedFile = File('${downloadsDir.path}/$fileName');
          await savedFile.writeAsBytes(bytes);
          return savedFile.path;
        }
      } else {
        // iOS/macOS - use app documents directory
        final directory = await getApplicationDocumentsDirectory();
        final savedFile = File('${directory.path}/$fileName');
        await savedFile.writeAsBytes(bytes);
        return savedFile.path;
      }
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }

  // Helper method to get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      // This is a simple approach - in production you might want to use
      // device_info_plus package for more accurate version detection
      final directory = await getExternalStorageDirectory();
      if (directory == null) return 30; // Assume modern Android

      // Try to access public downloads - if it fails, likely Android 13+
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await publicDownloads.exists()) {
        return 30; // Likely Android 11-12
      }
      return 33; // Likely Android 13+
    } catch (e) {
      return 33; // Default to modern Android
    }
  }

  pw.Widget _buildHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildCell(String text,
      {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      height: 30,
      child: pw.Align(
        alignment: align == pw.TextAlign.left
            ? pw.Alignment.centerLeft
            : pw.Alignment.center,
        child: pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 9),
          textAlign: align,
        ),
      ),
    );
  }

  pw.Widget _buildTotalHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTotalCell(String text,
      {bool isLabel = false, bool isBold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isLabel ? pw.TextAlign.left : pw.TextAlign.right,
      ),
    );
  }

  String _convertNumberToWords(double amount) {
    final int rupees = amount.floor();
    final int paise = ((amount - rupees) * 100).round();

    if (rupees == 0 && paise == 0) return 'Zero Rupees Only';

    String result = '';
    if (rupees > 0) {
      result = '${_numberToWords(rupees)} Rupees';
    }
    if (paise > 0) {
      result += ' and ${_numberToWords(paise)} Paise';
    }
    return '$result Only';
  }

  String _numberToWords(int number) {
    if (number == 0) return 'Zero';

    final ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine'
    ];
    final teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    if (number < 10) return ones[number];
    if (number < 20) return teens[number - 10];
    if (number < 100) {
      return '${tens[number ~/ 10]} ${ones[number % 10]}'.trim();
    }
    if (number < 1000) {
      return '${ones[number ~/ 100]} Hundred ${_numberToWords(number % 100)}'
          .trim();
    }
    if (number < 100000) {
      return '${_numberToWords(number ~/ 1000)} Thousand ${_numberToWords(number % 1000)}'
          .trim();
    }
    if (number < 10000000) {
      return '${_numberToWords(number ~/ 100000)} Lakh ${_numberToWords(number % 100000)}'
          .trim();
    }
    return '${_numberToWords(number ~/ 10000000)} Crore ${_numberToWords(number % 10000000)}'
        .trim();
  }
}
