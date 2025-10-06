import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Address.dart';
import 'editProfile.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isAlternateIcon = false;

  // User info (default values)
  String userName = "Loading...";
  String userGender = "unknown";
  String userEmail = "Loading...";

  final userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;

      // ✅ Check for missing gender field
      if (!data.containsKey('gender')) {
        await docRef.update({'gender': 'unknown'});
        data['gender'] = 'unknown'; // update local value too
      }

      setState(() {
        userName = data['name'] ?? 'Unknown';
        userGender = data['gender'] ?? 'unknown';
        userEmail = FirebaseAuth.instance.currentUser?.email ?? 'No Email';
      });
    }
  }



  // // User info
  // String userName = "John Doe";
  // String userGender = "Male";
  // String userEmail = "john.doe@email.com";



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- User Info ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(
                      _isAlternateIcon
                          ? Icons.person_3_rounded
                          : Icons.person_outline,
                      size: 60,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userGender,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  /// --- Edit Profile Button ---
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black45),
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            currentName: userName,
                            currentGender: userGender,
                            email: userEmail,
                          ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          userName = result['name'];
                          userGender = result['gender'];
                        });
                      }
                    },
                    child: const Text("Edit Profile"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// --- Account Settings ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Account Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// --- Saved Address Button ---
            ListTile(
              leading: const Icon(Icons.location_on_outlined, color: Colors.black87),
              title: const Text(
                "Saved Addresses",
                style: TextStyle(color: Colors.black87),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Address()),
                );
              },
            ),
            const Divider(thickness: 1, color: Colors.black12),
          ],
        ),
      ),
    );
  }
}