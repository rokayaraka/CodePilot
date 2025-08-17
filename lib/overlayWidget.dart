import 'package:flutter/material.dart';

class OverlayWidget extends StatelessWidget{
  const OverlayWidget({super.key,required this.keywordMap});
  final Map<String,List<String>> keywordMap;
  @override
  Widget build(BuildContext context) {
    return Container(
        
        padding: EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Generated Keywords and Identifiers',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(
                color: Colors.grey.shade400,
                thickness: 1.5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Keywords(Total: ${keywordMap['keywords']?.length ?? 0}):',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Identifiers(Total: ${keywordMap['identifiers']?.length ?? 0}):',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.grey.shade400,
                thickness: 1.5,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (final keyword in keywordMap['keywords'] ?? [])
                                Text(
                                  keyword,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                         VerticalDivider(
                            color: Colors.grey.shade400,
                            thickness: 1.5,
                          ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (final identifier in keywordMap['identifiers'] ?? [])
                                Text(
                                  identifier,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  elevation: 5,
                  shadowColor: Colors.blue.shade100,
                  side: BorderSide(
                    color: Colors.grey,
                    width: 2
                  ),
                  
                ),
                child: Text('Close'),
              ),
            ],
          ),
        
      );
  }
}