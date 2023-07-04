import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'model.dart';
import 'project_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  String ip = '';
  final _textEditingController = TextEditingController();

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _textEditingController,
                decoration: InputDecoration(
                    hintText: "Enter Ip address to connect to",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    )),
                onChanged: (value) {
                  setState(() {
                    ip = value;
                  });
                },
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  if (_textEditingController.text.isEmpty) {
                    print("Incorrect Ip address");
                  } else {
                    ref
                        .read(apiProvider.notifier)
                        .setIp(_textEditingController.text);
                    if (await ref.read(apiProvider.notifier).getConnection()) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ProjectPage()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Getting connection fail check the ip address: ${_textEditingController.text} again")));
                    }
                  }
                },
                child: Text(
                    "Connect to url: http://${_textEditingController.text}"))
          ],
        ),
      ),
    );
  }
}
