library tab_lib;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/containers/dealCardWidget.dart';
import 'package:savour_deals_flutter/containers/vendorCardWidget.dart';
import 'package:savour_deals_flutter/pages/dealPage.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/vendorPage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';



part "dealsTabPage.dart";
part "favoritesTabPage.dart";
part "vendorsTabPage.dart";
part "referralTabPage.dart";
part "accountTabPage.dart";