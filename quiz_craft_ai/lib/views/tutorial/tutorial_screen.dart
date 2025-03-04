import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      "image": "assets/image/quiztime.png",
      "title": "Enhance Your Learning Experience",
      "subtitle": "Track progress, share quizzes, and test your knowledge",
    },
  ];

  void _nextPage() {
    if (_currentPage < walkthroughData.length - 1) {
      _controller.nextPage(
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      context.go('/login'); // Navigate to login on last page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(walkthroughData[index]["image"]!, height: 300),
                    SizedBox(height: 20),
                    Text(
                      walkthroughData[index]["title"]!,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        walkthroughData[index]["subtitle"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom Bar (80px height)
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                TextButton(
                  onPressed: () => context.go('/login'), // Skip to Login
                  child: Text("Skip",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                // Page Indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: walkthroughData.length,
                  effect: WormEffect(activeDotColor: Colors.blue),
                ),

                // Next or Get Started Button
                TextButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == walkthroughData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
