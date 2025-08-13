import 'package:codepilot/models/code.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SaveCode extends StatelessWidget{
  const SaveCode({super.key,required this.savedFile, required this.onFileTap});
  final List<Code> savedFile;
  final void Function(Code) onFileTap;
  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 10,
        shadowColor: Colors.black12,
        child:  Column(
            children: [
              SizedBox(
                height: 100,
                child: DrawerHeader(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade800,
                      Colors.grey.shade900,
                      Colors.black,
                    ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
                  ),
                ),
                child:  Row(
                    children: [
                      Icon(Icons.file_open,color: Theme.of(context).colorScheme.inverseSurface,),
                      const SizedBox(width: 5,),
                      Text("Saved Files!",style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),),
                    ],
                  ),
                
                ),
              ),
              savedFile.isEmpty? Center(child: Text("No saved files",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold
              )
              )):
              Expanded(
                child: ListView.builder(
                  itemCount: savedFile.length,
                  itemBuilder: (context, index) {
                    final code = savedFile[index];
                    return Dismissible(
                      key: Key(code.fileName),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        final box = Hive.box<Code>('codes');
                        box.delete(code.fileName);
                        savedFile.removeAt(index);
                        
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Row(
                            children: [
                              Icon(Icons.delete,color: Colors.white,),
                              SizedBox(width: 8,),
                              Text(
                            'Deleted ${code.fileName}',
                            style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                            ],
                          ),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: Card(
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.only(bottom: 4,left: 4,right: 4),
                        child: ListTile(
                          title: Text(code.fileName),
                          subtitle: Text('${code.date.toLocal()}'),
                          onTap: () {
                            onFileTap(code);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Row(
                                children: [
                                  Icon(Icons.check_circle,color: Colors.white,),
                                  SizedBox(width: 8,),
                                  Text(
                                    'Opened ${code.fileName}',
                                    style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
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