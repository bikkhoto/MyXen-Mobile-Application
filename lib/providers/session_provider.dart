// lib/providers/session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to hold the current session PIN (in-memory only)
/// This is required for software-backed encryption where the PIN 
/// is needed to decrypt the seed for every operation.
final sessionPinProvider = StateProvider<String?>((ref) => null);
