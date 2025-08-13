import 'package:codepilot/api_services.dart';
import 'package:codepilot/drawer.dart';
import 'package:codepilot/editor.dart';
import 'package:codepilot/models/language.dart';
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
  _MyHomePageState createState() => _MyHomePageState();
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

  void openSavedFile(Code code) {
    setState(() {
      _codeController.text = code.code;
      selectedLanguage = code.language;
      _inputController.text = ""; // Clear input field
      _output = "Output will be displayed here"; // Reset output
    });
  }

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
                            savedFile.add(box.get(fileName)!);
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
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))),
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
                        : languages.first,
                    dropdownColor: Theme.of(context).canvasColor,
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.grey.shade300),
                    items: languages.map((lang) {
                      return DropdownMenuItem<Language>(
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
                      });
                    },
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
          SizedBox(
            width: 10,
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
