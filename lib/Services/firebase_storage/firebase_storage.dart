import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImage(PlatformFile image) async{
  // Create a storage reference
  final path = 'Users/Post-Media/${image.name}';
  // Create a storage reference
  final ref = FirebaseStorage.instance.ref().child(path);
  // Upload the image to storage
  await ref.putFile(File(image.path.toString()));
  // Return the download link
  return await ref.getDownloadURL();
}