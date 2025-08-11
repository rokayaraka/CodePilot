import 'package:flutter/material.dart';

class Editor extends StatefulWidget{
  final String startHere="// Write your code here\n";
  final TextEditingController code;
  const Editor({super.key, required this.code});
  @override
  _EditorState createState() => _EditorState();
}
class _EditorState extends State<Editor> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: TextField(
        controller: widget.code,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: widget.startHere,
        ),
        style: TextStyle(fontFamily: 'code', fontSize: 18),
      ),
    );
  }
}