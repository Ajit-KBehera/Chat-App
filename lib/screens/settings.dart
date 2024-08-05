import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../services/authServices.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text("Sign Out"),
            onTap: () {
              final authServices = context.read<AuthServices>();
              authServices.signOut();
              Navigator.pushReplacementNamed(context, 'Login Screen');
            },
          ),
          const Divider(),
        ],
      ).paddingSymmetric(horizontal: 16, vertical: 16),
    );
  }
}
