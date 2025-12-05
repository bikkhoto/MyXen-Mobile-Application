// lib/core/network/api_config.dart

/// API Configuration for MyXen Mobile App
/// 
/// MAINNET PRODUCTION CONFIGURATION
/// Updated with official MYXN token deployed on Solana Mainnet-Beta
/// Deployment Date: December 5, 2025
class ApiConfig {
  // ─────────────────────────────────────────────────────────────────────────────
  // NETWORK CONFIGURATION
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Set to true for mainnet deployment
  static const bool isProduction = true;
  
  /// Solana cluster identifier
  static const String solanaCluster = isProduction ? 'mainnet-beta' : 'devnet';
  
  // ─────────────────────────────────────────────────────────────────────────────
  // RPC ENDPOINTS
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Devnet RPC endpoint (for testing)
  static const String devnetRpc = 'https://api.devnet.solana.com';
  
  /// Mainnet-Beta RPC endpoint
  static const String mainnetRpc = 'https://api.mainnet-beta.solana.com';
  
  /// Alternative RPC endpoints for fallback
  static const String heliusRpc = 'https://mainnet.helius-rpc.com/?api-key=YOUR_API_KEY';
  static const String quicknodeRpc = 'https://YOUR_ENDPOINT.solana-mainnet.quiknode.pro/YOUR_KEY';
  
  /// Current active RPC endpoint
  static const String currentRpc = isProduction ? mainnetRpc : devnetRpc;
  
  // ─────────────────────────────────────────────────────────────────────────────
  // MYXN TOKEN CONFIGURATION (MAINNET LIVE)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Official MYXN Token Mint Address (Mainnet)
  /// Explorer: https://solscan.io/token/3NVKYBqjuhLzk5FQNBhcExkruJ7qcaZizkD7Q7veyHGH
  static const String myxnTokenMint = '3NVKYBqjuhLzk5FQNBhcExkruJ7qcaZizkD7Q7veyHGH';
  
  /// Token decimals (standard SPL Token)
  static const int myxnDecimals = 9;
  
  /// Token symbol
  static const String myxnSymbol = 'MYXN';
  
  /// Token name
  static const String myxnName = 'MyXen';
  
  /// Total supply (1 billion tokens)
  static const int myxnTotalSupply = 1000000000;
  
  /// Token description
  static const String myxnDescription = 
      'MYXN — The native decentralized utility token of the MyXenPay ecosystem, '
      'powering merchant settlements, university integrations, staking, burns, '
      'and cross-chain expansion.';
  
  // ─────────────────────────────────────────────────────────────────────────────
  // METADATA & IPFS
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// IPFS CID for token metadata
  static const String metadataIPFSCid = 'bafkreiholwopitkccosr6ebn42frwmpwlzel2c4fcl6wdsvk6y7rwx337a';
  
  /// Full IPFS URI for metadata
  static const String metadataURI = 'ipfs://$metadataIPFSCid';
  
  /// HTTP gateway URL for metadata
  static const String metadataHttpUrl = 'https://ipfs.io/ipfs/$metadataIPFSCid';
  
  /// Token icon URL
  static const String tokenIconUrl = 'https://ipfs.io/ipfs/$metadataIPFSCid';
  
  /// External website URL
  static const String externalUrl = 'https://myxenpay.finance';
  
  // ─────────────────────────────────────────────────────────────────────────────
  // OFFICIAL MYXEN FOUNDATION WALLETS
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Treasury Wallet - Main fund management wallet
  /// All platform funds are managed through this wallet
  static const String treasuryWallet = 'Azvjj21uXQzHbM9VHhyDfdbj14HD8Tef7ZuC1p7sEMk9';
  
  /// Core Token Mint Wallet - Token creation authority
  static const String coreMintWallet = '6S4eDdYXABgtmuk3waLM63U2KHgExcD9mco7MuyG9f5G';
  
  /// Burn Wallet - Official on-chain burn address
  /// Manual burns from Treasury + scheduled burns
  static const String burnWallet = 'HuyT8sNPJMnh9vgJ43PXU4TY696WTWSdh1LBX53ZVox9';
  
  /// Charity Wallet - Charitable contributions
  /// Platform fee charity portion + manual transfers
  static const String charityWallet = 'DDoiUCeoUNHHCV5sLT3rgFjLpLUM76tLCUMnAg52o8vK';
  
  /// HR Wallet - Organization operational costs
  /// Platform fee HR portion + manual transfers
  static const String hrWallet = 'Hv8QBqqSfD4nC6N8qZBo7iJE9QiHLnoXJ6sV2hk1XpoR';
  
