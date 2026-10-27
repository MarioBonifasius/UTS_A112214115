import 'package:flutter_test/flutter_test.dart';

import 'package:hris_mini/main.dart';

void main() {
  testWidgets('HRIS menampilkan daftar dan membuka detail pengajuan',
      (tester) async {
    await tester.pumpWidget(const HrisApp());
    expect(find.text('Budi Santoso'), findsOneWidget);

    await tester.tap(find.text('Budi Santoso'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Pengajuan'), findsOneWidget);
    expect(find.text('Total 5 hari'), findsOneWidget);
  });
}
