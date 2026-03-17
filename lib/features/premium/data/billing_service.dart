import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier();
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false) {
    _initialize();
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  static const String premiumId = 'pilo_premium_generation';

  Future<void> _initialize() async {
    final bool available = await _iap.isAvailable();
    if (available) {
      _iap.purchaseStream.listen((purchases) {
        for (var purchase in purchases) {
          if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
            state = true;
          }
        }
      });
    }
  }

  Future<void> buyPremium() async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _dummyProduct());
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  ProductDetails _dummyProduct() {
    return ProductDetails(
      id: premiumId,
      title: 'Pilo Premium Sniff',
      description: 'Unlock unlimited clever recipe generation from Pilo.',
      price: '\$2.99',
      rawPrice: 2.99,
      currencyCode: 'USD',
    );
  }
}