  /// Marketing Wallet - Marketing expenditures
  /// On-chain marketing campaign funding
  static const String marketingWallet = '4egNUZa2vNBwmc633GAjworDPEJD2F1HK6pSvMnC3WSv';

  // ─────────────────────────────────────────────────────────────────────────────
  // EXPLORER URLS
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Solscan explorer base URL
  static const String solscanMainnet = 'https://solscan.io';
  static const String solscanDevnet = 'https://solscan.io';
  
  /// Solana Explorer base URL
  static const String solanaExplorerMainnet = 'https://explorer.solana.com';
  static const String solanaExplorerDevnet = 'https://explorer.solana.com';
  
  /// Current explorer URL based on network
  static String get explorerUrl => isProduction ? solscanMainnet : solscanDevnet;
  
  /// Get transaction explorer link
  static String getTransactionUrl(String signature) {
    const network = isProduction ? '' : '?cluster=devnet';
    return '$explorerUrl/tx/$signature$network';
  }
  
  /// Get account/address explorer link
  static String getAccountUrl(String address) {
    const network = isProduction ? '' : '?cluster=devnet';
    return '$explorerUrl/account/$address$network';
  }
  
  /// Get token explorer link
  static String getTokenUrl(String mintAddress) {
    const network = isProduction ? '' : '?cluster=devnet';
    return '$explorerUrl/token/$mintAddress$network';
  }
  
  /// Get MYXN token explorer link
  static String get myxnTokenExplorerUrl => getTokenUrl(myxnTokenMint);
  
  // ─────────────────────────────────────────────────────────────────────────────
  // API TIMEOUTS
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Connection timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  
  /// Receive timeout
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // ─────────────────────────────────────────────────────────────────────────────
  // TRANSACTION CONFIGURATION
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Transaction confirmation timeout
  static const Duration confirmationTimeout = Duration(seconds: 60);
  
  /// Confirmation poll interval
  static const Duration confirmationPollInterval = Duration(seconds: 2);
  
  /// Default priority fee (in lamports)
  static const int defaultPriorityFee = 5000;
  
  /// Minimum rent exemption (approximate for token account)
  static const int minRentExemption = 890880;
  
  // ─────────────────────────────────────────────────────────────────────────────
  // RATE LIMITING
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Maximum requests per second
  static const int maxRequestsPerSecond = 10;
  
  /// Rate limit window
  static const Duration rateLimitWindow = Duration(seconds: 1);
  
  // ─────────────────────────────────────────────────────────────────────────────
  // PLATFORM FEES (in basis points, 100 = 1%)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Platform transaction fee (0.5%)
  static const int platformFeeBasisPoints = 50;
  
  /// Burn allocation from fees (30%)
  static const int burnAllocationPercent = 30;
  
  /// Charity allocation from fees (10%)
  static const int charityAllocationPercent = 10;
  
  /// HR allocation from fees (10%)
  static const int hrAllocationPercent = 10;
  
  /// Remaining goes to Treasury (50%)
  static const int treasuryAllocationPercent = 50;
  
  // ─────────────────────────────────────────────────────────────────────────────
  // UTILITY METHODS
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Convert lamports to SOL
  static double lamportsToSol(int lamports) => lamports / 1000000000;
  
  /// Convert SOL to lamports
  static int solToLamports(double sol) => (sol * 1000000000).round();
  
  /// Convert token amount to display format
  static double tokensToDisplay(int rawAmount, {int decimals = myxnDecimals}) {
    return rawAmount / (10 * decimals);
  }
  
  /// Convert display amount to raw token amount
  static int displayToTokens(double displayAmount, {int decimals = myxnDecimals}) {
    return (displayAmount * (10 * decimals)).round();
  }
  
  /// Check if an address is an official MyXen wallet
  static bool isOfficialWallet(String address) {
    return address == treasuryWallet ||
           address == coreMintWallet ||
           address == burnWallet ||
           address == charityWallet ||
           address == hrWallet ||
           address == marketingWallet;
  }
  
  /// Get wallet label for official wallets
  static String? getOfficialWalletLabel(String address) {
    switch (address) {
      case treasuryWallet:
        return 'MyXen Treasury';
      case coreMintWallet:
        return 'MYXN Mint Authority';
      case burnWallet:
        return 'MYXN Burn Wallet';
      case charityWallet:
        return 'MyXen Charity';
      case hrWallet:
        return 'MyXen HR';
      case marketingWallet:
        return 'MyXen Marketing';
      default:
        return null;
    }
  }
}
