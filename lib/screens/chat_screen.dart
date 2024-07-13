import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('HH:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0) {
    time = format.format(date);
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = '${diff.inDays} DAY AGO';
    } else {
      time = '${diff.inDays} DAYS AGO';
    }
  } else {
    if (diff.inDays == 7) {
      time = '${(diff.inDays / 7).floor()} WEEK AGO';
    } else {
      time = '${(diff.inDays / 7).floor()} WEEKS AGO';
    }
  }

  return time;
}

class ChatScreen extends StatefulWidget {
  static const String id = 'ChatScreen';

  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final _firestore = FirebaseFirestore.instance;
late auth.User loggedInUser;

class _ChatScreenState extends State<ChatScreen> {
  final _auth = auth.FirebaseAuth.instance;
  late String messageText;
  final _controller = TextEditingController();
  final ScrollController _lcontroller = ScrollController();

  void _scrollDown() {
    _lcontroller.animateTo(
      _lcontroller.position.maxScrollExtent + 200,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "images/background.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.popUntil(
                    context, ModalRoute.withName(WelcomeScreen.id));
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 30,
              ),
            ),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 30),
                  onPressed: () {
                    _auth.signOut();
                    Navigator.popUntil(
                        context, ModalRoute.withName(WelcomeScreen.id));
                  }),
            ],
            title: const Text(
              '⚡️Chat',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            backgroundColor: Colors.lightBlueAccent,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Bubble(
                  color: const Color.fromRGBO(212, 234, 244, 1.0),
                  child: const Padding(
                    padding: EdgeInsets.all(3),
                    child: Text('TODAY',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13)),
                  ),
                ),
              ),
              MessagesStream(control: _lcontroller),
              Container(
                decoration: kMessageContainerDecoration,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 0, 26),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
                        child: IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            size: 35,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: (value) {
                            messageText = value;
                          },
                          decoration: kMessageTextFieldDecoration,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 7, 0),
                        child: IconButton(
                          onPressed: () {
                            _controller.clear();
                            _firestore.collection('messages').add({
                              'timeStamp': FieldValue.serverTimestamp(),
                              'text': messageText,
                              'sender': loggedInUser.email,
                            });
                            _scrollDown();
                          },
                          icon: const Icon(
                            Icons.send_outlined,
                            size: 32,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({Key? key, required this.control}) : super(key: key);
  final ScrollController control;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('messages').orderBy('timeStamp').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ChatBubble> messageWidgets = [];
          final messages = snapshot.data!.docs;
          for (var message in messages) {
            if (message.data() != null) {
              final messageText = message.get('text');
              final messageSender = message.get('sender');
              final dt = (message.get('timeStamp')) == null
                  ? DateTime.now()
                  : (message.get('timeStamp')).toDate();
              String formattedHour = DateFormat.jm().format(dt);
              final currentUser = loggedInUser.email;
              final messageWidget = ChatBubble(
                sender: messageSender,
                text: messageText,
                hour: formattedHour,
                isMe: currentUser == messageSender,
              );
              messageWidgets.add(messageWidget);
            }
          }
          return Expanded(
            child: ListView(
              shrinkWrap: true,
              controller: control,
              physics: const BouncingScrollPhysics(),
              children: messageWidgets,
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  ChatBubble(
      {Key? key,
      required this.sender,
      required this.text,
      required this.hour,
      required this.isMe})
      : super(key: key);

  final String sender;
  final String text;
  final String hour;
  final bool isMe;

  Color? shadowColor;
  Color? bubbleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
            child: Text(
              sender,
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Bubble(
            elevation: 5,
            nip: isMe ? BubbleNip.rightTop : BubbleNip.leftTop,
            shadowColor: isMe ? Colors.blue : Colors.black,
            margin: isMe
                ? const BubbleEdges.fromLTRB(80, 0, 4, 0)
                : const BubbleEdges.fromLTRB(4, 0, 80, 0),
            radius: const Radius.circular(20.0),
            color: isMe
                ? const Color.fromRGBO(64, 210, 255, 1.0)
                : const Color.fromRGBO(255, 255, 255, 1.0),
            child: Stack(
              alignment: isMe
                  ? AlignmentDirectional.topEnd
                  : AlignmentDirectional.topStart,
              children: <Widget>[
                Padding(
                  padding: isMe
                      ? const EdgeInsets.only(
                          left: 10,
                          right: 60,
                          top: 5,
                          bottom: 8,
                        )
                      : const EdgeInsets.only(
                          left: 10,
                          right: 60,
                          top: 5,
                          bottom: 8,
                        ),
                  child: Text(
                    text,
                    textAlign: TextAlign.left,
                    style: isMe
                        ? const TextStyle(color: Colors.white, fontSize: 16)
                        : const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: 5,
                  child: Row(
                    children: [
                      Text(
                        hour,
                        textAlign: TextAlign.right,
                        style: isMe
                            ? const TextStyle(color: Colors.white, fontSize: 12)
                            : const TextStyle(
                                color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
