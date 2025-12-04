// lib/features/emergency/emergency_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/auth/biometric_service.dart';
import 'emergency_service.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  final EmergencyService _emergencyService = EmergencyService();
  final BiometricService _biometricService = BiometricService();

  bool _sosEnabled = false;
  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmergencySettings();
  }

  Future<void> _loadEmergencySettings() async {
    setState(() => _isLoading = true);
    try {
      await _emergencyService.initialize();
      final enabled = await _emergencyService.isSosEnabled();
      final contacts = await _emergencyService.getEmergencyContacts();
      
      if (mounted) {
        setState(() {
          _sosEnabled = enabled;
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleSos(bool value) async {
    if (value && _contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one emergency contact first'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final authenticated = await _biometricService.authenticate(
      reason: 'Authenticate to ${value ? 'enable' : 'disable'} Emergency SOS',
    );

    if (!authenticated) return;

    await _emergencyService.setSosEnabled(value);
    setState(() => _sosEnabled = value);
  }

  Future<void> _addContact() async {
    final contact = await showDialog<EmergencyContact>(
      context: context,
      builder: (context) => const AddContactDialog(),
    );

    if (contact != null) {
      await _emergencyService.addEmergencyContact(contact);
      await _loadEmergencySettings();
    }
  }

  Future<void> _triggerSos() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          'Trigger Emergency SOS?',
          style: TextStyle(color: AppTheme.errorColor),
        ),
        content: const Text(
          'This will send your encrypted recovery information to all emergency contacts. Only use in genuine emergencies.',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Trigger SOS'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final authenticated = await _biometricService.authenticate(
      reason: 'Authenticate to trigger Emergency SOS',
    );

    if (!authenticated) return;

    try {
      await _emergencyService.triggerSos(
        reason: 'Manual SOS trigger',
        additionalMessage: 'Emergency assistance needed',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS triggered! Contacts have been notified.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to trigger SOS: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Emergency SOS'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Banner
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.errorColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.errorColor,
                          size: 32,
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Feature',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.errorColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Only use in genuine emergencies. Your recovery phrase will be sent to emergency contacts.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondaryDark,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),

                  // SOS Toggle
                  Card(
                    color: AppTheme.surfaceDark,
                    child: SwitchListTile(
                      title: const Text(
                        'Enable Emergency SOS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                      subtitle: Text(
                        _sosEnabled
                            ? 'SOS is active'
                            : 'Add contacts and enable SOS',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryDark.withOpacity(0.8),
                        ),
                      ),
                      value: _sosEnabled,
                      onChanged: _toggleSos,
                      activeColor: AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),

                  // Emergency Contacts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                      IconButton(
                        onPressed: _addContact,
                        icon: const Icon(Icons.add_circle),
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  if (_contacts.isEmpty)
                    Card(
                      color: AppTheme.surfaceDark,
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingXl),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.contacts_outlined,
                                size: 48,
                                color: AppTheme.textSecondaryDark.withOpacity(0.5),
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              Text(
                                'No emergency contacts',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondaryDark.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...contacts.map((contact) => Card(
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                          color: AppTheme.surfaceDark,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingSm),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            title: Text(
                              contact.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryDark,
                              ),
                            ),
                            subtitle: Text(
                              '${contact.email}\n${contact.relationship}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondaryDark.withOpacity(0.8),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: AppTheme.errorColor,
                              onPressed: () async {
                                await _emergencyService.removeEmergencyContact(
                                  contact.email,
                                );
                                await _loadEmergencySettings();
                              },
                            ),
                          ),
                        )),
                  const SizedBox(height: AppTheme.spacingXl),

                  // Trigger SOS Button
                  if (_sosEnabled)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _triggerSos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        child: const Text(
                          'TRIGGER EMERGENCY SOS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

/// Add Contact Dialog
class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _relationship = 'family';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceDark,
      title: const Text(
        'Add Emergency Contact',
        style: TextStyle(color: AppTheme.textPrimaryDark),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: const [
                  DropdownMenuItem(value: 'family', child: Text('Family')),
                  DropdownMenuItem(value: 'friend', child: Text('Friend')),
                  DropdownMenuItem(value: 'lawyer', child: Text('Lawyer')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _relationship = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(
                EmergencyContact(
                  name: _nameController.text,
                  email: _emailController.text,
                  phone: _phoneController.text.isEmpty
                      ? null
                      : _phoneController.text,
                  relationship: _relationship,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
