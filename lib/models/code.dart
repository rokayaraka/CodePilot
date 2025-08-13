import 'package:codepilot/models/language.dart';

class Code {
  final String code;
  final DateTime date;
  final Language language;
  const Code({
    required this.code,
    required this.date,
    required this.language
  });
  
}