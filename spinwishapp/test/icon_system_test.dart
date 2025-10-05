import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/icon_manager.dart';

void main() {
  group('SpinWish Icon System Tests', () {
    setUp(() {
      // Reset to default icon set before each test
      SpinWishIcons.setIconSet(IconSet.hugeicons);
    });

    test('should default to HugeIcons', () {
      expect(SpinWishIcons.currentIconSet, IconSet.hugeicons);
    });

    test('should switch icon sets correctly', () {
      // Switch to Material Icons
      SpinWishIcons.setIconSet(IconSet.material);
      expect(SpinWishIcons.currentIconSet, IconSet.material);

      // Switch back to HugeIcons
      SpinWishIcons.setIconSet(IconSet.hugeicons);
      expect(SpinWishIcons.currentIconSet, IconSet.hugeicons);
    });

    test('should return different icons for different sets', () {
      // Test with Material Icons
      SpinWishIcons.setIconSet(IconSet.material);
      final materialHomeIcon = SpinWishIcons.home;

      // Test with HugeIcons
      SpinWishIcons.setIconSet(IconSet.hugeicons);
      final hugeHomeIcon = SpinWishIcons.home;

      // Icons should be different
      expect(materialHomeIcon, isNot(equals(hugeHomeIcon)));
    });

    group('Navigation Icons', () {
      test('should provide all navigation icons', () {
        expect(SpinWishIcons.home, isA<IconData>());
        expect(SpinWishIcons.sessions, isA<IconData>());
        expect(SpinWishIcons.djs, isA<IconData>());
        expect(SpinWishIcons.music, isA<IconData>());
        expect(SpinWishIcons.requests, isA<IconData>());
        expect(SpinWishIcons.profile, isA<IconData>());
      });
    });

    group('Action Icons', () {
      test('should provide all action icons', () {
        expect(SpinWishIcons.edit, isA<IconData>());
        expect(SpinWishIcons.settings, isA<IconData>());
        expect(SpinWishIcons.search, isA<IconData>());
        expect(SpinWishIcons.filter, isA<IconData>());
        expect(SpinWishIcons.download, isA<IconData>());
        expect(SpinWishIcons.logout, isA<IconData>());
      });
    });

    group('Media Control Icons', () {
      test('should provide all media control icons', () {
        expect(SpinWishIcons.play, isA<IconData>());
        expect(SpinWishIcons.pause, isA<IconData>());
        expect(SpinWishIcons.stop, isA<IconData>());
        expect(SpinWishIcons.skipNext, isA<IconData>());
        expect(SpinWishIcons.skipPrevious, isA<IconData>());
        expect(SpinWishIcons.volume, isA<IconData>());
        expect(SpinWishIcons.volumeMute, isA<IconData>());
      });
    });

    group('Status & Category Icons', () {
      test('should provide all status and category icons', () {
        expect(SpinWishIcons.trending, isA<IconData>());
        expect(SpinWishIcons.diamond, isA<IconData>());
        expect(SpinWishIcons.colorize, isA<IconData>());
        expect(SpinWishIcons.rocket, isA<IconData>());
        expect(SpinWishIcons.sun, isA<IconData>());
        expect(SpinWishIcons.snowflake, isA<IconData>());
        expect(SpinWishIcons.eco, isA<IconData>());
        expect(SpinWishIcons.sparkles, isA<IconData>());
      });
    });

    group('Social & Interaction Icons', () {
      test('should provide all social and interaction icons', () {
        expect(SpinWishIcons.favorite, isA<IconData>());
        expect(SpinWishIcons.share, isA<IconData>());
        expect(SpinWishIcons.comment, isA<IconData>());
        expect(SpinWishIcons.location, isA<IconData>());
        expect(SpinWishIcons.notifications, isA<IconData>());
      });
    });

    group('Utility Icons', () {
      test('should provide all utility icons', () {
        expect(SpinWishIcons.add, isA<IconData>());
        expect(SpinWishIcons.remove, isA<IconData>());
        expect(SpinWishIcons.close, isA<IconData>());
        expect(SpinWishIcons.check, isA<IconData>());
        expect(SpinWishIcons.chevronRight, isA<IconData>());
        expect(SpinWishIcons.arrowForward, isA<IconData>());
      });
    });

    group('Icon Consistency', () {
      test('should return same icon for same call within same set', () {
        SpinWishIcons.setIconSet(IconSet.material);
        final icon1 = SpinWishIcons.home;
        final icon2 = SpinWishIcons.home;
        expect(icon1, equals(icon2));

        SpinWishIcons.setIconSet(IconSet.hugeicons);
        final icon3 = SpinWishIcons.home;
        final icon4 = SpinWishIcons.home;
        expect(icon3, equals(icon4));
      });

      test('should maintain icon set state across calls', () {
        SpinWishIcons.setIconSet(IconSet.material);
        expect(SpinWishIcons.currentIconSet, IconSet.material);
        
        // Call some icons
        SpinWishIcons.home;
        SpinWishIcons.settings;
        SpinWishIcons.music;
        
        // Icon set should remain the same
        expect(SpinWishIcons.currentIconSet, IconSet.material);
      });
    });

    group('Icon Set Enum', () {
      test('should have correct enum values', () {
        expect(IconSet.values.length, 2);
        expect(IconSet.values.contains(IconSet.material), true);
        expect(IconSet.values.contains(IconSet.hugeicons), true);
      });
    });

    group('Icon Variant Enum', () {
      test('should have correct variant values', () {
        expect(IconVariant.values.length, 2);
        expect(IconVariant.values.contains(IconVariant.outlined), true);
        expect(IconVariant.values.contains(IconVariant.filled), true);
      });
    });
  });

  group('Integration Tests', () {
    testWidgets('should work in Icon widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Icon(SpinWishIcons.home),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should work in IconButton widget', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: Icon(SpinWishIcons.settings),
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      
      await tester.tap(find.byType(IconButton));
      expect(pressed, true);
    });

    testWidgets('should work in BottomNavigationBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(SpinWishIcons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(SpinWishIcons.profile),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(Icon), findsNWidgets(2));
    });

    testWidgets('should update when icon set changes', (WidgetTester tester) async {
      SpinWishIcons.setIconSet(IconSet.material);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Icon(SpinWishIcons.home),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          SpinWishIcons.setIconSet(IconSet.hugeicons);
                        });
                      },
                      child: Text('Switch to HugeIcons'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('Switch to HugeIcons'), findsOneWidget);

      // Tap the button to switch icon sets
      await tester.tap(find.text('Switch to HugeIcons'));
      await tester.pump();

      // Icon should still be present (but potentially different)
      expect(find.byType(Icon), findsOneWidget);
      expect(SpinWishIcons.currentIconSet, IconSet.hugeicons);
    });
  });
}
