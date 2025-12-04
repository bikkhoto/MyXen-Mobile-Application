// lib/core/network/api_config.dart

/// API Configuration for MyXen Mobile App
/// 
/// PRODUCTION CONFIGURATION - Updated with actual MYXN token and wallet addresses
class ApiConfig {
  // Network Configuration
  static const bool isProduction = false; // Set to true for mainnet
  
  // Solana Network
  static const String solanaCluster = isProduction ? 'mainnet-beta' : 'devnet';
  
  // RPC Endpoints
  static const String devnetRpc = 'https://api.devnet.solana.com';
  static const String mainnetRpc = 'https://api.mainnet-beta.solana.com';
  static const String recommendedReadRelay = 'https://solana-api.projectserum.com';
  static const String currentRpc = isProduction ? mainnetRpc : devnetRpc;
  
  // MYXN Token Configuration (ACTUAL TOKEN)
  static const String myxnTokenMint = '6S4eDdYXABgtmuk3waLM63U2KHgExcD9mco7MuyG9f5G';
  static const int myxnDecimals = 9;
  static const String myxnSymbol = 'MYXN';
  
  // Official MyXen Wallets
  static const String treasuryWallet = 'Azvjj21uXQzHbM9VHhyDfdbj14HD8Tef7ZuC1p7sEMk9';
  static const String burnWallet = 'HuyT8sNPJMnh9vgJ43PXU4TY696WTWSdh1LBX53ZVox9';
  static const String charityWallet = 'DDoiUCeoUNHHCV5sLT3rgFjLpLUM76tLCUMnAg52o8vK';
  static const String hrWallet = 'Hv8QBqqSfD4nC6N8qZBo7iJE9QiHLnoXJ6sV2hk1XpoR';
  static const String marketingWallet = '4egNUZa2vNBwmc633GAjworDPEJD2F1HK6pSvMnC3WSv';
  static const int myxnTotalSupply = 1000000000; // 1 billion

  // Explorer URLs
  static const String solscanMainnet = 'https://solscan.io';
  static const String solscanDevnet = 'https://solscan.io';
  
  static String get explorerUrl => isProduction ? solscanMainnet : solscanDevnet;

  // Transaction explorer link
  static String getTransactionUrl(String signature) {
    final network = isProduction ? '' : '?cluster=devnet';
    return '$explorerUrl/tx/$signature$network';
  }

  // Account explorer link
  static String getAccountUrl(String address) {
    final network = isProduction ? '' : '?cluster=devnet';
    return '$explorerUrl/account/$address$network';
  }

  // API timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Transaction confirmation
  static const Duration confirmationTimeout = Duration(seconds: 60);
  static const Duration confirmationPollInterval = Duration(seconds: 2);

  // Fee configuration (in lamports)
  static const int defaultPriorityFee = 5000;
  static const int minRentExemption = 890880; // Approximate for token account

  // Rate limiting
  static const int maxRequestsPerSecond = 10;
  static const Duration rateLimitWindow = Duration(seconds: 1);
}
