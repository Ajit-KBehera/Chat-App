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
      if (email == null || email.isEmpty) {
        throw Exception('Email is required');
      }
      if (pass == null || pass.isEmpty) {
        throw Exception('Password is required');
      }
      
      await auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      if (context != null) {
        Navigator.pushReplacementNamed(context, 'Home Screen');
      }
      return 'success';
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<String> signUpUser({
    String? name,
    String? email,
    String? pass,
    BuildContext? context,
  }) async {
    try {
      if (name == null || name.isEmpty) {
        throw Exception('Name is required');
      }
      if (email == null || email.isEmpty) {
        throw Exception('Email is required');
      }
      if (pass == null || pass.isEmpty) {
        throw Exception('Password is required');
      }
      
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      
      if (userCredential.user != null) {
        await fireStore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({"uid": userCredential.user!.uid, 'name': name, 'email': email});
      }
      
      if (context != null) {
        Navigator.pushReplacementNamed(context, 'Home Screen');
      }
      return 'success';
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

}
