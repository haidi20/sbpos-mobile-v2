import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptPreviewSheet', () {
    testWidgets('menampilkan isi receipt print job', (tester) async {
      const job = ReceiptPrintJob(
        title: 'SB POS',
        lines: [
          ReceiptPrintLine(label: 'No. Order', value: '#99', emphasize: true),
          ReceiptPrintLine(label: 'Americano x1', value: 'Rp 15.000'),
          ReceiptPrintLine(label: 'Total', value: 'Rp 25.000', emphasize: true),
        ],
        footer: 'Terima kasih',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ReceiptPreviewSheet.show(
                        context,
                        job: job,
                        onConfirmPrint: () async =>
                            const ReceiptPrintResult.success('ok'),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Preview Struk'), findsOneWidget);
      expect(find.text('SB POS'), findsOneWidget);
      expect(find.text('No. Order'), findsOneWidget);
      expect(find.text('#99'), findsOneWidget);
      expect(find.text('Americano x1'), findsOneWidget);
      expect(find.text('Terima kasih'), findsOneWidget);
      expect(find.text('Cetak Sekarang'), findsOneWidget);
    });

    testWidgets('confirm print memanggil callback dan menutup sheet',
        (tester) async {
      var callCount = 0;
      ReceiptPrintResult? result;

      const job = ReceiptPrintJob(
        title: 'SB POS',
        lines: [
          ReceiptPrintLine(label: 'Total', value: 'Rp 25.000'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await ReceiptPreviewSheet.show(
                        context,
                        job: job,
                        onConfirmPrint: () async {
                          callCount += 1;
                          return const ReceiptPrintResult.success(
                            'Struk berhasil dicetak',
                          );
                        },
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cetak Sekarang'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(callCount, equals(1));
      expect(result?.isSuccess, isTrue);
      expect(find.text('Preview Struk'), findsNothing);
    });
  });
}
