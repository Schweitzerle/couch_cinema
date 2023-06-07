import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bottom_nav_bar.dart';
import '../main.dart';

class FluidPage extends StatelessWidget {
  final String sessionId;

  FluidPage({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return LiquidTabBar();
  }

}
