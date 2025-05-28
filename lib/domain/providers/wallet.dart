import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Wallet state
  double _balance = 0.0;
  String _currency = 'USD';
  final bool _isLoading = false;
  String? _errorMessage;
  
  // Savings goals
  final List<Map<String, dynamic>> _savingsGoals = [];
  double _totalSavingsTarget = 0.0;
  double _totalSavingsCurrent = 0.0;
  
  // Quick actions
  final List<Map<String, dynamic>> _quickActions = [];
  final List<Map<String, dynamic>> _frequentContacts = [];
  
  // Security
  bool _isWalletLocked = false;
  DateTime? _lastUnlockTime;
  
  // Getters
  double get balance => _balance;
  String get currency => _currency;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get savingsGoals => _savingsGoals;
  double get totalSavingsTarget => _totalSavingsTarget;
  double get totalSavingsCurrent => _totalSavingsCurrent;
  List<Map<String, dynamic>> get quickActions => _quickActions;
  List<Map<String, dynamic>> get frequentContacts => _frequentContacts;
  bool get isWalletLocked => _isWalletLocked;
  
  // Computed getters
  double get savingsProgress => 
      _totalSavingsTarget > 0 ? _totalSavingsCurrent / _totalSavingsTarget : 0.0;
  
  String get formattedBalance => _formatCurrency(_balance);
  
  WalletProvider() {
    _initializeWallet();
  }
  
  // Initialize wallet data
  Future<void> _initializeWallet() async {
    User? user = _auth.currentUser;
    if (user == null) return;
    
    try {
      _setLoading(true);
      await _loadWalletData(user.uid);
      await _loadSavingsGoals(user.uid);
      await _loadQuickActions(user.uid);
      await _loadFrequentContacts(user.uid);
    } catch (e) {
      _setError('Error inicializando wallet: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load wallet data from Firestore
  Future<void> _loadWalletData(String userId) async {
    DocumentSnapshot doc = await _firestore
        .collection('wallets')
        .doc(userId)
        .get();
    
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      _balance = data['balance']?.toDouble() ?? 0.0;
      _currency = data['currency'] ?? 'USD';
      _isWalletLocked = data['isLocked'] ?? false;
    } else {
      // Create new wallet
      await _createWallet(userId);
    }
  }
  
  // Create new wallet
  Future<void> _createWallet(String userId) async {
    Map<String, dynamic> walletData = {
      'userId': userId,
      'balance': 0.0,
      'currency': 'USD',
      'isLocked': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    };
    
    await _firestore.collection('wallets').doc(userId).set(walletData);
    
    // Initialize default quick actions
    await _initializeQuickActions(userId);
  }
  
  // Add money to wallet
  Future<bool> addMoney({
    required double amount,
    required String source,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    if (_isWalletLocked) {
      _setError('Wallet está bloqueada. Desbloquea primero.');
      return false;
    }
    
    if (amount <= 0) {
      _setError('El monto debe ser mayor a cero');
      return false;
    }
    
    try {
      _setLoading(true);
      User? user = _auth.currentUser;
      if (user == null) return false;
      
      // Create transaction record
      String transactionId = await _createTransaction(
        userId: user.uid,
        type: 'deposit',
        amount: amount,
        source: source,
        description: description ?? 'Depósito a wallet',
        metadata: metadata,
      );
      
      // Update wallet balance
      await _firestore.collection('wallets').doc(user.uid).update({
        'balance': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Update local state
      _balance += amount;
      
      // Check savings goals progress
      await _checkSavingsGoalsProgress(user.uid, amount);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error agregando dinero: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Send money
  Future<bool> sendMoney({
    required String recipientId,
    required double amount,
    String? description,
    bool requiresApproval = false,
  }) async {
    if (_isWalletLocked) {
      _setError('Wallet está bloqueada. Desbloquea primero.');
      return false;
    }
    
    if (amount <= 0) {
      _setError('El monto debe ser mayor a cero');
      return false;
    }
    
    if (amount > _balance) {
      _setError('Saldo insuficiente');
      return false;
    }
    
    try {
      _setLoading(true);
      User? user = _auth.currentUser;
      if (user == null) return false;
      
      // Verify recipient exists
      DocumentSnapshot recipientDoc = await _firestore
          .collection('users')
          .doc(recipientId)
          .get();
      
      if (!recipientDoc.exists) {
        _setError('Destinatario no encontrado');
        return false;
      }
      
      // Create transaction batch
      WriteBatch batch = _firestore.batch();
      
      // Deduct from sender
      DocumentReference senderWallet = _firestore
          .collection('wallets')
          .doc(user.uid);
      
      batch.update(senderWallet, {
        'balance': FieldValue.increment(-amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Add to recipient (if not requiring approval)
      if (!requiresApproval) {
        DocumentReference recipientWallet = _firestore
            .collection('wallets')
            .doc(recipientId);
        
        batch.update(recipientWallet, {
          'balance': FieldValue.increment(amount),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
      
      // Create transactions
      String transactionId = _generateTransactionId();
      
      // Sender transaction
      DocumentReference senderTransaction = _firestore
          .collection('transactions')
          .doc('${transactionId}_sender');
      
      batch.set(senderTransaction, {
        'id': '${transactionId}_sender',
        'userId': user.uid,
        'type': 'transfer_out',
        'amount': -amount,
        'recipientId': recipientId,
        'description': description ?? 'Envío de dinero',
        'status': requiresApproval ? 'pending' : 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': {
          'transfer_type': 'p2p',
          'requires_approval': requiresApproval,
        },
      });
      
      // Recipient transaction
      DocumentReference recipientTransaction = _firestore
          .collection('transactions')
          .doc('${transactionId}_recipient');
      
      batch.set(recipientTransaction, {
        'id': '${transactionId}_recipient',
        'userId': recipientId,
        'type': 'transfer_in',
        'amount': amount,
        'senderId': user.uid,
        'description': description ?? 'Recepción de dinero',
        'status': requiresApproval ? 'pending' : 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': {
          'transfer_type': 'p2p',
          'requires_approval': requiresApproval,
        },
      });
      
      // Commit batch
      await batch.commit();
      
      // Update local balance
      _balance -= amount;
      
      // Add to frequent contacts
      await _addToFrequentContacts(recipientId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error enviando dinero: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Request money
  Future<bool> requestMoney({
    required String fromUserId,
    required double amount,
    String? description,
    DateTime? dueDate,
  }) async {
    try {
      _setLoading(true);
      User? user = _auth.currentUser;
      if (user == null) return false;
      
      String requestId = _generateTransactionId();
      
      await _firestore.collection('money_requests').doc(requestId).set({
        'id': requestId,
        'requesterId': user.uid,
        'fromUserId': fromUserId,
        'amount': amount,
        'description': description ?? 'Solicitud de dinero',
        'status': 'pending',
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Send notification to requested user
      await _sendNotification(
        userId: fromUserId,
        type: 'money_request',
        title: 'Solicitud de Dinero',
        body: 'Te solicitan \$${_formatAmount(amount)}',
        data: {'requestId': requestId},
      );
      
      return true;
    } catch (e) {
      _setError('Error solicitando dinero: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Savings goals management
  Future<bool> createSavingsGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    String? description,
    String? category,
  }) async {
    try {
      _setLoading(true);
      User? user = _auth.currentUser;
      if (user == null) return false;
      
      String goalId = _generateTransactionId();
      
      Map<String, dynamic> goalData = {
        'id': goalId,
        'userId': user.uid,
        'name': name,
        'description': description,
        'category': category ?? 'general',
        'targetAmount': targetAmount,
        'currentAmount': 0.0,
        'targetDate': targetDate.millisecondsSinceEpoch,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('savings_goals').doc(goalId).set(goalData);
      
      // Add to local state
      _savingsGoals.add(goalData);
      _totalSavingsTarget += targetAmount;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error creando meta de ahorro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Add money to savings goal
  Future<bool> addToSavingsGoal({
    required String goalId,
    required double amount,
  }) async {
    if (amount <= 0 || amount > _balance) {
      _setError('Monto inválido o saldo insuficiente');
      return false;
    }
    
    try {
      _setLoading(true);
      User? user = _auth.currentUser;
      if (user == null) return false;
      
      // Create transaction batch
      WriteBatch batch = _firestore.batch();
      
      // Update wallet balance
      DocumentReference walletRef = _firestore
          .collection('wallets')
          .doc(user.uid);
      
      batch.update(walletRef, {
        'balance': FieldValue.increment(-amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Update savings goal
      DocumentReference goalRef = _firestore
          .collection('savings_goals')
          .doc(goalId);
      
      batch.update(goalRef, {
        'currentAmount': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Create transaction record
      String transactionId = _generateTransactionId();
      DocumentReference transactionRef = _firestore
          .collection('transactions')
          .doc(transactionId);
      
      batch.set(transactionRef, {
        'id': transactionId,
        'userId': user.uid,
        'type': 'savings_deposit',
        'amount': -amount,
        'description': 'Depósito a meta de ahorro',
        'goalId': goalId,
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': {
          'savings_goal': true,
        },
      });
      
      await batch.commit();
      
      // Update local state
      _balance -= amount;
      _totalSavingsCurrent += amount;
      
      // Update local savings goals
      int goalIndex = _savingsGoals.indexWhere((g) => g['id'] == goalId);
      if (goalIndex != -1) {
        _savingsGoals[goalIndex]['currentAmount'] += amount;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error agregando a meta de ahorro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  // Withdraw money from wallet
  Future<bool> withdrawMoney({
    required double amount,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    if (_isWalletLocked) {
      _setError('Wallet está bloqueada. Desbloquea primero.');
      return false;
    }
    
    if (amount <= 0 || amount > _balance) {
      _setError('Monto inválido o saldo insuficiente');
      return false;
    }
    
    try {
      _setLoading(true);
      User? user = _auth.currentUser;
      if (user == null) return false;
      
      // Create transaction record
      String transactionId = await _createTransaction(
        userId: user.uid,
        type: 'withdrawal',
        amount: -amount,
        description: description ?? 'Retiro de wallet',
        metadata: metadata,
      );
      
      // Update wallet balance
      await _firestore.collection('wallets').doc(user.uid).update({
        'balance': FieldValue.increment(-amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Update local state
      _balance -= amount;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error retirando dinero: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}