import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class FullImageView extends StatefulWidget {
  final List<Uint8List> imageBytesList;
  final int initialIndex;

  FullImageView(
      {super.key, required this.imageBytesList, required this.initialIndex});

  @override
  _FullImageViewState createState() => _FullImageViewState();
}

class _FullImageViewState extends State<FullImageView> {
  bool _isSaving = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> _saveImageToGallery(
      context, Uint8List imageBytes) async {
    if (_isSaving) return; // Prevent multiple taps
    setState(() {
      _isSaving = true;
    });

    // Request media library permissions
    var status = await Permission.mediaLibrary.status;
    if (!status.isGranted) {
      // Request permission if not granted
      status = await Permission.mediaLibrary.request();
    }

    if (status.isGranted) {
      try {

        final now = DateTime.now();
        final formattedDateTime = DateFormat('yyyy_MM_dd_HH_mm_ss').format(now);
        final imageName = 'Juhat_$formattedDateTime';


        final correctedImageBytes = await compute(_processImage, imageBytes);

        final result = await ImageGallerySaver.saveImage(
          correctedImageBytes,
          quality: 100,
          name: imageName,
        );

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to gallery!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save image'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
          ),
        );
      } finally {
        setState(() {
          _isSaving = false; // Reset saving state
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission denied'),
        ),
      );
      setState(() {
        _isSaving = false; // Reset saving state
      });
    }
  }

  // Function to process image in background
  static Uint8List _processImage(Uint8List imageBytes) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image != null) {
      image = img.copyResize(image, width: image.width, height: image.height);
      return Uint8List.fromList(img.encodeJpg(image, quality: 100));
    } else {
      return Uint8List.fromList([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.white,
            )),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator())
                : const Icon(
                    Icons.save_alt,
                    color: Colors.white,
                  ),
            onPressed: _isSaving
                ? null
                : () => _saveImageToGallery(context,
                    widget.imageBytesList[_pageController.page!.toInt()]),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageBytesList.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            maxScale: 6,
            child: Image.memory(
              widget.imageBytesList[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
