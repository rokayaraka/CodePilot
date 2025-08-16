import 'package:codepilot/models/language.dart';
import 'package:hive/hive.dart';
part 'code.g.dart';
@HiveType(typeId:2)
class Code {
  @HiveField(0)
  String code;
  @HiveField(1)
  DateTime date;
  @HiveField(2)
  Language language;
  @HiveField(3)
  final String fileName;
  Code({
    required this.fileName,
    required this.code,
    required this.date,
    required this.language
  });
  
}