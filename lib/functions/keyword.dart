Map<String,List<String>> keyword(String data){
List<String> lines = data.trim().split('\n');
List<String> keywords = [];
List<String> identifiers = [];
for (var line in lines) {
  if (line.startsWith('Keyword:')) {
    keywords.add(line.replaceFirst('Keyword:', '').trim());
  } else if (line.startsWith('Identifier:')) {
    identifiers.add(line.replaceFirst('Identifier:', '').trim());
  }
}
Map<String, List<String>> result = {
  'keywords': keywords,
  'identifiers': identifiers,
};
return result;
}