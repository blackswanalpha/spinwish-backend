import 'package:flutter/material.dart';

class PageTransitions {
  // Slide transition from right to left
  static Route<T> slideFromRight<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Slide transition from left to right
  static Route<T> slideFromLeft<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Fade transition
  static Route<T> fadeTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // Scale transition
  static Route<T> scaleTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        var tween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  // Slide up transition (for modals/bottom sheets)
  static Route<T> slideFromBottom<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Custom transition for auth screens
  static Route<T> authTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Combine slide and fade for smooth auth transitions
        const slideBegin = Offset(0.3, 0.0);
        const slideEnd = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var slideTween = Tween(begin: slideBegin, end: slideEnd).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  // Rotation transition
  static Route<T> rotationTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        var rotationTween = Tween(begin: 0.1, end: 0.0).chain(
          CurveTween(curve: curve),
        );
        var scaleTween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return Transform.rotate(
          angle: animation.drive(rotationTween).value,
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// Extension to make navigation easier
extension NavigationExtensions on BuildContext {
  // Navigate with slide from right
  Future<T?> pushSlideFromRight<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.slideFromRight(page));
  }

  // Navigate with slide from left
  Future<T?> pushSlideFromLeft<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.slideFromLeft(page));
  }

  // Navigate with fade
  Future<T?> pushFade<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.fadeTransition(page));
  }

  // Navigate with scale
  Future<T?> pushScale<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.scaleTransition(page));
  }

  // Navigate with auth transition
  Future<T?> pushAuth<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.authTransition(page));
  }

  // Replace with slide from right
  Future<T?> pushReplacementSlideFromRight<T extends Object?, TO extends Object?>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(PageTransitions.slideFromRight(page));
  }

  // Replace with fade
  Future<T?> pushReplacementFade<T extends Object?, TO extends Object?>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(PageTransitions.fadeTransition(page));
  }

  // Replace with auth transition
  Future<T?> pushReplacementAuth<T extends Object?, TO extends Object?>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(PageTransitions.authTransition(page));
  }
}
