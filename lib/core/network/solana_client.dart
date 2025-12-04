// lib/core/network/solana_client.dart
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:typed_data';

/// Solana RPC Client for blockchain interactions
class SolanaClient {
  final Dio _dio;
  final String rpcUrl;

  SolanaClient({
    required this.rpcUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = rpcUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  /// Get account balance in lamports
  Future<int> getBalance(String publicKey) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getBalance',
          'params': [publicKey],
        },
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      return response.data['result']['value'] as int;
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  /// Get SPL token account balance
  Future<double> getTokenBalance(String tokenAccountAddress) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getTokenAccountBalance',
          'params': [tokenAccountAddress],
        },
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      final uiAmount = response.data['result']['value']['uiAmount'];
      return (uiAmount as num).toDouble();
    } catch (e) {
      throw Exception('Failed to get token balance: $e');
    }
  }

  /// Get recent blockhash
  Future<String> getRecentBlockhash() async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getLatestBlockhash',
          'params': [
            {'commitment': 'finalized'}
          ],
        },
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      return response.data['result']['value']['blockhash'] as String;
    } catch (e) {
      throw Exception('Failed to get recent blockhash: $e');
    }
  }

  /// Send transaction
  Future<String> sendTransaction(String signedTransaction) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'sendTransaction',
          'params': [
            signedTransaction,
            {
              'encoding': 'base64',
              'skipPreflight': false,
              'preflightCommitment': 'confirmed',
            }
          ],
        },
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      return response.data['result'] as String;
    } catch (e) {
      throw Exception('Failed to send transaction: $e');
    }
  }

  /// Get transaction details
  Future<Map<String, dynamic>?> getTransaction(String signature) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getTransaction',
          'params': [
            signature,
            {
              'encoding': 'json',
              'maxSupportedTransactionVersion': 0,
            }
          ],
        },
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      return response.data['result'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  /// Get confirmed signatures for address
  Future<List<Map<String, dynamic>>> getSignaturesForAddress(
    String address, {
    int limit = 10,
  }) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getSignaturesForAddress',
          'params': [
            address,
            {'limit': limit}
          ],
        },
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      final result = response.data['result'] as List;
      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get signatures: $e');
    }
  }

  /// Get minimum balance for rent exemption
  Future<int> getMinimumBalanceForRentExemption(int dataLength) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getMinimumBalanceForRentExemption',
          'params': [dataLength],
        },
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      return response.data['result'] as int;
    } catch (e) {
      throw Exception('Failed to get minimum balance: $e');
    }
  }

  /// Get token accounts by owner
  Future<List<Map<String, dynamic>>> getTokenAccountsByOwner(
    String ownerAddress,
    String tokenMintAddress,
  ) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getTokenAccountsByOwner',
          'params': [
            ownerAddress,
            {
              'mint': tokenMintAddress,
            },
            {
              'encoding': 'jsonParsed',
            }
          ],
        },
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      final result = response.data['result']['value'] as List;
      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get token accounts: $e');
    }
  }

  /// Confirm transaction
  Future<bool> confirmTransaction(
    String signature, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      try {
        final response = await _dio.post(
          '',
          data: {
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'getSignatureStatuses',
            'params': [
              [signature]
            ],
          },
        );

        if (response.data['error'] != null) {
          throw Exception(response.data['error']['message']);
        }

        final result = response.data['result']['value'][0];
        if (result != null) {
          final confirmationStatus = result['confirmationStatus'];
          if (confirmationStatus == 'confirmed' ||
              confirmationStatus == 'finalized') {
            return true;
          }
        }

        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        // Continue polling
      }
    }

    return false;
  }

  /// Get account info
  Future<Map<String, dynamic>?> getAccountInfo(String publicKey) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getAccountInfo',
          'params': [
            publicKey,
            {'encoding': 'jsonParsed'}
          ],
        },
      );

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      return response.data['result']['value'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get account info: $e');
    }
  }
}
