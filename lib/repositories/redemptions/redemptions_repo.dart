import 'package:savour_deals_flutter/utils.dart' as globals;

class RedemptionRepository {
  RedemptionRepository();

  void getRedemptions() {
    globals.redemptionApiProvider.getRedemptions();
  }
}