library tab_lib;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:savour_deals_flutter/blocs/deal/deal_bloc.dart';
import 'package:savour_deals_flutter/blocs/redemption/redemption_bloc.dart';
import 'package:savour_deals_flutter/blocs/vendor_page/vendor_bloc.dart';
import 'package:savour_deals_flutter/blocs/wallet/wallet_bloc.dart';
import 'package:savour_deals_flutter/containers/dealCardWidget.dart';
import 'package:savour_deals_flutter/containers/loading.dart';
import 'package:savour_deals_flutter/containers/textPage.dart';
import 'package:savour_deals_flutter/containers/vendorCardWidget.dart';
import 'package:savour_deals_flutter/pages/infoPages/dealPage.dart';
import 'package:savour_deals_flutter/pages/modalPages/mapModalPage.dart';
import 'package:savour_deals_flutter/pages/modalPages/searchModalPage.dart';
import 'package:savour_deals_flutter/pages/modalPages/walletModalPage.dart';
import 'package:savour_deals_flutter/themes/SavourCarouselScrollPhysics.dart';
import 'package:savour_deals_flutter/utils.dart' as globals;
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/infoPages/vendorPage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils.dart';

part "dealsTabPage.dart";
part "vendorsTabPage.dart";
