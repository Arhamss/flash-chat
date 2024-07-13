import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.black),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.black54),
  ),
  contentPadding: EdgeInsets.fromLTRB(18, 10, 10, 0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
  hintStyle: TextStyle(
    fontSize: 18,
  ),
  hoverColor: Colors.black54,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
  color: Colors.white,
);

const KTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {super.key,
      required this.col,
      required this.onPress,
      required this.cardText});

  final Color col;
  final Function()? onPress;
  final String cardText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: col,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPress,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            cardText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}
