import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/widgets/tiled_background.dart';

void main() {
  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TiledBackground(child: Text('content')),
      ),
    ));
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('uses the home background asset by default', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TiledBackground(child: SizedBox.shrink()),
      ),
    ));
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    final image = decoration.image!.image as AssetImage;
    expect(image.assetName, 'assets/images/background_home.png');
  });

  testWidgets('accepts a custom background asset', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TiledBackground(
          asset: 'assets/images/background.png',
          child: SizedBox.shrink(),
        ),
      ),
    ));
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    final image = decoration.image!.image as AssetImage;
    expect(image.assetName, 'assets/images/background.png');
  });
}
