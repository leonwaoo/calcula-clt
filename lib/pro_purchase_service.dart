import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

enum ProPurchaseState {
  loading,
  unavailable,
  ready,
  purchasing,
  active,
  failed,
}

class ProPurchaseService {
  ProPurchaseService({http.Client? client}) : _client = client ?? http.Client();

  static const productId = 'calculaclt_pro_lifetime';
  static const _validationUrl = String.fromEnvironment(
    'PURCHASE_VALIDATION_URL',
  );

  final http.Client _client;
  final state = ValueNotifier<ProPurchaseState>(ProPurchaseState.loading);
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _product;

  Future<void> initialize() async {
    if (_validationUrl.isEmpty || !await InAppPurchase.instance.isAvailable()) {
      state.value = ProPurchaseState.unavailable;
      return;
    }
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchases,
      onError: (_) => state.value = ProPurchaseState.failed,
    );
    final response = await InAppPurchase.instance.queryProductDetails({
      productId,
    });
    _product = response.productDetails.isEmpty
        ? null
        : response.productDetails.first;
    state.value = _product == null
        ? ProPurchaseState.unavailable
        : ProPurchaseState.ready;
  }

  Future<void> buy() async {
    final product = _product;
    if (product == null) return;
    state.value = ProPurchaseState.purchasing;
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final valid = await _validate(purchase);
        state.value = valid ? ProPurchaseState.active : ProPurchaseState.failed;
      } else if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        state.value = ProPurchaseState.failed;
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<bool> _validate(PurchaseDetails purchase) async {
    try {
      final response = await _client.post(
        Uri.parse(_validationUrl),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'productId': purchase.productID,
          'purchaseToken': purchase.verificationData.serverVerificationData,
        }),
      );
      if (response.statusCode != 200) return false;
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      return payload['valid'] == true;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _client.close();
    state.dispose();
  }
}
