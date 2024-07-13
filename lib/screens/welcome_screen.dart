import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/constants.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'Welcome_Screen';

  const WelcomeScreen({super.key});
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController controllerC;
  late Animation animation;
  late Animation animationC;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    controllerC = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 15),
    );
    animationC = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controllerC);
    animation = CurvedAnimation(parent: controller, curve: Curves.bounceOut);
    controller.forward();
    controllerC.forward();
    controller.addListener(() {
      setState(() {});
    });
    controllerC.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    controllerC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animationC.value,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: animation.value * 100,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      "Flash Chat",
                      textStyle: const TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.w900,
                      ),
                      speed: const Duration(milliseconds: 200),
                      cursor: '|',
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 100),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),
            RoundedButton(
                cardText: 'Log In',
                col: Colors.lightBlueAccent,
                onPress: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                }),
            RoundedButton(
                cardText: 'Register',
                col: Colors.blueAccent,
                onPress: () {
                  Navigator.pushNamed(context, RegistrationScreen.id);
                }),
          ],
        ),
      ),
    );
  }
}
