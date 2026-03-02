import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  static const String baseUrl = 'https://pos.dhisproject.my.id/api';

  static final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static const Color primaryColor = Color(0xFFC8F560);
  static const Color secondaryColor = Color(0xFF2C2C2C);
  static const Color backgroundColor = Color(0xFFF5F5F7);
  static const Color textDarkColor = Color(0xFF2C2C2C);
  static const Color textLightColor = Color(0xFF8E8E93);
}
