package com.myxen.keystore

/**
 * Constants for the MyXen Native Keystore Module
 * 
 * This file contains all error codes, configuration constants, and shared values
 * used throughout the keystore implementation.
 */

object Constants {
    // ========== ERROR CODES ==========
    // These error codes are exposed to the bridge layer and must remain stable across versions
    
    const val ERR_HW_NOT_AVAILABLE = "ERR_HW_NOT_AVAILABLE"
    const val ERR_HW_CREATION_FAILED = "ERR_HW_CREATION_FAILED"
    const val ERR_SIGN_FAILED = "ERR_SIGN_FAILED"
    const val ERR_KEY_NOT_FOUND = "ERR_KEY_NOT_FOUND"
    const val ERR_USER_CANCELLED = "ERR_USER_CANCELLED"
    const val ERR_DECRYPT_FAILED = "ERR_DECRYPT_FAILED"
    const val ERR_INVALID_BACKUP = "ERR_INVALID_BACKUP"
    const val ERR_NOT_AUTHORIZED = "ERR_NOT_AUTHORIZED"
    const val ERR_UNKNOWN = "ERR_UNKNOWN"
    
    // ========== KEYSTORE CONFIGURATION ==========
    
    const val ANDROID_KEYSTORE_PROVIDER = "AndroidKeyStore"
    const val KEY_ALGORITHM_EC = "EC"
    const val KEY_ALGORITHM_RSA = "RSA"
    const val SIGNATURE_ALGORITHM = "SHA256withECDSA"
    
    // Ed25519 constants (using BouncyCastle when hardware doesn't support)
    const val ED25519_ALGORITHM = "Ed25519"
    const val ED25519_KEY_SIZE = 256
    const val ED25519_PUBLIC_KEY_SIZE = 32
    const val ED25519_PRIVATE_KEY_SIZE = 32
    const val ED25519_SIGNATURE_SIZE = 64
    
    // ========== SCRYPT PARAMETERS ==========
    
    // CI/Testing parameters (fast, lower security - for automated tests only)
    object ScryptCI {
        const val N = 16384  // 2^14
        const val R = 8
        const val P = 1
        const val SALT_LENGTH = 16
        const val KEY_LENGTH = 32
    }
    
    // Production fallback parameters (secure, acceptable performance)
    object ScryptProduction {
        const val N = 32768  // 2^15
        const val R = 8
        const val P = 1
        const val SALT_LENGTH = 16
        const val KEY_LENGTH = 32
    }
    
    // High security parameters (use only if device performance allows)
    // TODO: Benchmark on lowest-spec target device before enabling
    object ScryptHighSecurity {
        const val N = 65536  // 2^16
        const val R = 8
        const val P = 1
        const val SALT_LENGTH = 16
        const val KEY_LENGTH = 32
    }
    
    // ========== AES-GCM PARAMETERS ==========
    
    const val AES_KEY_SIZE = 256
    const val AES_GCM_NONCE_LENGTH = 12  // 96 bits (recommended for GCM)
    const val AES_GCM_TAG_LENGTH = 128   // 128 bits authentication tag
    
    // ========== BACKUP FORMAT ==========
    
    const val BACKUP_VERSION = 1
    const val BACKUP_ALGORITHM = "Ed25519"
    
    // JSON keys for backup blob structure
    object BackupKeys {
        const val VERSION = "version"
        const val ALGORITHM = "algorithm"
        const val SCRYPT_PARAMS = "scryptParams"
        const val SCRYPT_N = "N"
        const val SCRYPT_R = "r"
        const val SCRYPT_P = "p"
        const val SALT = "salt"
        const val NONCE = "nonce"
        const val CIPHERTEXT = "ciphertext"
        const val MAC = "mac"
    }
    
    // ========== KEYSTORE MODES ==========
    
    const val MODE_HARDWARE = "HARDWARE"
    const val MODE_SOFTWARE_FALLBACK = "SOFTWARE_FALLBACK"
    
    // ========== BIOMETRIC CONFIGURATION ==========
    
    const val BIOMETRIC_PROMPT_TITLE = "Authenticate"
    const val BIOMETRIC_PROMPT_SUBTITLE = "Verify your identity to sign transaction"
    const val BIOMETRIC_PROMPT_DESCRIPTION = "Use your fingerprint or face to authorize this operation"
    const val BIOMETRIC_NEGATIVE_BUTTON = "Use PIN"
    
