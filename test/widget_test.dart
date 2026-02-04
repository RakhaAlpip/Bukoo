import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SimpleScreen extends StatelessWidget {
  const SimpleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Bukoo App')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Tambah Buku'),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Cek tampilan dasar Bukoo', (WidgetTester tester) async {
    await tester.pumpWidget(const SimpleScreen());
    expect(find.text('Bukoo App'), findsOneWidget);
    expect(find.text('Tambah Buku'), findsOneWidget);
    expect(find.text('Hapus Buku'), findsNothing);
  });
}