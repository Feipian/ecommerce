import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}


class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _releaseDate;
  File? _posterImage;

  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _posterImage = File(picked.path);
      });
    }
  }

  Future<String> _uploadPoster(File file) async {
    final fileName = "movies/${DateTime.now().millisecondsSinceEpoch}.jpg";
    if ((file == null) || !file.existsSync()) {
      throw Exception("No file selected or file does not exist");
    }
    final ref = FirebaseStorage.instance.ref().child(fileName);

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate() || _posterImage == null || _releaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and pick poster + release date")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Upload poster first
      final posterUrl = await _uploadPoster(_posterImage!);

      // Save to Firestore
      await FirebaseFirestore.instance.collection('movies').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'posterUrl': posterUrl,
        'releaseDate': _releaseDate,
        'createdAt': DateTime.now(),
      });

      Navigator.pop(context); // go back after success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Movie")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
                validator: (value) => value!.isEmpty ? "Enter movie title" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? "Enter description" : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(_releaseDate == null
                      ? "Pick release date"
                      : "Release: ${_releaseDate!.toLocal().toString().split(' ')[0]}"),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => _releaseDate = pickedDate);
                      }
                    },
                    child: Text("Select Date"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _posterImage == null
                  ? Text("No poster selected")
                  : Image.file(_posterImage!, height: 150),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Pick Poster"),
              ),
              SizedBox(height: 24),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveMovie,
                child: Text("Save Movie"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}