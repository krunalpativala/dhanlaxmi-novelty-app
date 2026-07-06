part of 'main.dart';

Future<String?> _pickAndUploadImage(BuildContext context, String folder) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    _showUploadError(context, 'Please log in before uploading images.');
    return null;
  }

  XFile? picked;
  try {
    picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 75,
    );
  } on PlatformException catch (error) {
    debugPrint('Image picker failed: ${error.code} ${error.message}');
    if (context.mounted) {
      _showUploadError(
        context,
        'Gallery could not open. Allow photo permission and try again.',
      );
    }
    return null;
  }

  if (picked == null) {
    return null;
  }

  try {
    final fileBytes = await picked.readAsBytes();
    const maxUploadBytes = 5 * 1024 * 1024;
    if (fileBytes.length >= maxUploadBytes) {
      if (context.mounted) {
        _showUploadError(
          context,
          'Image must be smaller than 5 MB. Please select a different image.',
        );
      }
      return null;
    }

    final contentType = _contentTypeForImage(picked);
    if (contentType == null) {
      if (context.mounted) {
        _showUploadError(
          context,
          'Please select a JPG, PNG, GIF, or WEBP image.',
        );
      }
      return null;
    }

    final safeFolder = folder.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final fileExtension = _extensionForContentType(contentType);
    final fileName =
        '${user.uid}_${DateTime.now().microsecondsSinceEpoch}.$fileExtension';

    final upload = await _uploadImageToCloudinary(
      folder: safeFolder,
      fileName: fileName,
      fileBytes: fileBytes,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image upload thai gai.')));
    }
    return upload;
  } catch (error) {
    debugPrint('Image upload failed: $error');
    if (context.mounted) {
      _showUploadError(context, 'Image upload failed. Please try again.');
    }
    return null;
  }
}

Future<String> _uploadImageToCloudinary({
  required String folder,
  required String fileName,
  required Uint8List fileBytes,
}) async {
  final uri = Uri.https('api.cloudinary.com', '/v1_1/dyonkudly/image/upload');
  final publicId = fileName.replaceFirst(RegExp(r'\.[^.]+$'), '');
  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = 'Dhanlaxmi'
    ..fields['folder'] = folder
    ..fields['public_id'] = publicId
    ..files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );

  debugPrint('Trying Cloudinary image upload: folder=$folder file=$fileName');

  final response = await http.Response.fromStream(await request.send());
  if (response.statusCode < 200 || response.statusCode >= 300) {
    debugPrint(
      'Cloudinary upload failed: ${response.statusCode} ${response.body}',
    );
    throw Exception(_friendlyCloudinaryError(response));
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final secureUrl = data['secure_url']?.toString();
  if (secureUrl == null || secureUrl.isEmpty) {
    throw Exception('Cloudinary image URL missing.');
  }

  return secureUrl;
}

String? _contentTypeForImage(XFile image) {
  final mimeType = image.mimeType?.toLowerCase();
  if (mimeType != null && mimeType.startsWith('image/')) {
    return mimeType;
  }

  final path = image.path.toLowerCase();
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (path.endsWith('.png')) {
    return 'image/png';
  }
  if (path.endsWith('.gif')) {
    return 'image/gif';
  }
  if (path.endsWith('.webp')) {
    return 'image/webp';
  }
  return null;
}

String _extensionForContentType(String contentType) {
  switch (contentType) {
    case 'image/png':
      return 'png';
    case 'image/gif':
      return 'gif';
    case 'image/webp':
      return 'webp';
    default:
      return 'jpg';
  }
}

String _friendlyCloudinaryError(http.Response response) {
  try {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final message = (data['error'] as Map<String, dynamic>?)?['message']
        ?.toString();
    if (message != null && message.isNotEmpty) {
      return 'Cloudinary upload failed: $message';
    }
  } catch (_) {
    // Fall back to the generic message below.
  }

  if (response.statusCode == 400 || response.statusCode == 401) {
    return 'Check your Cloudinary cloud name and upload preset.';
  }
  return 'Cloudinary upload failed. Please try again.';
}

void _showUploadError(BuildContext context, String message) {
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
}
