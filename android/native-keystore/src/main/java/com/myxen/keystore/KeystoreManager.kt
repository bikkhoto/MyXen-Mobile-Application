package com.myxen.keystore

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Log
import org.bouncycastle.jce.provider.BouncyCastleProvider
import java.security.*
import java.security.spec.ECGenParameterSpec
import java.util.Base64
import kotlinx.coroutines.*

/**
 * KeystoreManager - Main Singleton for Hardware-Backed Key Management
 * 
 * This class is responsible for:
 * 1. Detecting hardware capabilities (StrongBox, KeyStore)
 * 2. Generating Ed25519 keypairs in hardware or fallback mode
 * 3. Signing messages with hardware-protected keys
 * 4. Managing key lifecycle (create, retrieve, delete)
 * 5. Coordinating with ScryptFallback for software encryption
 * 
 * SECURITY PRINCIPLES:
 * - Private keys NEVER leave hardware boundary in hardware mode
 * - All sensitive data zeroized after use
 * - No private key material in logs
 * - Biometric authentication enforced when available
 * 
 * THREAD SAFETY:
 * - All public methods are thread-safe
 * - Uses synchronized blocks where needed
 * - Async operations use Kotlin coroutines
 * 
 * COPILOT INSTRUCTIONS:
 * Implement the following TODO sections:
 * 1. Hardware capability detection (StrongBox, KeyStore)
 * 2. Ed25519 keypair generation using AndroidKeyStore or BouncyCastle
 * 3. Digital signature generation with biometric prompt
 * 4. Key retrieval and deletion
 * 5. Backup/restore coordination with ScryptFallback
 * 6. Error handling with proper error codes
 * 7. Memory zeroization for sensitive byte arrays
 */
class KeystoreManager private constructor(private val context: Context) {
    
    companion object {
        private const val TAG = Constants.TAG
        
        @Volatile
        private var instance: KeystoreManager? = null
        
        /**
         * Get singleton instance of KeystoreManager
         * 
         * @param context Application context
         * @return KeystoreManager instance
         */
        fun getInstance(context: Context): KeystoreManager {
            return instance ?: synchronized(this) {
                instance ?: KeystoreManager(context.applicationContext).also { instance = it }
            }
        }
    }
    
    // ========== INITIALIZATION ==========
    
    private val keyStore: KeyStore
    private val scryptFallback: ScryptFallback
    private val packageManager: PackageManager
    
    init {
        // Initialize BouncyCastle provider for Ed25519 support
        if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
            Security.addProvider(BouncyCastleProvider())
        }
        
        // Load Android KeyStore
        keyStore = KeyStore.getInstance(Constants.ANDROID_KEYSTORE_PROVIDER).apply {
            load(null)
        }
        
