// lib/features/kyc/kyc_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/auth/biometric_service.dart';
import 'kyc_service.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final KycService _kycService = KycService();
  final BiometricService _biometricService = BiometricService();
  final ImagePicker _imagePicker = ImagePicker();

  KycStatus _status = KycStatus.notStarted;
  int _completionPercentage = 0;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _documentNumberController = TextEditingController();
  
  String _documentType = 'passport';
  File? _frontImage;
  File? _backImage;
  File? _selfieImage;

  @override
  void initState() {
    super.initState();
    _loadKycStatus();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadKycStatus() async {
    setState(() => _isLoading = true);
    try {
      await _kycService.initialize();
      final status = await _kycService.getStatus();
      final percentage = await _kycService.getCompletionPercentage();
      
      if (mounted) {
        setState(() {
          _status = status;
          _completionPercentage = percentage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(ImageType type) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        switch (type) {
          case ImageType.front:
            _frontImage = File(image.path);
            break;
          case ImageType.back:
            _backImage = File(image.path);
            break;
          case ImageType.selfie:
            _selfieImage = File(image.path);
            break;
        }
      });
    }
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;

    if (_frontImage == null || _selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Require biometric authentication
    final authenticated = await _biometricService.authenticate(
      reason: 'Authenticate to submit KYC documents',
    );

    if (!authenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Store encrypted documents
      await _kycService.storeDocument(
        documentType: '${_documentType}_front',
        documentData: await _frontImage!.readAsBytes(),
        metadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );

      if (_backImage != null) {
        await _kycService.storeDocument(
          documentType: '${_documentType}_back',
          documentData: await _backImage!.readAsBytes(),
          metadata: {'uploadedAt': DateTime.now().toIso8601String()},
        );
      }

      await _kycService.storeDocument(
        documentType: 'selfie',
        documentData: await _selfieImage!.readAsBytes(),
        metadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );

      // Submit for verification
      await _kycService.submitForVerification(
        fullName: _fullNameController.text,
        dateOfBirth: _dobController.text,
        nationality: _nationalityController.text,
        documentNumber: _documentNumberController.text,
        documentType: _documentType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KYC submitted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        await _loadKycStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('KYC Verification'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(),
                  const SizedBox(height: AppTheme.spacingXl),

                  if (_status == KycStatus.notStarted ||
                      _status == KycStatus.rejected) ...[
                    // KYC Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          
                          TextFormField(
                            controller: _dobController,
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              hintText: 'YYYY-MM-DD',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          
                          TextFormField(
                            controller: _nationalityController,
                            decoration: const InputDecoration(
                              labelText: 'Nationality',
                              prefixIcon: Icon(Icons.flag),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: AppTheme.spacingXl),

                          // Document Type
                          const Text(
                            'Identity Document',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          
                          DropdownButtonFormField<String>(
                            initialValue: _documentType,
                            decoration: const InputDecoration(
                              labelText: 'Document Type',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'passport',
                                child: Text('Passport'),
                              ),
                              DropdownMenuItem(
                                value: 'drivers_license',
                                child: Text('Driver\'s License'),
                              ),
                              DropdownMenuItem(
                                value: 'national_id',
                                child: Text('National ID'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _documentType = value!);
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          
                          TextFormField(
                            controller: _documentNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Document Number',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: AppTheme.spacingXl),

                          // Document Upload
                          const Text(
                            'Upload Documents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          
                          _buildImageUpload(
                            'Front of Document',
                            _frontImage,
                            () => _pickImage(ImageType.front),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          
                          _buildImageUpload(
                            'Back of Document',
                            _backImage,
                            () => _pickImage(ImageType.back),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          
                          _buildImageUpload(
                            'Selfie with Document',
                            _selfieImage,
                            () => _pickImage(ImageType.selfie),
                          ),
                          const SizedBox(height: AppTheme.spacingXl),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submitKyc,
                              child: const Text(
                                'Submit for Verification',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    Color color;
    IconData icon;

    switch (_status) {
      case KycStatus.notStarted:
        color = AppTheme.infoColor;
        icon = Icons.info_outline;
        break;
      case KycStatus.pending:
        color = AppTheme.warningColor;
        icon = Icons.pending;
        break;
      case KycStatus.verified:
        color = AppTheme.successColor;
        icon = Icons.verified_user;
        break;
      case KycStatus.rejected:
        color = AppTheme.errorColor;
        icon = Icons.error_outline;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            _status.displayName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            _status.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          LinearProgressIndicator(
            value: _completionPercentage / 100,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            '$_completionPercentage% Complete',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUpload(String label, File? image, VoidCallback onTap) {
    return Card(
      color: AppTheme.surfaceDark,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          image != null ? Icons.check_circle : Icons.camera_alt,
          color: image != null ? AppTheme.successColor : AppTheme.primaryColor,
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        subtitle: Text(
          image != null ? 'Uploaded' : 'Tap to upload',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondaryDark.withValues(alpha: 0.8),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondaryDark,
        ),
      ),
    );
  }
}

enum ImageType { front, back, selfie }
