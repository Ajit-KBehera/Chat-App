import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pl_project/services/authServices.dart';
import 'package:pl_project/utils/conts.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late double? height;
  late double? width;
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void showLoader(bool val) {
    setState(() {
      isLoading = val;
    });
  }

  void signIn({BuildContext? context}) async {
    final authServices = context!.read<AuthServices>();
    try {
      showLoader(true);
      await authServices.signInUser(
        context: context,
        email: emailController.text.trim(),
        pass: passwordController.text.trim(),
      );
      showLoader(false);
    } catch (e) {
      showLoader(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    height = getHeight(context);
    width = getWidth(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Sign In",
          ),
        ),
        body: IgnorePointer(
          ignoring: isLoading,
          child: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset("assets/login_animation.json",
                              height: height! * 0.25)
                          .paddingOnly(
                              top: height! * 0.1, bottom: height! * 0.1),
                      Align(
                        child: Text(
                          "Welcome Back!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height! * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).paddingBottom(height! * 0.03),
                      TextFormField(
                        autocorrect: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email id';
                          }
                          return null;
                        },
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          hintText: 'Enter your email',
                        ),
                      ).paddingBottom(30),
                      TextFormField(
                        autocorrect: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          hintText: 'Enter your password',
                        ),
                      ).paddingBottom(30),
                      SizedBox(
                        width: height! * 0.2,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              signIn(
                                context: context,
                              );
                            }
                          },
                          child: const Text('Sign In'),
                        ),
                      ).paddingBottom(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Not yet registered? ",
                            style: TextStyle(color: Colors.black),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, 'SignUp Screen');
                            },
                            child: const Text(
                              "Register here!",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ).paddingOnly(bottom: 25)
                    ],
                  ),
                ).paddingOnly(left: 25, right: 25),
              ),
              isLoading
                  ? Container(
                      height: height,
                      width: width,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      child: Loader(
                        color: Colors.amberAccent,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
