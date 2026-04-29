import 'dart:convert';

abstract class EncryptionService {
  Future<String> encrypt(String plainText);
  Future<String> decrypt(String cipherText);
}

class MockEncryptionService implements EncryptionService {
  @override
  Future<String> encrypt(String plainText) async {
    return base64Encode(utf8.encode(plainText));
  }

  @override
  Future<String> decrypt(String cipherText) async {
    return utf8.decode(base64Decode(cipherText));
  }
}