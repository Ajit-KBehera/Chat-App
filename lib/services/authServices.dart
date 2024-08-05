import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/cupertino.dart";

class AuthServices {
  final FirebaseAuth auth;

  AuthServices(this.auth);

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Stream<User?> get authChanges => auth.idTokenChanges();

  Future<String> signInUser({
    String? email,
    String? pass,
    BuildContext? context,
  }) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email!,
        password: pass!,
      );
      Navigator.pushReplacementNamed(context!, 'Home Screen');
      return 'success';
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<String> signUpUser({
    String? name,
    String? email,
    String? pass,
    BuildContext? context,
  }) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email!, password: pass!);
      fireStore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({"uid": userCredential.user!.uid, 'name': name, 'email': email});
      Navigator.pushReplacementNamed(context!, 'Home Screen');
      return 'success';
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future addFriend() async {

    // fireStore
    //     .collection('users')
    //     .doc(userCredential.user!.uid)
    //     .set({"uid": userCredential.user!.uid, 'name': name, 'email': email});
    //
  }
}
