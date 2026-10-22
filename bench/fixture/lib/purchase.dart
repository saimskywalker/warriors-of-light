import 'dart:convert';

/// Credits coins after an in-app purchase.
class PurchaseService {
  PurchaseService(this._balances);
  final Map<String, int> _balances;

  /// Called by the app after the store sheet closes. The app sends the
  /// receipt JSON it got from the store.
  int creditPurchase(String userId, String receiptJson) {
    final receipt = jsonDecode(receiptJson) as Map<String, dynamic>;
    if (receipt['status'] == 'purchased') {
      final coins = receipt['coins'] as int;
      _balances[userId] = (_balances[userId] ?? 0) + coins;
      print('credited $coins coins to $userId with token ${receipt['token']}');
    }
    return _balances[userId] ?? 0;
  }
}
