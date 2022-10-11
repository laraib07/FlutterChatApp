import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
    );

    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: SizedBox(
                      height: 60,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 250.0,
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                    ),
                    child: AnimatedTextKit(
                      isRepeatingAnimation: true,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Flash Chat',
                          speed: const Duration(milliseconds: 250),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),
            Hero(
              tag: 'Log In',
              child: RoundedButton(
                title: 'Log In',
                color: Colors.lightBlueAccent,
                onTap: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
            ),
            Hero(
              tag: 'Register',
              child: RoundedButton(
                title: 'Register',
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.pushNamed(context, RegistrationScreen.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
