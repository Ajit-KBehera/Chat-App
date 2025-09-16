import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pl_project/services/authServices.dart';
import 'package:provider/provider.dart';
import '../utils/conts.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool isLoading = false;
  late double? height;
  late double? width;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);
    return value!.isEmpty
        ? 'Enter a email address'
        : value.isNotEmpty && !regex.hasMatch(value)
            ? 'Enter a valid email address'
            : null;
  }

  String? validatePassword(String? value) {
    const pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    final regex = RegExp(pattern);
    return value!.isEmpty
        ? 'Enter a Password'
        : value.isNotEmpty && !regex.hasMatch(value)
            ? 'Password is weak!'
            : null;
  }

  void showLoader(bool val) {
    setState(() {
      isLoading = val;
    });
  }

  void signUp({BuildContext? context}) async {
    final authServices = context!.read<AuthServices>();
    try {
      showLoader(true);
      await authServices.signUpUser(
        context: context,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        pass: passwordController.text.trim(),
      );
      showLoader(false);
    } catch (e) {
      showLoader(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    height = getHeight(context);
    width = getWidth(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
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
                      Lottie.asset("assets/signup.json", height: height! * 0.4)
                          .paddingTop(20),
                      Align(
                        child: Text(
                          "Create a new account!",
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
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          hintText: 'Enter your name',
                        ),
                      ).paddingBottom(30),
                      TextFormField(
                        autocorrect: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: validateEmail,
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          hintText: 'Enter your email',
                        ),
                      ).paddingBottom(30),
                      TextFormField(
                        obscureText: true,
                        autocorrect: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: validatePassword,
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
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              signUp(
                                context: context,
                              );
                            }
                          },
                          child: const Text('Signup'),
                        ),
                      ).paddingOnly(bottom: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already a user? ",
                            style: TextStyle(color: Colors.black),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, 'Login Screen');
                            },
                            child: const Text(
                              "SignIn here!",
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
        ));
  }
}
