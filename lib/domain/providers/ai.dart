import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class AIProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  
  // AI insights and recommendations
  Map<String, dynamic>? _financialProfile;
  List<Map<String, dynamic>> _recommendations = [];
  double _creditScore = 0.0;
  Map<String, dynamic>? _riskAssessment;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get financialProfile => _financialProfile;
  List<Map<String, dynamic>> get recommendations => _recommendations;
  double get creditScore => _creditScore;
  Map<String, dynamic>? get riskAssessment => _riskAssessment;
  
  // Generate financial profile using AI
  Future<bool> generateFinancialProfile({
    required String userId,
    required Map<String, dynamic> userData,
    required List<Map<String, dynamic>> transactionHistory,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Prepare data for AI analysis
      Map<String, dynamic> analysisData = {
        'user_id': userId,
        'demographic_data': _prepareDemographicData(userData),
        'transaction_patterns': _analyzeTransactionPatterns(transactionHistory),
        'financial_behavior': _extractFinancialBehavior(transactionHistory),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Call Vertex AI endpoint (simulated for demo)
      Map<String, dynamic> aiResponse = await _callVertexAI(
        'financial-profile-generator',
        analysisData,
      );
      
      if (aiResponse['success']) {
        _financialProfile = aiResponse['profile'];
        _creditScore = aiResponse['credit_score']?.toDouble() ?? 0.0;
        _riskAssessment = aiResponse['risk_assessment'];
        
        // Generate personalized recommendations
        await _generateRecommendations(userId, analysisData);
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Error generando perfil financiero: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Generate savings recommendations
  Future<List<Map<String, dynamic>>> generateSavingsRecommendations({
    required double currentBalance,
    required double monthlyIncome,
    required List<Map<String, dynamic>> expenses,
    required Map<String, dynamic> financialGoals,
  }) async {
    try {
      _setLoading(true);
      
      Map<String, dynamic> analysisData = {
        'current_balance': currentBalance,
        'monthly_income': monthlyIncome,
        'expense_categories': _categorizeExpenses(expenses),
        'financial_goals': financialGoals,
        'savings_capacity': _calculateSavingsCapacity(monthlyIncome, expenses),
      };
      
      Map<String, dynamic> aiResponse = await _callVertexAI(
        'savings-advisor',
        analysisData,
      );
      
      if (aiResponse['success']) {
        return List<Map<String, dynamic>>.from(
          aiResponse['recommendations'] ?? []
        );
      }
      
      return _generateFallbackSavingsRecommendations(analysisData);
    } catch (e) {
      _setError('Error generando recomendaciones: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Credit risk assessment
  Future<Map<String, dynamic>> assessCreditRisk({
    required String userId,
    required double requestedAmount,
    required Map<String, dynamic> userProfile,
    required List<Map<String, dynamic>> transactionHistory,
  }) async {
    try {
      _setLoading(true);
      
      Map<String, dynamic> riskData = {
        'user_id': userId,
        'requested_amount': requestedAmount,
        'user_profile': userProfile,
        'transaction_stability': _calculateTransactionStability(transactionHistory),
        'income_consistency': _analyzeIncomeConsistency(transactionHistory),
        'debt_to_income_ratio': _calculateDebtToIncomeRatio(
          userProfile,
          transactionHistory,
        ),
        'payment_history': _analyzePaymentHistory(transactionHistory),
      };
      
      Map<String, dynamic> aiResponse = await _callVertexAI(
        'credit-risk-assessor',
        riskData,
      );
      
      if (aiResponse['success']) {
        return aiResponse['assessment'];
      }
      
      return _generateFallbackRiskAssessment(riskData);
    } catch (e) {
      _setError('Error evaluando riesgo crediticio: ${e.toString()}');
      return {
        'risk_level': 'high',
        'score': 0.0,
        'recommendation': 'denied',
        'reasons': ['Error en análisis AI'],
      };
    } finally {
      _setLoading(false);
    }
  }
  
  // Fraud detection
  Future<Map<String, dynamic>> detectFraud({
    required Map<String, dynamic> transaction,
    required List<Map<String, dynamic>> userBehaviorHistory,
  }) async {
    try {
      Map<String, dynamic> fraudData = {
        'transaction': transaction,
        'user_patterns': _extractUserPatterns(userBehaviorHistory),
        'anomaly_factors': _calculateAnomalyFactors(
          transaction,
          userBehaviorHistory,
        ),
        'time_factors': _analyzeTimingPatterns(transaction),
        'location_factors': _analyzeLocationFactors(transaction),
      };
      
      Map<String, dynamic> aiResponse = await _callVertexAI(
        'fraud-detector',
        fraudData,
      );
      
      if (aiResponse['success']) {
        return aiResponse['analysis'];
      }
      
      return _generateFallbackFraudAnalysis(fraudData);
    } catch (e) {
      return {
        'is_suspicious': false,
        'confidence': 0.0,
        'risk_factors': [],
        'recommendation': 'approve',
      };
    }
  }
  
  // Private methods for AI integration
  Future<Map<String, dynamic>> _callVertexAI(
    String modelEndpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      // For production, replace with actual Vertex AI endpoint
      // This is a simulation for demo purposes
      await Future.delayed(Duration(seconds: 2)); // Simulate API call
      
      // Generate realistic AI responses based on input data
      switch (modelEndpoint) {
        case 'financial-profile-generator':
          return _simulateFinancialProfileResponse(data);
        case 'savings-advisor':
          return _simulateSavingsAdvisorResponse(data);
        case 'credit-risk-assessor':
          return _simulateCreditRiskResponse(data);
        case 'fraud-detector':
          return _simulateFraudDetectionResponse(data);
        default:
          return {'success': false, 'error': 'Unknown model endpoint'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // AI Response Simulators (replace with actual Vertex AI calls in production)
  Map<String, dynamic> _simulateFinancialProfileResponse(
    Map<String, dynamic> data,
  ) {
    Random rand = Random();
    
    // Generate realistic credit score based on transaction patterns
    double baseScore = 300 + rand.nextDouble() * 550;
    if (data['transaction_patterns']['regularity'] > 0.7) baseScore += 50;
    if (data['transaction_patterns']['average_balance'] > 1000) baseScore += 100;
    
    return {
      'success': true,
      'profile': {
        'spending_personality': _generateSpendingPersonality(data),
        'financial_habits': _analyzeFinancialHabits(data),
        'risk_tolerance': _calculateRiskTolerance(data),
        'savings_potential': _calculateSavingsPotential(data),
      },
      'credit_score': baseScore.clamp(300, 850),
      'risk_assessment': {
        'level': baseScore > 650 ? 'low' : baseScore > 500 ? 'medium' : 'high',
        'factors': _generateRiskFactors(data),
        'recommendations': _generateRiskRecommendations(baseScore),
      },
    };
  }
  
  Map<String, dynamic> _simulateSavingsAdvisorResponse(
    Map<String, dynamic> data,
  ) {
    List<Map<String, dynamic>> recommendations = [];
    double savingsCapacity = data['savings_capacity'] ?? 0.0;
    
    if (savingsCapacity > 100) {
      recommendations.add({
        'type': 'emergency_fund',
        'title': 'Fondo de Emergencia',
        'description': 'Ahorra \$${(savingsCapacity * 0.3).toStringAsFixed(0)} mensualmente',
        'impact': 'high',
        'priority': 1,
        'estimated_savings': savingsCapacity * 0.3 * 12,
      });
    }
    
    if (data['financial_goals']['has_goals'] == true) {
      recommendations.add({
        'type': 'goal_based',
        'title': 'Ahorro para Metas',
        'description': 'Optimiza tus gastos para alcanzar tus objetivos',
        'impact': 'medium',
        'priority': 2,
        'estimated_savings': savingsCapacity * 0.4 * 12,
      });
    }
    
    return {
      'success': true,
      'recommendations': recommendations,
    };
  }
  
  Map<String, dynamic> _simulateCreditRiskResponse(
    Map<String, dynamic> data,
  ) {
    double riskScore = 0.5;
    List<String> riskFactors = [];
    
    if (data['transaction_stability'] < 0.6) {
      riskScore += 0.2;
      riskFactors.add('Ingresos irregulares');
    }
    
    if (data['debt_to_income_ratio'] > 0.4) {
      riskScore += 0.3;
      riskFactors.add('Alta relación deuda-ingreso');
    }
    
    String riskLevel = riskScore < 0.3 ? 'low' : riskScore < 0.7 ? 'medium' : 'high';
    String recommendation = riskLevel == 'high' ? 'denied' : 'approved';
    
    return {
      'success': true,
      'assessment': {
        'risk_level': riskLevel,
        'score': (1 - riskScore) * 100,
        'recommendation': recommendation,
        'reasons': riskFactors,
        'suggested_amount': recommendation == 'approved' 
            ? data['requested_amount'] * (1 - riskScore)
            : 0,
      },
    };
  }
  
  Map<String, dynamic> _simulateFraudDetectionResponse(
    Map<String, dynamic> data,
  ) {
    bool isSuspicious = false;
    double confidence = 0.0;
    List<String> riskFactors = [];
    
    // Check for anomalies
    if (data['anomaly_factors']['amount_anomaly'] > 0.8) {
      isSuspicious = true;
      confidence += 0.4;
      riskFactors.add('Monto inusual para el usuario');
    }
    
    if (data['time_factors']['unusual_time'] == true) {
      confidence += 0.2;
      riskFactors.add('Horario inusual de transacción');
    }
    
    return {
      'success': true,
      'analysis': {
        'is_suspicious': isSuspicious,
        'confidence': confidence,
        'risk_factors': riskFactors,
        'recommendation': isSuspicious ? 'review' : 'approve',
      },
    };
  }
  
  // Helper methods for data analysis
  Map<String, dynamic> _prepareDemographicData(Map<String, dynamic> userData) {
    return {
      'age_group': _getAgeGroup(userData['age'] ?? 25),
      'location': userData['location'] ?? 'unknown',
      'employment_status': userData['employment_status'] ?? 'unknown',
      'education_level': userData['education_level'] ?? 'unknown',
    };
  }
  
  Map<String, dynamic> _analyzeTransactionPatterns(
    List<Map<String, dynamic>> transactions,
  ) {
    if (transactions.isEmpty) {
      return {
        'regularity': 0.0,
        'average_amount': 0.0,
        'frequency': 0,
        'categories': <String, int>{},
      };
    }
    
    double totalAmount = 0;
    Map<String, int> categories = {};
    
    for (var transaction in transactions) {
      totalAmount += transaction['amount']?.toDouble() ?? 0.0;
      String category = transaction['category'] ?? 'other';
      categories[category] = (categories[category] ?? 0) + 1;
    }
    
    return {
      'regularity': _calculateRegularity(transactions),
      'average_amount': totalAmount / transactions.length,
      'frequency': transactions.length,
      'categories': categories,
      'average_balance': totalAmount / transactions.length,
    };
  }
  
  double _calculateRegularity(List<Map<String, dynamic>> transactions) {
    if (transactions.length < 2) return 0.0;
    
    List<int> intervals = [];
    for (int i = 1; i < transactions.length; i++) {
      DateTime current = DateTime.parse(transactions[i]['date']);
      DateTime previous = DateTime.parse(transactions[i-1]['date']);
      intervals.add(current.difference(previous).inDays);
    }
    
    if (intervals.isEmpty) return 0.0;
    
    double average = intervals.reduce((a, b) => a + b) / intervals.length;
    double variance = intervals
        .map((interval) => pow(interval - average, 2))
        .reduce((a, b) => a + b) / intervals.length;
    
    return 1.0 / (1.0 + sqrt(variance) / average);
  }
  
  // Additional helper methods...
  void _generateRecommendations(String userId, Map<String, dynamic> data) async {
    _recommendations = [
      {
        'id': 'save_emergency',
        'type': 'savings',
        'title': 'Crea tu Fondo de Emergencia',
        'description': 'Ahorra el equivalente a 3 meses de gastos',
        'priority': 'high',
        'impact': 'financial_security',
      },
      {
        'id': 'reduce_expenses',
        'type': 'optimization',
        'title': 'Optimiza tus Gastos',
        'description': 'Identifica gastos innecesarios y redúcelos',
        'priority': 'medium',
        'impact': 'cash_flow',
      },
    ];
  }
  
  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  // Fallback methods for when AI is unavailable
  List<Map<String, dynamic>> _generateFallbackSavingsRecommendations(
    Map<String, dynamic> data,
  ) {
    return [
      {
        'type': 'basic_savings',
        'title': 'Regla 50/30/20',
        'description': 'Destina 20% de tus ingresos al ahorro',
        'impact': 'medium',
        'priority': 1,
      },
      {
        'type': 'budgeting',
        'title': 'Presupuesto Mensual',
        'description': 'Crea un presupuesto para controlar tus gastos',
        'impact': 'high',
        'priority': 2,
      },
    ];
  }
  Map<String, dynamic> _generateFallbackRiskAssessment(
    Map<String, dynamic> data,
  ) {
    return {
      'risk_level': 'high',
      'score': 0.0,
      'recommendation': 'denied',
      'reasons': ['Error en análisis AI'],
    };
  }
  Map<String, dynamic> _generateFallbackFraudAnalysis(
    Map<String, dynamic> data,
  ) {
    return {
      'is_suspicious': false,
      'confidence': 0.0,
      'risk_factors': [],
      'recommendation': 'approve',
    };
  }
}