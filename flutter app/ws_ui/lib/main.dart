import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
          title: title,
          channel: IOWebSocketChannel.connect(
            "ws://192.168.1.8:5556",
          )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;

  MyHomePage({
    Key key,
    @required this.title,
    @required this.channel,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                    child: Form(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Type your message'),
                  ),
                )),
                ElevatedButton(
                    child: Icon(Icons.send),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: Colors.red)))),
                    onPressed: _sendMessage),
              ],
            ),
            SizedBox(height: 40),
            StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _messages.add(snapshot.data);
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: null == _messages ? 0 : _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      String message = '';
                      if (_messages[index].startsWith("Me: ")) {
                        message = _messages[index]
                            .substring(4, _messages[index].length);
                      } else if (_messages[index].startsWith("My friend: ")) {
                        message = _messages[index]
                            .substring(11, _messages[index].length);
                      }
                      return BubbleSpecialOne(
                        text: message,
                        isSender:
                            _messages[index].startsWith("Me:") ? false : true,
                        tail: true,
                        color: _messages[index].startsWith("Me:")
                            ? Colors.blue
                            : Colors.grey,
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      widget.channel.sink.add(_controller.text);
      _controller.text = "";
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}
