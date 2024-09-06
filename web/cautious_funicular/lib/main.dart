import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MySocketApp(),
    );
  }
}

class MySocketApp extends StatefulWidget {
  @override
  _MySocketAppState createState() => _MySocketAppState();
}

class _MySocketAppState extends State<MySocketApp> {
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    
    // Initialize the Socket.IO client
    socket = IO.io('http://127.0.0.1:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Handle connection
    socket.on('connect', (_) {
      print('web connected');
    });

    // Handle disconnection
    socket.on('disconnect', (_) {
      print('web disconnected');
    });

    // Example: Listen to custom event from the server
    socket.on('event-name', (data) {
      print('Received event: $data');
    });

    // Connect the socket
    socket.connect();
  }

  @override
  void dispose() {
    // Disconnect the socket when the widget is disposed
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket.IO Client in Flutter Web'),
      ),
      body: const Center(
        child: Text('Check the console for socket events'),
      ),
    );
  }
}