        scryptFallback = ScryptFallback(context)
        packageManager = context.packageManager
        
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "KeystoreManager initialized")
            Log.d(TAG, "Hardware capabilities: ${getHardwareCapabilities()}")
        }
    }
    
    // ========== CAPABILITY DETECTION ==========
    
    /**
     * Check if device supports hardware keystore
     * 
     * TODO: Implement detection logic
     * - Check Android version (API 23+)
     * - Verify KeyStore provider is available
     * - Test key generation (may fail on some devices)
     * 
     * @return true if hardware keystore available and functional
     */
    fun isHardwareKeystoreAvailable(): Boolean {
        // TODO: Implement hardware detection
        // Check API level >= 23
        // Try creating a test key and signing
        // Return true only if fully functional
        
        return false // Placeholder
    }
    
    /**
     * Check if device supports StrongBox
     * 
     * TODO: Implement StrongBox detection
     * - Check API level >= 28
     * - Use PackageManager.hasSystemFeature(FEATURE_STRONGBOX_KEYSTORE)
     * - Verify with test key generation using setIsStrongBoxBacked(true)
     * 
     * @return true if StrongBox available
     */
    fun isStrongBoxAvailable(): Boolean {
        // TODO: Implement StrongBox detection
        // if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return false
        // return packageManager.hasSystemFeature(PackageManager.FEATURE_STRONGBOX_KEYSTORE)
        
        return false // Placeholder
    }
    
    /**
     * Get detailed hardware capabilities
     * 
     * @return Map containing capability information
     */
    fun getHardwareCapabilities(): Map<String, Any> {
        return mapOf(
            "hardwareAvailable" to isHardwareKeystoreAvailable(),
            "details" to mapOf(
                "android" to mapOf(
                    "strongboxAvailable" to isStrongBoxAvailable(),
                    "keystoreAvailable" to isHardwareKeystoreAvailable(),
                    "apiLevel" to Build.VERSION.SDK_INT
                )
            )
        )
    }
    
    // ========== KEY GENERATION ==========
    
    /**
     * Generate new Ed25519 keypair
     * 
     * Attempts hardware generation first, falls back to software if unavailable.
     * 
     * TODO: Implement key generation flow
     * 1. Check hardware availability
     * 2. If hardware available:
     *    - Generate Ed25519 keypair in AndroidKeyStore
     *    - Use StrongBox if available (setIsStrongBoxBacked(true))
     *    - Set user authentication required (biometric)
     *    - Set key validity parameters
     * 3. If hardware not available:
     *    - Generate Ed25519 keypair using BouncyCastle
     *    - Encrypt private key using ScryptFallback
     *    - Store encrypted key in secure storage
     * 4. Return public key and mode
     * 
     * @param label Unique identifier for this keypair
     * @return Map containing status, mode, publicKey, algorithm
     * @throws KeystoreException on failure
     */
    suspend fun generateKey(label: String): Map<String, Any> = withContext(Dispatchers.IO) {
        try {
            if (BuildConfig.DEBUG) {
                Log.d(TAG, "Generating key with label: $label")
            }
            
            // Check if key already exists
            if (hasKey(label)) {
                throw KeystoreException(
                    Constants.ERR_UNKNOWN,
                    "Key with label '$label' already exists"
                )
            }
            
            // TODO: Implement hardware key generation
            val hardwareAvailable = isHardwareKeystoreAvailable()
            
            if (hardwareAvailable) {
                // TODO: Generate key in AndroidKeyStore
                // 1. Create KeyGenParameterSpec
                // 2. Set algorithm, key size, purposes
                // 3. Set StrongBox backed if available
                // 4. Set user authentication required
                // 5. Generate keypair
                // 6. Extract public key
                // 7. Return result with MODE_HARDWARE
                
                throw KeystoreException(
                    Constants.ERR_HW_CREATION_FAILED,
                    "Hardware key generation not implemented"
                )
            } else {
                // TODO: Generate key in software fallback
                // 1. Use BouncyCastle to generate Ed25519 keypair
                // 2. Encrypt private key with ScryptFallback
                // 3. Store encrypted blob securely
                // 4. Store public key metadata
                // 5. Return result with MODE_SOFTWARE_FALLBACK
                
                throw KeystoreException(
                    Constants.ERR_HW_NOT_AVAILABLE,
                    "Software fallback generation not implemented"
                )
            }
            
        } catch (e: KeystoreException) {
            throw e
        } catch (e: Exception) {
            Log.e(TAG, "Key generation failed", e)
            throw KeystoreException(
                Constants.ERR_UNKNOWN,
                "Key generation failed: ${e.message}",
                e
            )
        }
    }
    
    // ========== KEY RETRIEVAL ==========
    
    /**
     * Check if key exists
     * 
     * TODO: Implement existence check
     * - Check in AndroidKeyStore
     * - Check in secure storage (fallback keys)
     * - Return exists flag and mode
     * 
     * @param label Key identifier
     * @return true if key exists
     */
    fun hasKey(label: String): Boolean {
        // TODO: Implement key existence check
        // Check keyStore.containsAlias(label) for hardware keys
        // Check secure storage for fallback keys
        
        return false // Placeholder
    }
    
    /**
     * Get key information
     * 
     * @param label Key identifier
     * @return Map containing exists flag and mode
     */
    fun getKeyInfo(label: String): Map<String, Any> {
        val exists = hasKey(label)
        val mode = if (exists) {
            // TODO: Determine if key is hardware or fallback
            Constants.MODE_HARDWARE
        } else {
            null
        }
        
        return mapOf(
            "exists" to exists,
            "mode" to mode
        ).filterValues { it != null }
    }
    
    /**
     * Get public key for given label
     * 
     * TODO: Implement public key retrieval
     * 1. Check if key exists
     * 2. If hardware key:
     *    - Retrieve from AndroidKeyStore
     *    - Extract public key bytes
     * 3. If fallback key:
     *    - Retrieve from secure storage
     * 4. Return as hex-encoded string
     * 
     * @param label Key identifier
     * @return Map containing publicKey (hex-encoded)
     * @throws KeystoreException if key not found
     */
    fun getPublicKey(label: String): Map<String, String> {
        if (!hasKey(label)) {
            throw KeystoreException(
                Constants.ERR_KEY_NOT_FOUND,
                "Key with label '$label' not found"
            )
        }
        
        // TODO: Implement public key retrieval
        // 1. Load key from KeyStore or storage
        // 2. Extract public key bytes
        // 3. Encode as hex
        // 4. Return in map
        
        throw KeystoreException(
            Constants.ERR_UNKNOWN,
            "Public key retrieval not implemented"
        )
    }
    
    // ========== SIGNING ==========
    
    /**
     * Sign message with private key
     * 
     * This is the core cryptographic operation. May trigger biometric prompt.
     * 
     * TODO: Implement signing flow
     * 1. Check if key exists
     * 2. Decode message from base64
     * 3. If hardware key:
     *    - Show biometric prompt
     *    - Load private key from KeyStore
     *    - Sign using Signature API
     * 4. If fallback key:
     *    - Decrypt private key using ScryptFallback
     *    - Sign using BouncyCastle
     *    - Zeroize decrypted key immediately
     * 5. Encode signature as base64
     * 6. Return signature
     * 
     * @param label Key identifier
     * @param message Base64-encoded message to sign
     * @return Map containing signature (base64-encoded)
     * @throws KeystoreException on failure or user cancellation
     */
    suspend fun sign(label: String, message: String): Map<String, String> = withContext(Dispatchers.IO) {
        if (!hasKey(label)) {
            throw KeystoreException(
                Constants.ERR_KEY_NOT_FOUND,
                "Key with label '$label' not found"
            )
        }
        
        try {
            // TODO: Decode message from base64
            // val messageBytes = Base64.getDecoder().decode(message)
            
            // TODO: Determine key mode (hardware vs fallback)
            val isHardware = true // Placeholder
            
            if (isHardware) {
                // TODO: Implement hardware signing
                // 1. Show biometric prompt using BiometricPrompt API
                // 2. Load private key from AndroidKeyStore
                // 3. Initialize Signature with key
                // 4. Sign message bytes
                // 5. Encode signature as base64
                // 6. Return result
                
                throw KeystoreException(
                    Constants.ERR_SIGN_FAILED,
                    "Hardware signing not implemented"
                )
            } else {
                // TODO: Implement software fallback signing
                // 1. Decrypt private key from storage
                // 2. Load key into BouncyCastle signer
                // 3. Sign message
                // 4. Zeroize decrypted key bytes
                // 5. Encode signature as base64
                // 6. Return result
                
                throw KeystoreException(
                    Constants.ERR_SIGN_FAILED,
                    "Software signing not implemented"
                )
            }
            
        } catch (e: KeystoreException) {
            throw e
        } catch (e: Exception) {
            Log.e(TAG, "Signing failed", e)
            throw KeystoreException(
                Constants.ERR_SIGN_FAILED,
                "Signing operation failed: ${e.message}",
                e
            )
        }
    }
    
    // ========== KEY DELETION ==========
    
    /**
     * Delete keypair
     * 
     * TODO: Implement key deletion
     * 1. Check if key exists
     * 2. If hardware key:
     *    - Delete from AndroidKeyStore
     * 3. If fallback key:
     *    - Delete encrypted blob from storage
     *    - Delete metadata
     * 4. Return success
     * 
     * @param label Key identifier
     * @return Map containing status
     * @throws KeystoreException if key not found
     */
    fun deleteKey(label: String): Map<String, String> {
        if (!hasKey(label)) {
            throw KeystoreException(
                Constants.ERR_KEY_NOT_FOUND,
                "Key with label '$label' not found"
            )
        }
        
        // TODO: Implement key deletion
        // keyStore.deleteEntry(label) for hardware keys
        // Delete from secure storage for fallback keys
        
        return mapOf("status" to "OK")
    }
    
    // ========== BACKUP & RESTORE ==========
    
    /**
     * Export encrypted backup of key material
     * 
     * Only works for software fallback keys. Hardware keys cannot be exported by design.
     * 
     * TODO: Implement backup export
     * 1. Check if key exists and is fallback mode
     * 2. Retrieve private key material (encrypted)
     * 3. Re-encrypt with user passphrase using scrypt
     * 4. Create backup blob with metadata
     * 5. Encode as base64 JSON
     * 6. Return blob and metadata
     * 
     * @param label Key identifier
     * @param passphrase User-provided encryption passphrase
     * @param scryptParams Optional scrypt parameters (defaults to PRODUCTION)
     * @return Map containing blob (base64) and metadata
     * @throws KeystoreException if hardware key or other error
     */
    suspend fun exportEncryptedBackup(
        label: String,
        passphrase: String,
        scryptParams: ScryptParams = ScryptParams.PRODUCTION
    ): Map<String, Any> = withContext(Dispatchers.IO) {
        
        if (!hasKey(label)) {
            throw KeystoreException(
                Constants.ERR_KEY_NOT_FOUND,
                "Key with label '$label' not found"
            )
        }
        
        // TODO: Implement backup export
        // 1. Verify key is in fallback mode (hardware keys cannot be exported)
        // 2. Load key material
        // 3. Use ScryptFallback.encryptBackup()
        // 4. Create JSON structure with metadata
        // 5. Return base64-encoded blob
        
        throw KeystoreException(
            Constants.ERR_UNKNOWN,
            "Backup export not implemented"
        )
    }
    
    /**
     * Import encrypted backup
     * 
     * Decrypts backup and optionally migrates to hardware if available.
     * 
     * TODO: Implement backup import
     * 1. Parse backup blob JSON
     * 2. Validate version and format
     * 3. Use ScryptFallback.decryptBackup()
     * 4. Check if hardware available
     * 5. If hardware available:
     *    - Generate new hardware key
     *    - Store backup encrypted with hardware key
     *    - Return MODE_HARDWARE
     * 6. If hardware not available:
     *    - Store as fallback key
     *    - Return MODE_SOFTWARE_FALLBACK
     * 7. Return success, mode, and public key
     * 
     * @param blob Base64-encoded backup blob
     * @param passphrase User passphrase for decryption
     * @return Map containing success, migratedTo, publicKey, label
     * @throws KeystoreException on decryption failure or invalid backup
     */
    suspend fun importEncryptedBackup(
        blob: String,
        passphrase: String
    ): Map<String, Any> = withContext(Dispatchers.IO) {
        
        try {
            // TODO: Implement backup import
            // 1. Decode base64 blob
            // 2. Parse JSON structure
            // 3. Extract scrypt params, salt, nonce, ciphertext
            // 4. Use ScryptFallback.decryptBackup()
            // 5. Validate decrypted key material
            // 6. Attempt hardware migration if available
            // 7. Store key
            // 8. Return result
            
            throw KeystoreException(
                Constants.ERR_INVALID_BACKUP,
                "Backup import not implemented"
            )
            
        } catch (e: KeystoreException) {
            throw e
        } catch (e: Exception) {
            Log.e(TAG, "Backup import failed", e)
            throw KeystoreException(
                Constants.ERR_DECRYPT_FAILED,
                "Failed to decrypt backup: ${e.message}",
                e
            )
        }
    }
    
    // ========== MIGRATION ==========
    
    /**
     * Migrate key from software fallback to hardware
     * 
     * Requires user consent. Creates new hardware key and migrates encrypted material.
     * 
     * TODO: Implement migration flow
     * 1. Verify key exists and is in fallback mode
     * 2. Check hardware availability
     * 3. Decrypt existing private key
     * 4. Generate new hardware keypair
     * 5. Re-encrypt sensitive material with hardware key
     * 6. Delete old fallback key
     * 7. Return migration result
     * 
     * @param label Key identifier
     * @return Map containing status, fromMode, toMode, publicKey
     * @throws KeystoreException if migration fails
     */
    suspend fun migrateKey(label: String): Map<String, Any> = withContext(Dispatchers.IO) {
        
        if (!hasKey(label)) {
            throw KeystoreException(
                Constants.ERR_KEY_NOT_FOUND,
                "Key with label '$label' not found"
            )
        }
        
        if (!isHardwareKeystoreAvailable()) {
            throw KeystoreException(
                Constants.ERR_HW_NOT_AVAILABLE,
                "Hardware keystore not available for migration"
            )
        }
        
        // TODO: Implement migration
        // 1. Export current key as backup
        // 2. Generate new hardware key
        // 3. Import backup encrypted with hardware key
        // 4. Verify migration success
        // 5. Delete old fallback key
        // 6. Return result
        
        throw KeystoreException(
            Constants.ERR_UNKNOWN,
            "Key migration not implemented"
        )
    }
    
    // ========== UTILITY METHODS ==========
    
    /**
     * Zeroize sensitive byte array
     * 
     * Overwrites all bytes with zeros to prevent recovery by garbage collector.
     * ALWAYS call this after using private key bytes or other sensitive data.
     * 
     * @param data Byte array to zeroize
     */
    private fun zeroize(data: ByteArray) {
        data.fill(0)
    }
    
    /**
     * Convert byte array to hex string
     * 
     * @param bytes Input bytes
     * @return Hex-encoded string
     */
    private fun bytesToHex(bytes: ByteArray): String {
        return bytes.joinToString("") { "%02x".format(it) }
    }
    
    /**
     * Convert hex string to byte array
     * 
     * @param hex Hex-encoded string
     * @return Decoded bytes
     */
    private fun hexToBytes(hex: String): ByteArray {
        require(hex.length % 2 == 0) { "Hex string must have even length" }
        return hex.chunked(2)
            .map { it.toInt(16).toByte() }
            .toByteArray()
    }
    
    /**
     * Sanitize value for logging (prevent secret leakage)
     * 
     * @param value Value to sanitize
     * @return Safe string for logging
     */
    private fun sanitize(value: Any?): String {
        return when (value) {
            is ByteArray -> "[${value.size} bytes]"
            is Map<*, *> -> value.mapValues { sanitize(it.value) }.toString()
            else -> value.toString()
        }
    }
}
