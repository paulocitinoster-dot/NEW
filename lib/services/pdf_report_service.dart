import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class PdfReportService {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> generateAndShareReport({
    required String familyName,
    required DateTime monthYear,
    required List<TransactionModel> transactions,
  }) async {
    final pdf = pw.Document();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    final Map<String, double> categoryTotals = {};

    for (var tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        totalExpense += tx.amount;
        final catName = tx.notes ?? 'Geral';
        categoryTotals[catName] = (categoryTotals[catName] ?? 0.0) + tx.amount;
      }
    }

    final netResult = totalIncome - totalExpense;
    final periodName = DateFormat('MMMM / yyyy', 'pt_BR').format(monthYear).toUpperCase();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  cross: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DEMONSTRATIVO FINANCEIRO FAMILIAR',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Família: $familyName', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('Período de Apuração: $periodName', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
                pw.Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.blue900),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfKpi('Receitas (+)', currencyFormat.format(totalIncome), PdfColors.green700),
                  _pdfKpi('Despesas (-)', currencyFormat.format(totalExpense), PdfColors.red700),
                  _pdfKpi(
                    'Resultado Líquido (=)',
                    currencyFormat.format(netResult),
                    netResult >= 0 ? PdfColors.blue800 : PdfColors.orange800,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Análise Gráfica do Período',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              cross: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      cross: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Gastos por Categoria', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blue900)),
                        pw.SizedBox(height: 8),
                        if (categoryTotals.isEmpty)
                          pw.Text('Sem despesas registradas', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600))
                        else
                          ...categoryTotals.entries.map((entry) {
                            final percentage = totalExpense > 0 ? (entry.value / totalExpense) : 0.0;
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
                              child: pw.Column(
                                cross: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(entry.key, style: const pw.TextStyle(fontSize: 9)),
                                      pw.Text('${currencyFormat.format(entry.value)} (${(percentage * 100).toStringAsFixed(1)}%)', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                    ],
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.LinearProgressIndicator(value: percentage, backgroundColor: PdfColors.grey200, color: PdfColors.blue700, minHeight: 5),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      cross: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Equilíbrio Financeiro', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blue900)),
                        pw.SizedBox(height: 12),
                        _barComparison('Receita Total', totalIncome, totalIncome > 0 ? 1.0 : 0.0, PdfColors.green600),
                        pw.SizedBox(height: 10),
                        _barComparison('Despesa Total', totalExpense, totalIncome > 0 ? (totalExpense / totalIncome).clamp(0.0, 1.0) : 0.0, totalExpense > totalIncome ? PdfColors.red600 : PdfColors.orange600),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Lançamentos Analíticos', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: ['Data', 'Descrição', 'Tipo', 'Pagamento', 'Valor (R\$)'],
              data: transactions.map((tx) {
                final isIncome = tx.type == 'income';
                return [
                  dateFormat.format(tx.transactionDate),
                  tx.description,
                  isIncome ? 'Receita' : 'Despesa',
                  tx.paymentMethod,
                  '${isIncome ? "+" : "-"} ${currencyFormat.format(tx.amount)}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              alternateRowColor: PdfColors.grey50,
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey400),
            pw.Center(
              child: pw.Text('Relatório financeiro emitido pelo App Controle Financeiro Familiar', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Relatorio_Financeiro_$periodName.pdf',
    );
  }

  pw.Widget _pdfKpi(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  pw.Widget _barComparison(String label, double amount, double ratio, PdfColor color) {
    return pw.Column(
      cross: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
            pw.Text(currencyFormat.format(amount), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.LinearProgressIndicator(value: ratio, backgroundColor: PdfColors.grey200, color: color, minHeight: 8),
      ],
    );
  }
}
