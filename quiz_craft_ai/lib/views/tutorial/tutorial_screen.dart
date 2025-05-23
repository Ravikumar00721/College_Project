import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WalkthroughScreen extends StatefulWidget {
  @override
  _WalkthroughScreenState createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> walkthroughData = [
    {
      "image": "assets/image/dtoq.png",
      "title": "Welcome to QuizCraft AI",
      "subtitle": "Generate quizzes from PDFs, images, and text instantly.",
    },
    {
      "image": "assets/image/coref.png",
      "title": "Smart AI-Powered Questions",
      "subtitle": "AI understands your content and generates accurate MCQs.",
    },
    {
      "image": "assets/image/pdftoquiz.png",
      "title": "Upload PDFs, Images, or Text",
      "subtitle": "Use multiple formats to generate quizzes effortlessly.",
    },
    {
      "image": "assets/image/start.png",
      "title": "Enhance Your Learning Experience",
      "subtitle": "Track progress, share quizzes, and test your knowledge.",
    },
  ];

  void _nextPage() {
    if (_currentPage < walkthroughData.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      _finishWalkthrough();
    }
  }

  void _skipTutorial() {
    _finishWalkthrough();
  }

  Future<void> _finishWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_tutorial", true);
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set white background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: walkthroughData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          walkthroughData[index]["image"]!,
                          height: 300,
                        ),
                        SizedBox(height: 30),
                        Text(
                          walkthroughData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            walkthroughData[index]["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage < walkthroughData.length - 1
                      ? TextButton(
                          onPressed: _skipTutorial,
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        )
                      : SizedBox(width: 60),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: walkthroughData.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Colors.blue,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  TextButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == walkthroughData.length - 1
                          ? "Get Started"
                          : "Next",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
