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
import 'package:spinwishapp/screens/profile/add_payment_method_screen.dart';
import 'package:spinwishapp/theme.dart';

void main() {
  group('Profile Screens Compilation Tests', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        theme: lightTheme,
        home: child,
      );
    }

    testWidgets('All profile screens can be instantiated', (WidgetTester tester) async {
      // Test that all screens can be created without compilation errors
      
      // ProfileScreen
      const profileScreen = ProfileScreen();
      expect(profileScreen, isA<Widget>());
      
      // EditProfileScreen
      const editProfileScreen = EditProfileScreen();
      expect(editProfileScreen, isA<Widget>());
      
      // PaymentMethodsScreen
      const paymentMethodsScreen = PaymentMethodsScreen();
      expect(paymentMethodsScreen, isA<Widget>());
      
      // AddPaymentMethodScreen
      const addPaymentMethodScreen = AddPaymentMethodScreen();
      expect(addPaymentMethodScreen, isA<Widget>());
      
      // RequestHistoryScreen
      const requestHistoryScreen = RequestHistoryScreen();
      expect(requestHistoryScreen, isA<Widget>());
      
      // NotificationSettingsScreen
      const notificationSettingsScreen = NotificationSettingsScreen();
      expect(notificationSettingsScreen, isA<Widget>());
      
      // HelpSupportScreen
      const helpSupportScreen = HelpSupportScreen();
      expect(helpSupportScreen, isA<Widget>());
      
      // AboutSpinWishScreen
      const aboutSpinWishScreen = AboutSpinWishScreen();
      expect(aboutSpinWishScreen, isA<Widget>());
      
      // SendFeedbackScreen
      const sendFeedbackScreen = SendFeedbackScreen();
      expect(sendFeedbackScreen, isA<Widget>());
      
      // ProfileSettingsScreen
      const profileSettingsScreen = ProfileSettingsScreen();
      expect(profileSettingsScreen, isA<Widget>());
    });

    testWidgets('ProfileScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const ProfileScreen()));
      await tester.pump();
      
      // Verify screen loads without throwing exceptions
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('EditProfileScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const EditProfileScreen()));
      await tester.pump();
      
      // Verify screen loads without throwing exceptions
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });

    testWidgets('SendFeedbackScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SendFeedbackScreen()));
      await tester.pump();
      
      // Verify screen loads without throwing exceptions
      expect(find.byType(SendFeedbackScreen), findsOneWidget);
    });

    testWidgets('HelpSupportScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HelpSupportScreen()));
      await tester.pump();
      
      // Verify screen loads without throwing exceptions
      expect(find.byType(HelpSupportScreen), findsOneWidget);
    });
  });
}
