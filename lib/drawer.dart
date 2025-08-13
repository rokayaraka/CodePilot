import 'package:flutter/material.dart';

class SaveCode extends StatelessWidget{
  const SaveCode({super.key});
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
              
            ],
          ),
        
      );
  }
}