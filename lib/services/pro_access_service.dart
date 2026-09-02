import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

/// The single non-consumable product configured in Google Play Console.
const proLifetimeProductId = 'calculaclt_pro_lifetime';

enum ProAccessStatus { loading, free, pro, unavailable, error }

class ProAccessService {
  ProAccessService({http.Client? client}) : _client = client ?? http.Client();

  static const _verifierUrl = String.fromEnvironment('PURCHASE_VERIFIER_URL');

  final InAppPurchase _store = InAppPurchase.instance;
  final http.Client _client;
  final StreamController<ProAccessStatus> _statusController =
      StreamController<ProAccessStatus>.broadcast();
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  ProductDetails? _product;
  bool _isPro = false;
  bool get isPro => _isPro;
  ProductDetails? get product => _product;
  Stream<ProAccessStatus> get status => _statusController.stream;

  Future<void> initialize() async {
    _statusController.add(ProAccessStatus.loading);
    _subscription = _store.purchaseStream.listen(
      _handlePurchases,
      onError: (_) => _statusController.add(ProAccessStatus.error),
    );

    final available = await _store.isAvailable();
    if (!available) {
      _statusController.add(ProAccessStatus.unavailable);
      return;
    }

    final response = await _store.queryProductDetails({proLifetimeProductId});
    if (response.error != null || response.notFoundIDs.isNotEmpty) {
      _statusController.add(ProAccessStatus.error);
      return;
    }
    _product = response.productDetails.single;
    await restorePurchases();
    _statusController.add(_isPro ? ProAccessStatus.pro : ProAccessStatus.free);
  }

  Future<bool> buyLifetimeAccess() async {
    final product = _product;
    if (product == null) return false;
    return _store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restorePurchases() => _store.restorePurchases();

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != proLifetimeProductId) continue;
      if (purchase.status == PurchaseStatus.pending) {
        _statusController.add(ProAccessStatus.loading);
        continue;
      }
      if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        _statusController.add(ProAccessStatus.error);
        continue;
      }
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final verified = await _verifyWithBackend(purchase);
        if (verified) {
          _isPro = true;
          _statusController.add(ProAccessStatus.pro);
          if (purchase.pendingCompletePurchase)
            await _store.completePurchase(purchase);
        } else {
          // Do not grant access or acknowledge a transaction that was not verified.
          _isPro = false;
          _statusController.add(ProAccessStatus.error);
        }
      }
    }
  }

  Future<bool> _verifyWithBackend(PurchaseDetails purchase) async {
    // A device must never be the authority for a paid entitlement. The endpoint
    // validates the Play purchase token with Google Play Developer API and
    // returns { "active": true } only for an owned non-consumable product.
    if (_verifierUrl.isEmpty) return false;
    try {
      final response = await _client.post(
        Uri.parse(_verifierUrl),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': purchase.productID,
          'purchaseToken': purchase.verificationData.serverVerificationData,
          'source': purchase.verificationData.source,
        }),
      );
      if (response.statusCode != 200) return false;
      return (jsonDecode(response.body) as Map<String, dynamic>)['active'] ==
          true;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _statusController.close();
    _client.close();
  }
}
