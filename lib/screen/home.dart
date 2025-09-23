import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final user = FirebaseAuth.instance.currentUser;

  signOut()async{
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home page"),),
      body: Center(
        child: Text("Welcome ${user?.email}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (()=>signOut()),
        child: Icon(Icons.login_rounded),
      ),
    );
  }
}
