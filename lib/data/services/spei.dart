
// lib/services/spei_service.dart
import 'api.dart';
import '../models/transfer.dart';
import '../models/account.dart';

class SPEIService {
  final ApiService _apiService;

  SPEIService(this._apiService);

  Future<TransferResult> initiateTransfer({
    required String senderAccountId,
    required String receiverClabe,
    required double amount,
    required String concept,
    String? receiverName,
  }) async {
    final response = await _apiService.post('/transfers/spei', {
      'senderAccountId': senderAccountId,
      'receiverClabe': receiverClabe,
      'amount': amount,
      'concept': concept,
      'receiverName': receiverName,
    });

    if (response.success && response.data != null) {
      final transferData = response.data!['transfer'];
      final transfer = Transfer.fromJson(transferData);
      
      return TransferResult(success: true, transfer: transfer);
    }

    return TransferResult(
      success: false,
      error: response.message ?? 'Transfer failed'
    );
  }

  Future<Transfer?> getTransferStatus(String transferId) async {
    final response = await _apiService.get('/transfers/$transferId/status');

    if (response.success && response.data != null) {
      return Transfer.fromJson(response.data!);
    }

    return null;
  }

  Future<List<Transfer>> getTransferHistory({
    int page = 1,
    int limit = 20,
    String? accountId,
  }) async {
    String endpoint = '/transactions?page=$page&limit=$limit';
    if (accountId != null) {
      endpoint += '&accountId=$accountId';
    }

    final response = await _apiService.get(endpoint);

    if (response.success && response.data != null) {
      final transactions = response.data!['transactions'] as List;
      return transactions.map((t) => Transfer.fromJson(t)).toList();
    }

    return [];
  }

  Future<bool> validateClabe(String clabe) async {
    if (clabe.length != 18) return false;
    
    // Basic CLABE validation
    final regex = RegExp(r'^\d{18}$');
    if (!regex.hasMatch(clabe)) return false;
    
    // Check digit validation
    final weights = [3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7];
    int sum = 0;
    
    for (int i = 0; i < 17; i++) {
      sum += int.parse(clabe[i]) * weights[i];
    }
    
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(clabe[17]);
  }

  String getBankNameFromClabe(String clabe) {
    if (clabe.length < 3) return 'Banco desconocido';
    
    final bankCode = clabe.substring(0, 3);
    final bankNames = {
      '002': 'Banamex',
      '012': 'BBVA',
      '014': 'Santander',
      '021': 'HSBC',
      '030': 'Banobras',
      '036': 'Inbursa',
      '044': 'Scotiabank',
      '072': 'Banorte',
      '127': 'Azteca',
      '130': 'Compartamos',
      '132': 'Multiva',
      '137': 'Coppel',
      '638': 'Nu México',
    };
    
    return bankNames[bankCode] ?? 'Banco desconocido';
  }
}

class TransferResult {
  final bool success;
  final Transfer? transfer;
  final String? error;

  TransferResult({required this.success, this.transfer, this.error});
}