import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinwishapp/screens/welcome/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _titleAnimationController;
  late AnimationController _descriptionAnimationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _descriptionFadeAnimation;
  late Animation<Offset> _descriptionSlideAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to SpinWish',
      description:
          'Connect with DJs and discover amazing music experiences in real-time',
      imagePath: 'lib/onboard1.jpg',
    ),
    OnboardingPage(
      title: 'Request Your Favorite Songs',
      description:
          'Send song requests to DJs and tip them to prioritize your music',
      imagePath: 'lib/onboard2.jpg',
    ),
    OnboardingPage(
      title: 'Live DJ Sessions',
      description:
          'Join live sessions from clubs and online DJs around the world',
      imagePath: 'lib/onboard3.jpg',
    ),
    OnboardingPage(
      title: 'Become a DJ',
      description:
          'Start your own sessions, earn from tips and requests, and build your audience',
      imagePath: 'lib/onboard4.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _descriptionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeInOut,
    ));

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _descriptionFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _descriptionAnimationController,
      curve: Curves.easeInOut,
    ));

    _descriptionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _descriptionAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations after image loads (delayed start)
    _startAnimationsWithDelay();
  }

  void _startAnimationsWithDelay() {
    // Wait longer for image to fully load and display first
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _titleAnimationController.forward();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            _descriptionAnimationController.forward();
          }
        });
      }
    });
  }

  void _resetAnimations() {
    _titleAnimationController.reset();
    _descriptionAnimationController.reset();
    _startAnimationsWithDelay();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Page content with full screen background
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _resetAnimations();
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], theme);
            },
          ),

          // Skip button overlay
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Page indicators overlay
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: _buildPageIndicators(theme),
            ),
          ),

          // Navigation buttons overlay
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _buildNavigationButtons(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, ThemeData theme) {
    return Stack(
      children: [
        // Background image - loads immediately and stays visible
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(page.imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient overlay - always visible
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),

        // Text content - animated
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),

                // Animated Title
                SlideTransition(
                  position: _titleSlideAnimation,
                  child: FadeTransition(
                    opacity: _titleFadeAnimation,
                    child: Text(
                      page.title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 32,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Animated Description
                SlideTransition(
                  position: _descriptionSlideAnimation,
                  child: FadeTransition(
                    opacity: _descriptionFadeAnimation,
                    child: Text(
                      page.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.6,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                const SizedBox(
                    height: 156), // Increased by 30% (120 * 1.3 = 156)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicators(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 8),
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _currentPage == index
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    return Row(
      children: [
        // Previous button
        if (_currentPage > 0)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextButton(
                onPressed: _previousPage,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        if (_currentPage > 0) const SizedBox(width: 16),

        // Next/Get Started button
        Expanded(
          flex: _currentPage == 0 ? 1 : 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _currentPage == _pages.length - 1
                  ? _completeOnboarding
                  : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleAnimationController.dispose();
    _descriptionAnimationController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
