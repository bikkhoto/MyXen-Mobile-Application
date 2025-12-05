// lib/features/emergency/emergency_service.dart
import 'dart:convert';

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/crypto/encryption/aes_gcm_wrapper.dart';
import '../../core/crypto/crypto_utils.dart';

/// Emergency SOS Service
/// 
/// Allows users to set up emergency contacts and trigger SOS
/// with encrypted wallet recovery information
class EmergencyService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AesGcmWrapper _encryption = AesGcmWrapper();

  static const String _emergencyKeyStorageKey = 'emergency_encryption_key';
  static const String _emergencyContactsKey = 'emergency_contacts';
  static const String _sosEnabledKey = 'sos_enabled';
  static const String _sosPayloadKey = 'sos_encrypted_payload';

  /// Initialize emergency service
  Future<void> initialize() async {
    final existingKey = await _secureStorage.read(key: _emergencyKeyStorageKey);
    if (existingKey == null) {
      final key = _generateRandomBytes(32);
      await _secureStorage.write(
        key: _emergencyKeyStorageKey,
        value: bytesToHex(key),
      );
    }
  }

  /// Get encryption key
  Future<Uint8List> _getKey() async {
    final keyHex = await _secureStorage.read(key: _emergencyKeyStorageKey);
    if (keyHex == null) {
      throw Exception('Emergency encryption key not found');
    }
    return hexToBytes(keyHex);
  }

  /// Generate random bytes
  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }

  /// Check if SOS is enabled
  Future<bool> isSosEnabled() async {
    final enabled = await _secureStorage.read(key: _sosEnabledKey);
    return enabled == 'true';
  }

  /// Enable/disable SOS
  Future<void> setSosEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _sosEnabledKey,
      value: enabled.toString(),
    );
  }

  /// Add emergency contact
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    final contacts = await getEmergencyContacts();
    contacts.add(contact);
    await _saveContacts(contacts);
  }

  /// Remove emergency contact
  Future<void> removeEmergencyContact(String email) async {
    final contacts = await getEmergencyContacts();
    contacts.removeWhere((c) => c.email == email);
    await _saveContacts(contacts);
  }

  /// Get all emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    final contactsJson = await _secureStorage.read(key: _emergencyContactsKey);
    if (contactsJson == null) return [];

    try {
      final key = await _getKey();
      final encrypted = Base64Encrypted.fromBase64(contactsJson);
      final decrypted = await _encryption.decrypt(encrypted, key);
      
      final jsonString = String.fromCharCodes(decrypted);
      // Parse JSON and convert to list of contacts
      final parsed = jsonDecode(jsonString) as List<dynamic>;
      return parsed.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save contacts
  Future<void> _saveContacts(List<EmergencyContact> contacts) async {
    try {
      final key = await _getKey();
      final jsonString = contacts.map((c) => c.toJson()).toList().toString();
      final encrypted = await _encryption.encrypt(
        Uint8List.fromList(jsonString.codeUnits),
        key,
      );
      
      await _secureStorage.write(
        key: _emergencyContactsKey,
        value: encrypted.base64,
      );
    } catch (e) {
      throw Exception('Failed to save contacts: $e');
    }
  }

  /// Create emergency payload
  /// 
  /// This creates an encrypted payload containing recovery information
  /// that can be sent to emergency contacts
  Future<String> createEmergencyPayload({
    required String recoveryPhrase,
    required String walletAddress,
    String? additionalInfo,
  }) async {
    try {
      final key = await _getKey();
      
      final payload = {
        'recoveryPhrase': recoveryPhrase,
        'walletAddress': walletAddress,
        'additionalInfo': additionalInfo,
        'createdAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      final payloadJson = payload.toString();
      final encrypted = await _encryption.encrypt(
        Uint8List.fromList(payloadJson.codeUnits),
        key,
      );

      // Store encrypted payload
      await _secureStorage.write(
        key: _sosPayloadKey,
        value: encrypted.base64,
      );

      return encrypted.base64;
    } catch (e) {
      throw Exception('Failed to create emergency payload: $e');
    }
  }

  /// Trigger SOS
  /// 
  /// Sends encrypted recovery information to emergency contacts
  Future<void> triggerSos({
    required String reason,
    String? additionalMessage,
  }) async {
    try {
      final enabled = await isSosEnabled();
      if (!enabled) {
        throw Exception('SOS is not enabled');
      }

      final contacts = await getEmergencyContacts();
      if (contacts.isEmpty) {
        throw Exception('No emergency contacts configured');
      }

      final payload = await _secureStorage.read(key: _sosPayloadKey);
      if (payload == null) {
        throw Exception('Emergency payload not found');
      }

      // In production, this would send emails/SMS to contacts
      // For now, just log
      debugPrint('SOS triggered: $reason');
      debugPrint('Contacts notified: ${contacts.length}');
      debugPrint('Payload: ${payload.substring(0, 20)}...');

      // Record SOS event
      await _recordSosEvent(reason, additionalMessage);
    } catch (e) {
      throw Exception('Failed to trigger SOS: $e');
    }
  }

  /// Record SOS event
  Future<void> _recordSosEvent(String reason, String? message) async {
    final event = {
      'reason': reason,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Store in secure storage
    final eventKey = 'sos_event_${DateTime.now().millisecondsSinceEpoch}';
    await _secureStorage.write(
      key: eventKey,
      value: event.toString(),
    );
  }

  /// Get SOS history
  Future<List<Map<String, dynamic>>> getSosHistory() async {
    final allKeys = await _secureStorage.readAll();
    final events = <Map<String, dynamic>>[];

    for (final entry in allKeys.entries) {
      if (entry.key.startsWith('sos_event_')) {
        // Parse event
        // Simplified for now
        events.add({'key': entry.key, 'data': entry.value});
      }
    }

    return events;
  }

  /// Clear all emergency data
  Future<void> clearAllEmergencyData() async {
    await _secureStorage.delete(key: _emergencyKeyStorageKey);
    await _secureStorage.delete(key: _emergencyContactsKey);
    await _secureStorage.delete(key: _sosEnabledKey);
    await _secureStorage.delete(key: _sosPayloadKey);

    // Delete all SOS events
    final allKeys = await _secureStorage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith('sos_event_')) {
        await _secureStorage.delete(key: key);
      }
    }
  }
}

/// Emergency Contact model
class EmergencyContact {
  final String name;
  final String email;
  final String? phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.email,
    required this.relationship, this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'relationship': relationship,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      relationship: json['relationship'] as String,
    );
  }
}
