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
    socket = io('https://socket.staging.granite.leentechdev.com:3030', OptionBuilder()
      .setTransports(['websocket'])
      .build());
    socket.onConnectError((e) { /* WHEN CONNECTION FAILED */
      print("onConnectError $e");
      setState(() {
        isConnected = false;
      });
    });
    socket.onConnect((data) {
      print("onConnect $data");
      setState(() {
        isConnected = true;
      });
    });
    socket.onDisconnect((data) {
      print("onDisconnect $data");
      setState(() {
        isConnected = false;
      });
    });
  }
  Future<void> testEmitSocketIo() async {
    var notifications = [
      {
        "sender_user_id": 2,
        "reference_id": 6,
        "type": "new_upcoming_projects",
        "receiver_user_id": 21,
        "message": "You have a new project invitation.",
        "project_date_from": null,
        "project_date_to": null,
        "project_status_id": null,
        "pre_message": "You have a new project invitation.",
        "post_message": null,
        "updated_at": "2022-02-09T11:19:12.000000Z",
        "created_at": "2022-02-09T11:19:12.000000Z",
        "id": 4,
        "display_message": [
          {
            "message": "You have a new project invitation.",
            "color": "474747",
            "weight": 400,
            "bold": false,
            "background": "",
            "badge": false,
            "date": false
          },
          {
            "message": "00006-20220209-00002",
            "color": "2040EB",
            "weight": 800,
            "bold": true,
            "background": "",
            "badge": false,
            "date": false
          }
        ],
        "sender": {
          "id": 2,
          "first_name": "Jim",
          "last_name": "Levi",
          "profile_photo_url": "http://127.0.0.1:8000/storage/images/placeholder/placeholder-default.jpg",
          "location": []
        }
      },
      {
        "sender_user_id": 2,
        "reference_id": 6,
        "type": "new_upcoming_projects",
        "receiver_user_id": 21,
        "message": "You have a new project invitation.",
        "project_date_from": null,
        "project_date_to": null,
        "project_status_id": null,
        "pre_message": "You have a new project invitation.",
        "post_message": null,
        "updated_at": "2022-02-09T11:19:12.000000Z",
        "created_at": "2022-02-09T11:19:12.000000Z",
        "id": 4,
        "display_message": [
          {
            "message": "You have a new project invitation.",
            "color": "474747",
            "weight": 400,
            "bold": false,
            "background": "",
            "badge": false,
            "date": false
          },
          {
            "message": "00006-20220209-00002",
            "color": "2040EB",
            "weight": 800,
            "bold": true,
            "background": "",
            "badge": false,
            "date": false
          }
        ],
        "sender": {
          "id": 2,
          "first_name": "Jim",
          "last_name": "Levi",
          "profile_photo_url": "http://127.0.0.1:8000/storage/images/placeholder/placeholder-default.jpg",
          "location": []
        }
      }
    ];
    socket.emit('notifications', {'message': notifications});
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
            !isConnected ? const Text('Not connected') : const Text('Connected'),
            TextButton(
              onPressed: testEmitSocketIo,
              child: const Text(
                'Test Emit',
              ),
            ),
          ],
        ),
      )
    );
  }
}
