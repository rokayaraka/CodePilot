import 'package:codepilot/models/code.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SaveCode extends StatefulWidget {
  const SaveCode({super.key, required this.savedFile, required this.onFileTap});
  final List<Code> savedFile;
  final void Function(Code) onFileTap;

  @override
  State<SaveCode> createState() {
    return _SaveCodeState();
  }
}

class _SaveCodeState extends State<SaveCode> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 10,
      shadowColor: Colors.black12,
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: DrawerHeader(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.grey.shade800,
                  Colors.grey.shade900,
                  Colors.black,
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.file_open,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Saved Files!",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.grey.shade300,
                        ),
                  ),
                ],
              ),
            ),
          ),
          widget.savedFile.isEmpty
              ? SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("No saved files!",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)
                              ),
                      SizedBox(height: 10,),
                      Image.asset("assets/noHistory.gif",
                      height: 150,
                      width: 150,
                      ),
                      
                    ],
                  ),
              )
              : Expanded(
                  child: ListView.builder(
                    itemCount: widget.savedFile.length,
                    itemBuilder: (context, index) {
                      final code = widget.savedFile[index];
                      return Dismissible(
                        key: Key(code.fileName),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          final box = Hive.box<Code>('codes');
                          box.delete(code.fileName);
                          widget.savedFile.removeAt(index);
                          setState(() {});
                        },
                        child: Card(
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.only(
                              bottom: 4, left: 4, right: 4),
                          child: ListTile(
                            title: Text(code.fileName),
                            subtitle: Text('${code.date.toLocal()}'),
                            onTap: () {
                              widget.onFileTap(code);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        'Opened ${code.fileName}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
