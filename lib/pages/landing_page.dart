import 'package:flutter/material.dart';

final Color kYellow = Color(0xFFFFD600);
final Color kBlack = Colors.black;
final Color kWhite = Colors.white;

class LandingPage extends StatefulWidget {
  final VoidCallback onContinue;
  const LandingPage({super.key, required this.onContinue});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<_LandingInfo> _pages = [
    _LandingInfo(
      title: 'Track Your Expenses',
      description:
          'Easily add, edit, and visualize your daily expenses with beautiful charts.',
      image: 'assets/landing_expense.png',
    ),
    _LandingInfo(
      title: 'Manage Fixed Charges',
      description:
          'Keep recurring costs like rent and subscriptions organized and always visible.',
      image: 'assets/landing_fixed.png',
    ),
    _LandingInfo(
      title: 'Secure & Private',
      description:
          'Your data is stored securely on your device. Sign in with Google for easy access.',
      image: 'assets/landing_secure.png',
    ),
    _LandingInfo(
      title: 'Modern, Accessible UI',
      description:
          'Enjoy a modern, accessible design with a bold yellow, black, and white color scheme.',
      image: 'assets/landing_modern.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Image.asset('assets/logo.png', height: 64),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final info = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            info.image,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (c, e, s) => Icon(
                                  Icons.image,
                                  size: 120,
                                  color: kYellow,
                                ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          info.title,
                          style: TextStyle(
                            color: kYellow,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          info.description,
                          style: TextStyle(color: kWhite, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? kYellow : kWhite.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kYellow,
                  foregroundColor: kBlack,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed:
                    _page == _pages.length - 1
                        ? widget.onContinue
                        : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        ),
                child: Text(
                  _page == _pages.length - 1 ? 'Get Started' : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingInfo {
  final String title;
  final String description;
  final String image;
  const _LandingInfo({
    required this.title,
    required this.description,
    required this.image,
  });
}
