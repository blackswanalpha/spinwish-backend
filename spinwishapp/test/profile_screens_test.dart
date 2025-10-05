import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spinwishapp/screens/profile/profile_screen.dart';
import 'package:spinwishapp/screens/profile/edit_profile_screen.dart';
import 'package:spinwishapp/screens/profile/payment_methods_screen.dart';
import 'package:spinwishapp/screens/profile/request_history_screen.dart';
import 'package:spinwishapp/screens/profile/notification_settings_screen.dart';
import 'package:spinwishapp/screens/profile/help_support_screen.dart';
import 'package:spinwishapp/screens/profile/about_spinwish_screen.dart';
import 'package:spinwishapp/screens/profile/send_feedback_screen.dart';
import 'package:spinwishapp/screens/profile/profile_settings_screen.dart';
import 'package:spinwishapp/theme.dart';

void main() {
  group('Profile Screens Tests', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        theme: lightTheme,
        home: child,
      );
    }

    testWidgets('ProfileScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const ProfileScreen()));

      // Verify main elements are present
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('Request History'), findsOneWidget);
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
      expect(find.text('About SpinWish'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('EditProfileScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const EditProfileScreen()));

      // Verify main elements are present
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Favorite Genres'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('PaymentMethodsScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PaymentMethodsScreen()));

      // Verify main elements are present
      expect(find.text('Payment Methods'), findsOneWidget);
      // Should show empty state initially
      expect(find.text('No Payment Methods'), findsOneWidget);
      expect(find.text('Add Payment Method'), findsWidgets);
    });

    testWidgets('RequestHistoryScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RequestHistoryScreen()));

      // Verify main elements are present
      expect(find.text('Request History'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search field
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('NotificationSettingsScreen displays correctly',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(const NotificationSettingsScreen()));

      // Verify main elements are present
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Song Requests'), findsOneWidget);
      expect(find.text('DJ Live Sessions'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('HelpSupportScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HelpSupportScreen()));

      // Verify main elements are present
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
      expect(find.text('Contact Us'), findsOneWidget);
    });

    testWidgets('AboutSpinWishScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const AboutSpinWishScreen()));

      // Verify main elements are present
      expect(find.text('About SpinWish'), findsOneWidget);
      expect(find.text('SpinWish'), findsWidgets);
      expect(find.text('Connect. Request. Enjoy.'), findsOneWidget);
      expect(find.text('App Information'), findsOneWidget);
      expect(find.text('Legal'), findsOneWidget);
    });

    testWidgets('SendFeedbackScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SendFeedbackScreen()));

      // Verify main elements are present
      expect(find.text('Send Feedback'), findsOneWidget);
      expect(find.text('Feedback Category'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Priority Level'), findsOneWidget);
      expect(find.text('Submit Feedback'), findsOneWidget);
    });

    testWidgets('ProfileSettingsScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const ProfileSettingsScreen()));

      // Verify main elements are present
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App Preferences'), findsOneWidget);
      expect(find.text('Audio Settings'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    group('Navigation Tests', () {
      testWidgets('Profile screen navigation works',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const ProfileScreen()));

        // Test Edit Profile navigation
        await tester.tap(find.text('Edit Profile'));
        await tester.pumpAndSettle();
        expect(find.text('Edit Profile'), findsWidgets);

        // Go back
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Profile'), findsOneWidget);
      });

      testWidgets('Settings bottom sheet navigation works',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const ProfileScreen()));

        // Open settings bottom sheet
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsWidgets);
        expect(find.text('App Settings'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Edit Profile'), findsWidgets);
      });
    });

    group('Form Validation Tests', () {
      testWidgets('Edit Profile form validation works',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const EditProfileScreen()));

        // Try to save without filling required fields
        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.text('Please enter your name'), findsOneWidget);
        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('Send Feedback form validation works',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const SendFeedbackScreen()));

        // Try to submit without filling required fields
        await tester.tap(find.text('Submit Feedback'));
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.text('Please enter a title'), findsOneWidget);
        expect(find.text('Please enter a description'), findsOneWidget);
      });
    });

    group('Widget Interaction Tests', () {
      testWidgets('Feedback category selection works',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const SendFeedbackScreen()));

        // Find and tap a feedback category
        await tester.tap(find.text('Bug Report'));
        await tester.pumpAndSettle();

        // Verify selection is reflected in UI
        expect(find.text('Bug Report'), findsOneWidget);
      });

      testWidgets('Priority selection works', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const SendFeedbackScreen()));

        // Find and tap a priority level
        await tester.tap(find.text('HIGH'));
        await tester.pumpAndSettle();

        // Verify selection works
        expect(find.text('HIGH'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Profile screens have proper semantics',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(const ProfileScreen()));

        // Verify important elements have semantic labels
        expect(find.bySemanticsLabel('Profile'), findsOneWidget);
        expect(find.byType(Semantics), findsWidgets);
      });
    });

    group('Theme Tests', () {
      testWidgets('Screens work with dark theme', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: darkTheme,
          home: const ProfileScreen(),
        ));

        await tester.pumpAndSettle();
        expect(find.text('Profile'), findsOneWidget);
      });
    });
  });
}
