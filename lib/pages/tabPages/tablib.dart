library tab_lib;

// import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/containers/dealCardWidget.dart';
import 'package:savour_deals_flutter/containers/vendorCardWidget.dart';
import 'package:savour_deals_flutter/pages/dealPage.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/vendorPage.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../stores/settings.dart' as settings;
import 'package:shared_preferences/shared_preferences.dart';





part "dealsTabPage.dart";
part "favoritesTabPage.dart";
part "vendorsTabPage.dart";
part "referralTabPage.dart";
part "accountTabPage.dart";