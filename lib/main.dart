import 'package:codepilot/api_services.dart';
import 'package:codepilot/drawer.dart';
import 'package:codepilot/editor.dart';
import 'package:codepilot/functions/keyword.dart';
import 'package:codepilot/models/language.dart';
import 'package:codepilot/overlayWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:codepilot/models/code.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await Hive.initFlutter();
  Hive.registerAdapter(LanguageAdapter());
  Hive.registerAdapter(CodeAdapter());
  await Hive.openBox<Code>('codes');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodePilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
      ),
      themeMode: ThemeMode.dark,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Code> savedFile = [];
  Icon sideBarIcon = Icon(Icons.view_sidebar);
  late Future<List<Language>> languagesFuture;
  Language? selectedLanguage;
  final TextEditingController _codeController = TextEditingController(text: "");
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  String _output = "Output will be displayed here";
  bool isSideBarOn = true;
  bool isLoading = false;
  bool isFlexAble = false;
  bool keywordLoading=false;
  @override
  void initState() {
    super.initState();
    languagesFuture = ApiServices.fetchLanguages();
    final box = Hive.box<Code>('codes');
    savedFile.clear();
    savedFile.addAll(box.values);
  }
  @override
  void dispose() {
    _codeController.dispose();
    _inputController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }
  //open saved file function
  void openSavedFile(Code code) async {
  final langs = await languagesFuture;
  final lang = langs.firstWhere(
    (l) => l.language == code.language.language,
    orElse: () => code.language,
  );
  setState(() {
    _codeController.text = code.code;
    selectedLanguage = lang;
    _inputController.text = "";
    if(selectedLanguage!.language=="python"||selectedLanguage!.language=="c"||selectedLanguage!.language=="c++"){
      isFlexAble=true;
    }
  });
}
  void generateKeyword(BuildContext context)async{
    String language="";
    if(selectedLanguage!.language=="python"){
      language="python";
    }
    else if(selectedLanguage!.language=="c"){
      language="c";
    }
    else if(selectedLanguage!.language=="c++"){
      language="c++";
    }
    setState(() {
      keywordLoading=true;
    });
    final keywords= await ApiServices.keywordGenerator(code: _codeController.text, language: language);
    setState(() {
      keywordLoading=false;
    });
    final keywordMap = keyword(keywords);
    showModalBottomSheet(
    context: context, 
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return OverlayWidget(keywordMap: keywordMap);
    });
  }
  //on file save function
  void saveFile() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(
                'Save File',
                textAlign: TextAlign.center,
              ),
              content: TextField(
                controller: _fileNameController,
                decoration: InputDecoration(hintText: 'Enter file name'),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final fileName = _fileNameController.text.trim();
                        if (fileName.isNotEmpty&& selectedLanguage!=null) {
                          final box = Hive.box<Code>('codes');
                          
                          box.put(
                              fileName,
                              Code(
                                  fileName: fileName,
                                  code: _codeController.text,
                                  date: DateTime.now(),
                                  language: selectedLanguage!));
                          setState(() {
                            for (final iterate in savedFile){
                              if (iterate.fileName == fileName) {
                                iterate.code = _codeController.text;
                                iterate.date = DateTime.now();
                                iterate.language = selectedLanguage!;
                                break;
                              }
                              savedFile.add(box.get(fileName)!);
                            }
                            _fileNameController.clear();
                          });
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'File saved successfully',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                            , duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(ctx).pop();
                        }
                        else {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Please enter a file name or select language first',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Save'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ));
  }
  // run button function 
  void _runcode() async {
    setState(() {
      isLoading = !isLoading;
    });
    if (selectedLanguage == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Please select a language',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = !isLoading;
      });
      return;
    }
    final outputResult = await ApiServices.runCode(
      language: selectedLanguage!,
      code: _codeController.text,
      input: _inputController.text,
    );
    setState(() {
      _output = outputResult;
      isLoading = !isLoading;
    });
  }
  //app first screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CodePilot'),
        elevation: 10,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
        toolbarHeight: 40,
        actions: [
          FutureBuilder<List<Language>>(
            future: languagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                      child: SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 3,
                          color: Colors.grey.shade400,
                          ))),
                );
                
              } else if (snapshot.hasError) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      languagesFuture = ApiServices.fetchLanguages();
                    });
                  },
                  icon: Icon(Icons.refresh_sharp, color: Colors.red),
                );
              } else if (snapshot.hasData) {
                final languages = snapshot.data!;
                return DropdownButtonHideUnderline(
                  child: DropdownButton<Language>(
                    
                    value: languages.contains(selectedLanguage)
                        ? selectedLanguage
                        : (selectedLanguage=languages.first),
                    dropdownColor: Theme.of(context).canvasColor,
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.grey.shade300),
                    items: languages.map((lang) {
                      return DropdownMenuItem<Language>(
                        alignment: Alignment.centerLeft,
                        value: lang,
                        child: Text(
                          '${lang.language} (${lang.version})',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      );
                    }).toList(),
                    onChanged: (Language? newLang) {
                      setState(() {
                        selectedLanguage = newLang;
                        if(selectedLanguage!.language=="python"||selectedLanguage!.language=="c"||selectedLanguage!.language=="c++") {
                          isFlexAble = true;
                        }
                        else{
                          isFlexAble=false;
                        }
                      });
                    },
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
         
          !isLoading
              ? IconButton(
                  onPressed: _runcode,
                  icon: Icon(
                    Icons.play_arrow,
                  ),
                )
              : SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                ),
          keywordLoading?
          SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                )
          :isFlexAble?
          IconButton(
            onPressed: (){
              generateKeyword(context);
            }, 
            icon: Icon(Icons.generating_tokens, color: Colors.grey.shade400)
          ): SizedBox(),
          IconButton(
              onPressed: () {
                setState(() {
                  _codeController.clear();
                  _inputController.clear();
                  _output = "Output will be displayed here";
                });
              },
              icon: Icon(Icons.cleaning_services)),
          IconButton(onPressed: saveFile, icon: Icon(Icons.save)),
          IconButton(
            onPressed: () {
              setState(() {
                isSideBarOn = !isSideBarOn;
                if (isSideBarOn == true) {
                  sideBarIcon = Icon(Icons.view_sidebar);
                } else {
                  sideBarIcon = Icon(Icons.view_sidebar_outlined);
                }
              });
            },
            icon: sideBarIcon,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Editor(code: _codeController),
              ),
              SizedBox(width: 16.0),
              isSideBarOn
                  ? Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _inputController,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors
                                          .grey.shade300), // same as enabled
                                ),
                                hintText: "Input",
                              ),
                              maxLines: null,
                              minLines: 2,
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              padding: EdgeInsets.all(16.0),
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: SingleChildScrollView(
                                child: Text(_output,
                                    style: TextStyle(
                                        fontFamily: 'Courier', fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ))
                  : Text("")
            ],
          ),
        ),
      ),
      drawer: SaveCode(
        savedFile: savedFile,
        onFileTap: openSavedFile,
      ),
    );
  }
}