    // ========== RATE LIMITING ==========
    
    const val MAX_PASSPHRASE_ATTEMPTS = 5
    const val RATE_LIMIT_WINDOW_MS = 60_000L  // 1 minute
    
    // ========== LOGGING ==========
    
    const val TAG = "MyXenKeystore"
    const val TAG_CRYPTO = "MyXenKeystore:Crypto"
    const val TAG_BRIDGE = "MyXenKeystore:Bridge"
    const val TAG_FALLBACK = "MyXenKeystore:Fallback"
    
    // ========== TELEMETRY EVENTS (opt-in) ==========
    
    object TelemetryEvents {
        const val KEY_GENERATED_HW = "keystore.key_generated.hardware"
        const val KEY_GENERATED_SW = "keystore.key_generated.fallback"
        const val SIGN_SUCCESS = "keystore.sign.success"
        const val SIGN_FAILURE = "keystore.sign.failure"
        const val MIGRATION_ATTEMPTED = "keystore.migration.attempted"
        const val MIGRATION_SUCCESS = "keystore.migration.success"
        const val MIGRATION_FAILURE = "keystore.migration.failure"
        const val BACKUP_EXPORTED = "keystore.backup.exported"
        const val BACKUP_IMPORTED = "keystore.backup.imported"
    }
    
    // ========== STORAGE KEYS ==========
    
    object StorageKeys {
        const val KEY_METADATA_PREFIX = "keystore_meta_"
        const val KEY_MODE_SUFFIX = "_mode"
        const val KEY_CREATED_SUFFIX = "_created"
        const val KEY_ALGORITHM_SUFFIX = "_algorithm"
    }
}

/**
 * Exception class for keystore operations
 * 
 * @param code Error code from Constants (e.g., ERR_KEY_NOT_FOUND)
 * @param message Human-readable error message (sanitized, no secrets)
 * @param cause Optional underlying exception
 */
class KeystoreException(
    val code: String,
    message: String,
    cause: Throwable? = null
) : Exception(message, cause) {
    
    override fun toString(): String {
        return "KeystoreException($code): $message"
    }
    
    /**
     * Convert to JSON-friendly map for bridge layer
     */
    fun toMap(): Map<String, Any> {
        return mapOf(
            "code" to code,
            "message" to message.orEmpty()
        )
    }
}

/**
 * Result wrapper for keystore operations
 * Follows Result<T> pattern for type-safe error handling
 */
sealed class KeystoreResult<out T> {
    data class Success<T>(val data: T) : KeystoreResult<T>()
    data class Failure(val exception: KeystoreException) : KeystoreResult<Nothing>()
    
    inline fun <R> map(transform: (T) -> R): KeystoreResult<R> {
        return when (this) {
            is Success -> Success(transform(data))
            is Failure -> this
        }
    }
    
    inline fun onSuccess(action: (T) -> Unit): KeystoreResult<T> {
        if (this is Success) action(data)
        return this
    }
    
    inline fun onFailure(action: (KeystoreException) -> Unit): KeystoreResult<T> {
        if (this is Failure) action(exception)
        return this
    }
}

/**
 * Data class for scrypt parameters
 */
data class ScryptParams(
    val N: Int,
    val r: Int,
    val p: Int,
    val saltLength: Int = Constants.ScryptProduction.SALT_LENGTH,
    val keyLength: Int = Constants.ScryptProduction.KEY_LENGTH
) {
    companion object {
        val CI = ScryptParams(
            N = Constants.ScryptCI.N,
            r = Constants.ScryptCI.R,
            p = Constants.ScryptCI.P
        )
        
        val PRODUCTION = ScryptParams(
            N = Constants.ScryptProduction.N,
            r = Constants.ScryptProduction.R,
            p = Constants.ScryptProduction.P
        )
        
        val HIGH_SECURITY = ScryptParams(
            N = Constants.ScryptHighSecurity.N,
            r = Constants.ScryptHighSecurity.R,
            p = Constants.ScryptHighSecurity.P
        )
    }
    
    fun toMap(): Map<String, Int> {
        return mapOf(
            "N" to N,
            "r" to r,
            "p" to p
        )
    }
}
