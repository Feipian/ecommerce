import 'package:ecommerce/auth/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserInfoScreen extends StatefulWidget {
  final String userId;
  const UserInfoScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Future<void> saveUserInfo() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
      'name': nameController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'createdAt': DateTime.now(),
    });

    // Go to wrapper/home
    Get.offAll(() => Wrapper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: "Address"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveUserInfo,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
