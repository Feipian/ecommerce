import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Address extends StatefulWidget {
  const Address({super.key});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {

  final userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Addresses"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addAddress(context, userDocRef); // Function to add address
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDocRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null || userData['address'] == null) {
            return const Center(
              child: Text("Your saved addresses will show here"),
            );
          }

          List addresses = List.from(userData['address']);

          if (addresses.isEmpty) {
            return const Center(
              child: Text("Your saved addresses will show here"),
            );
          }

          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.home),
                title: Text(addresses[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Remove from Firestore
                    await userDocRef.update({
                      'address': FieldValue.arrayRemove([addresses[index]])
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addAddress(BuildContext context, DocumentReference<Map<String, dynamic>> userDocRef) {
    final TextEditingController controller = TextEditingController();
    final List<String> _addresses = []; // Local list for addresses
    final userId = FirebaseAuth.instance.currentUser?.uid;


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Address"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter your address"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final address = controller.text.trim();
                if (address.isNotEmpty) {
                  setState(() {
                    _addresses.add(address);
                  });

                  // Optional: Save to Firestore
                  if (userId != null) {
                    final userDocRef =
                    FirebaseFirestore.instance.collection('users').doc(userId);

                    // If "address" field is a list
                    await userDocRef.set({
                      'address': FieldValue.arrayUnion([address])
                    }, SetOptions(merge: true));
                  }

                  Navigator.pop(context); // Close dialog
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

  }
}