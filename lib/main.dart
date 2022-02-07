import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_socketio_local_notifications/api/notification_api.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Socket socket;
  bool isConnected = false;
  bool roomJoined = false;
  int userId = 1;

  @override
  void initState() {
    super.initState();
    _initSocketIo();
    NotificationApi.init();
    listenNotifications();
  }
  void listenNotifications() {
    NotificationApi.onNotifications.stream.listen(onClickedNotification);
  }
  void onClickedNotification(String? payload) {
    /* DO SOMETHING WHEN YOU CLICK ON THE NOTIFICATION */
  }
  Future<void> _initSocketIo() async { /* INITIALIZE HOST AND PORT */
    /* MAKE SURE THE HOST AND PORT ARE CORRECT. RECOMMENDED PUT THE HOST AND PORT VARIABLE TO ENVIRONMENT SO THAT YOU CAN EASILY CHANGE IT IN THE FUTURE */
    socket = io('https://socketio.granite.leentechdev.com:3030', OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());
  }
  void _connectIO() async { /* ESTABLISH CONNECTION WITH SOCKET.IO */
    socket.connect().onConnectError((e) { /* WHEN CONNECTION FAILED */
      print("onConnectError $e");
    });
    try {
      socket.onConnect((data) { /* WHEN THE CONNECTED SUCCESSFULLY */
        print('Connected');
        setState(() {
          isConnected = true;
        });
      });
      socket.on('message', (data) { /* AFTER CONNECTING, CONSTANTLY LISTEN TO INCOMING MESSAGE */
        var payload = data['message'];
        var sender = payload['user']['first_name'] + ' ' + payload['user']['last_name'];
        var message = payload['message'];
        int id = payload['receiver_id'];
        print(payload);
        if (id == userId) {
          NotificationApi.showNotification(title: sender, body: message, payload: payload.toString());
        }
      });
    } catch(error) {
      setState(() {
        isConnected = false;
      });
      print('error $error');
    }
    
  }
  void _disconnectIO() async { /* DISCONNECT FROM SOCKET.IO */
    socket.disconnect();
    setState(() {
      isConnected = false;
    });
  }
  void _joinRoom() async { /* JOIN TO MESSAGE-CHANNEL-<PROJECT_ID> CHANNEL */
    /* 
    
    NOTE:

    ONLY PEOPLE INSIDE THE ROOM CAN RECEIVE A PUSH NOTIFICATION

    EXAMPLE:
    BACKOFFICE ADMIN, AGENT AND CONTRACTOR HAS A NEW PROJECT WITH ID OF 1
    ALL OF THEM ARE REQUIRED TO JOIN THE CHANNEL MESSAGE-CHANNEL-1

    IF A NEW PROJECT HAS AN ID OF 2
    JOIN ALSO TO MESSAGE-CHANNEL-2

    ETC.

     */
    socket.emit('join', 'message');
    setState(() {
      roomJoined = true;
    });
  }
  void _leaveRoom() async { /* LEAVE FROM MESSAGE-CHANNEL-<PROJECT_ID> CHANNEL */
    /* 
    
    NOTE:

    ONCE A PERSON LEAVES THIS ROOM, HE/SHE CAN NO LONGER RECEIVE ANY PUSH NOTIFICATIONS

     */
    socket.emit('leave', 'message');
    setState(() {
      roomJoined = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(onPressed: !isConnected ? _connectIO : _disconnectIO , child: !isConnected ? const Text('Connect to Socket.IO') : const Text('Disonnect to Socket.IO')),
            isConnected ? FlatButton(onPressed: !roomJoined ? _joinRoom : _leaveRoom , child: !roomJoined ? const Text('Join Messages') : const Text('Leave Messages')) : SizedBox.shrink(),
          ],
        ),
      )
    );
  }
}
