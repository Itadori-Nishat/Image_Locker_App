import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'Reset Pin.dart';
import 'View Full Image.dart';


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Uint8List> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final images = prefs.getStringList('images') ?? [];
    List<Uint8List> decodedImages = [];

    for (String base64Image in images) {
      decodedImages.add(base64Decode(base64Image));
    }

    setState(() {
      _images = decodedImages;
      _isLoading = false;
    });
  }

  Future<void> _saveImages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> base64Images =
        _images.map((imageBytes) => base64Encode(imageBytes)).toList();
    await prefs.setStringList('images', base64Images);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _images.add(bytes);
      });
      _saveImages();
    }
  }

  void _deleteImage(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Image"),
          content: const Text("Are you sure you want to delete this image?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                setState(() {
                  _images.removeAt(index);
                });
                _saveImages();
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Image Storage App',
          style: TextStyle(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'change_pin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResetPinScreen(isResetting: true)),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return {
                'Change PIN',
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice.toLowerCase().replaceAll(' ', '_'),
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _images.isEmpty
          ? const Center(child: Text("Pick Images to save here"))
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemBuilder: (context, index) {
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullImageView(
                                        imageBytesList: _images,
                                        initialIndex: index,
                                      )));
                        },
                        onLongPress: () {
                          _deleteImage(index);
                        },
                        child: Image.memory(
                          _images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add),
      ),
    );
  }
}
