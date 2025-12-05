// lib/features/kyc/kyc_service.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/crypto/encryption/aes_gcm_wrapper.dart';
import '../../core/crypto/crypto_utils.dart';

/// KYC Service for client-side encrypted document management
class KycService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AesGcmWrapper _encryption = AesGcmWrapper();

  static const String _kycKeyStorageKey = 'kyc_encryption_key';
  static const String _kycStatusKey = 'kyc_status';
  static const String _kycDataKey = 'kyc_encrypted_data';

  /// Initialize KYC encryption key
  Future<void> initialize() async {
    final existingKey = await _secureStorage.read(key: _kycKeyStorageKey);
    if (existingKey == null) {
      // Generate new encryption key for KYC data
      final key = _generateRandomBytes(32);
      await _secureStorage.write(
        key: _kycKeyStorageKey,
        value: bytesToHex(key),
      );
    }
  }

  /// Get KYC encryption key
  Future<Uint8List> _getKycKey() async {
    final keyHex = await _secureStorage.read(key: _kycKeyStorageKey);
    if (keyHex == null) {
      throw Exception('KYC encryption key not found');
    }
    return hexToBytes(keyHex);
  }

  /// Generate random bytes
  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }

  /// Encrypt and store KYC document
  Future<void> storeDocument({
    required String documentType,
    required Uint8List documentData,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final key = await _getKycKey();
      
      // Encrypt document data
      final encrypted = await _encryption.encrypt(
        documentData,
        key,
        associatedData: Uint8List.fromList(documentType.codeUnits),
      );

      // Store encrypted document
      final documentKey = 'kyc_doc_$documentType';
      await _secureStorage.write(
        key: documentKey,
        value: encrypted.base64,
      );

      // Store metadata (encrypted)
      final metadataJson = metadata.toString();
      final encryptedMetadata = await _encryption.encrypt(
        Uint8List.fromList(metadataJson.codeUnits),
        key,
      );
      
      await _secureStorage.write(
        key: '${documentKey}_metadata',
        value: encryptedMetadata.base64,
      );

      debugPrint('KYC document stored: $documentType');
    } catch (e) {
      throw Exception('Failed to store KYC document: $e');
    }
  }

  /// Retrieve and decrypt KYC document
  Future<Uint8List?> getDocument(String documentType) async {
    try {
      final key = await _getKycKey();
      final documentKey = 'kyc_doc_$documentType';
      
      final encryptedBase64 = await _secureStorage.read(key: documentKey);
      if (encryptedBase64 == null) return null;

      final encrypted = Base64Encrypted.fromBase64(encryptedBase64);
      
      return await _encryption.decrypt(
        encrypted,
        key,
        associatedData: Uint8List.fromList(documentType.codeUnits),
      );
    } catch (e) {
      throw Exception('Failed to retrieve KYC document: $e');
    }
  }

  /// Get KYC status
  Future<KycStatus> getStatus() async {
    final status = await _secureStorage.read(key: _kycStatusKey);
    switch (status) {
      case 'pending':
        return KycStatus.pending;
      case 'verified':
        return KycStatus.verified;
      case 'rejected':
        return KycStatus.rejected;
      default:
        return KycStatus.notStarted;
    }
  }

  /// Update KYC status
  Future<void> updateStatus(KycStatus status) async {
    await _secureStorage.write(
      key: _kycStatusKey,
      value: status.toString().split('.').last,
    );
  }

  /// Submit KYC for verification
  Future<void> submitForVerification({
    required String fullName,
    required String dateOfBirth,
    required String nationality,
    required String documentNumber,
    required String documentType,
  }) async {
    try {
      // In production, this would send encrypted data to backend
      // For now, just update status
      await updateStatus(KycStatus.pending);
      
      // Store submission data (encrypted)
      final key = await _getKycKey();
      final submissionData = {
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'nationality': nationality,
        'documentNumber': documentNumber,
        'documentType': documentType,
        'submittedAt': DateTime.now().toIso8601String(),
      };

      final dataJson = submissionData.toString();
      final encrypted = await _encryption.encrypt(
        Uint8List.fromList(dataJson.codeUnits),
        key,
      );

      await _secureStorage.write(
        key: _kycDataKey,
        value: encrypted.base64,
      );

      debugPrint('KYC submitted for verification');
    } catch (e) {
      throw Exception('Failed to submit KYC: $e');
    }
  }

  /// Delete all KYC data
  Future<void> deleteAllKycData() async {
    await _secureStorage.delete(key: _kycKeyStorageKey);
    await _secureStorage.delete(key: _kycStatusKey);
    await _secureStorage.delete(key: _kycDataKey);
    
    // Delete all document keys
    final allKeys = await _secureStorage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith('kyc_doc_')) {
        await _secureStorage.delete(key: key);
      }
    }
  }

  /// Check if KYC is required
  bool isKycRequired() {
    // In production, this would check transaction limits, jurisdiction, etc.
    return true;
  }

  /// Get KYC completion percentage
  Future<int> getCompletionPercentage() async {
    final status = await getStatus();
    switch (status) {
      case KycStatus.notStarted:
        return 0;
      case KycStatus.pending:
        return 50;
      case KycStatus.verified:
        return 100;
      case KycStatus.rejected:
        return 25;
    }
  }
}

/// KYC Status enum
enum KycStatus {
  notStarted,
  pending,
  verified,
  rejected,
}

extension KycStatusX on KycStatus {
  String get displayName {
    switch (this) {
      case KycStatus.notStarted:
        return 'Not Started';
      case KycStatus.pending:
        return 'Pending Review';
      case KycStatus.verified:
        return 'Verified';
      case KycStatus.rejected:
        return 'Rejected';
    }
  }

  String get description {
    switch (this) {
      case KycStatus.notStarted:
        return 'Complete KYC to unlock all features';
      case KycStatus.pending:
        return 'Your documents are being reviewed';
      case KycStatus.verified:
        return 'Your identity has been verified';
      case KycStatus.rejected:
        return 'Please resubmit your documents';
    }
  }
}
