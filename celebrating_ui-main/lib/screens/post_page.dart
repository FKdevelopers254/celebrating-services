import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/browser_client.dart' as http_browser;
import 'package:http/io_client.dart' as http_io;

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Uint8List> _imageBytesList = [];
  final ImagePicker _picker = ImagePicker();

  // Celebration types
  final List<String> _celebrationTypes = [
    'PERSONAL_ACHIEVEMENT',
    'CAREER_MILESTONE',
    'EDUCATIONAL_SUCCESS',
    'HEALTH_FITNESS',
    'RELATIONSHIP_MILESTONE',
    'CREATIVE_ACCOMPLISHMENT',
    'BUSINESS_SUCCESS',
    'COMMUNITY_SERVICE',
    'TRAVEL_ADVENTURE',
    'LIFE_EVENT',
    'OTHER',
  ];
  String _selectedCelebrationType = 'OTHER';

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final bytesList = await Future.wait(
        pickedFiles.map((f) => f.readAsBytes()),
      );
      setState(() {
        _imageBytesList.addAll(bytesList);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageBytesList.removeAt(index);
    });
  }

  void _submitPost() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final images = _imageBytesList;
    final token = Provider.of<AppState>(context, listen: false).jwtToken;
    final userId = Provider.of<AppState>(context, listen: false).userId;
    final email = Provider.of<AppState>(context, listen: false).email;
    debugPrint('JWT token before upload (full): ${token ?? "<null>"}');

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a post.'),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Upload all images and collect URLs
      List<String> mediaUrls = [];
      var uploadUriGateway = Uri.parse(
        'http://localhost:8080/api/posts/upload-media',
      );
      var uploadUriDirect = Uri.parse(
        'http://localhost:8083/api/posts/upload-media',
      );
      for (int i = 0; i < images.length; i++) {
        http.StreamedResponse uploadResponse;
        // Use BrowserClient for web, IOClient otherwise
        final client =
            kIsWeb ? http_browser.BrowserClient() : http_io.IOClient();
        // Try API Gateway first
        var uploadRequest =
            http.MultipartRequest('POST', uploadUriGateway)
              ..headers['Authorization'] = 'Bearer $token'
              ..files.add(
                http.MultipartFile.fromBytes(
                  'media',
                  images[i],
                  filename: 'image_$i.jpg',
                  contentType: MediaType('image', 'jpeg'),
                ),
              );
        uploadResponse = await client.send(uploadRequest);
        // If not successful, try direct Post Service
        if (uploadResponse.statusCode != 200) {
          var uploadRequestDirect =
              http.MultipartRequest('POST', uploadUriDirect)
                ..headers['Authorization'] = 'Bearer $token'
                ..files.add(
                  http.MultipartFile.fromBytes(
                    'media',
                    images[i],
                    filename: 'image_$i.jpg',
                    contentType: MediaType('image', 'jpeg'),
                  ),
                );
          uploadResponse = await client.send(uploadRequestDirect);
        }
        if (uploadResponse.statusCode != 200) {
          final errorBody = await uploadResponse.stream.bytesToString();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload image ${i + 1}. Status: ${uploadResponse.statusCode}\n$errorBody',
              ),
            ),
          );
          return;
        }
        final uploadRespStr = await uploadResponse.stream.bytesToString();
        final uploadRespJson = jsonDecode(uploadRespStr);
        final mediaUrl = uploadRespJson['mediaUrl'];
        if (mediaUrl == null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image ${i + 1} upload did not return a URL.'),
            ),
          );
          return;
        }
        mediaUrls.add(mediaUrl);
      }

      // 2. Create the post with the image URLs
      var postUriGateway = Uri.parse('http://localhost:8080/api/posts');
      var postUriDirect = Uri.parse('http://localhost:8083/api/posts');
      http.Response postResponse;
      // Try API Gateway first
      postResponse = await http.post(
        postUriGateway,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'content': description,
          'celebrationType': _selectedCelebrationType,
          'mediaUrls': mediaUrls,
          'userId': userId,
        }),
      );
      // If forbidden or not successful, try direct Post Service
      if (postResponse.statusCode == 403 ||
          postResponse.statusCode == 404 ||
          postResponse.statusCode < 200 ||
          postResponse.statusCode > 299) {
        postResponse = await http.post(
          postUriDirect,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'title': title,
            'content': description,
            'celebrationType': _selectedCelebrationType,
            'mediaUrls': mediaUrls,
            'userId': userId,
          }),
        );
      }
      Navigator.of(context).pop(); // Remove loading indicator
      if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        _titleController.clear();
        _descriptionController.clear();

        setState(() {
          _imageBytesList.clear();
          _selectedCelebrationType = 'OTHER';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create post. Status:  {postResponse.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Remove loading indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Celebration type dropdown
            DropdownButtonFormField<String>(
              value: _selectedCelebrationType,
              items:
                  _celebrationTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCelebrationType = val;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Celebration Type'),
            ),
            const SizedBox(height: 12),
            // Multiple image preview
            _imageBytesList.isNotEmpty
                ? SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageBytesList.length,
                    itemBuilder:
                        (context, idx) => Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.memory(
                                _imageBytesList[idx],
                                height: 100,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(idx),
                                child: Container(
                                  color: Colors.black54,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ),
                )
                : const Text('No images selected.'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: const Text('Pick Images'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              child: const Text('CelebRate'),
            ),
          ],
        ),
      ),
    );
  }
}
