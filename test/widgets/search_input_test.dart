// test/search_input_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trade_plus/widgets/search_input.dart';

void main() {
  testWidgets('SearchInputWidget calls onTextChanged with the correct value', (WidgetTester tester) async {
    String searchText = '';

    void onTextChanged(String text) {
      searchText = text;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchInputWidget(onTextChanged: onTextChanged),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'AAPL');
    await tester.pump(); // Rebuild the widget after the state has changed.

    expect(searchText, 'AAPL');
  });

  testWidgets('SearchInputWidget starts with empty text', (WidgetTester tester) async {
    String searchText = '';
    void onTextChanged(String text) {
      searchText = text;
    }
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchInputWidget(onTextChanged: onTextChanged),
        ),
      ),
    );
    final textFieldFinder = find.byType(TextField);
    
    await tester.enterText(textFieldFinder, ''); 
    await tester.pump(); 

    expect(searchText, isEmpty);
  });
}