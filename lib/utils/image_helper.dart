import 'dart:io';

String getImageName(File? imageFile) {
  if (imageFile == null) return "";
  // Get the file name with extension
  String fileNameWithExtension = imageFile.path.split('/').last;
  // Get the file name without extension
  return fileNameWithExtension.split('.').first;
}

String getImageNameString(String? imageFile) {
  if (imageFile == null) return "";
  // Get the file name with extension
  String fileNameWithExtension = imageFile.split('/').last;
  // Get the file name without extension
  return fileNameWithExtension;
}

String getImageExtension(File? imageFile) {
  if (imageFile == null) return "";
  // Get the file name with extension
  String fileNameWithExtension = imageFile.path.split('/').last;
  // Get the file extension
  return fileNameWithExtension.split('.').last;
}
