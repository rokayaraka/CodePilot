import 'package:hive/hive.dart';
part 'language.g.dart';
@HiveType(typeId: 1)
class Language {
  @HiveField(0)
  final String language;
  @HiveField(1)
  final String version;
  @HiveField(2)
  final List<String> aliases;
  @HiveField(3)
  final String? runtime;

  Language({
    required this.language,
    required this.version,
    required this.aliases,
    this.runtime,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      language: json['language'] as String,
      version: json['version'] as String,
      aliases: (json['aliases'] as List<dynamic>).map((e) => e as String).toList(),
      runtime: json['runtime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'version': version,
      'aliases': aliases,
      if (runtime != null) 'runtime': runtime,
    };
  }

  static List<Language> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => Language.fromJson(item)).toList();
  }
}