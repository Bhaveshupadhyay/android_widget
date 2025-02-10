import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.registerInteractivityCallback(interactiveCallback);
  bool isPinSupported=await HomeWidget.isRequestPinWidgetSupported() ?? false;
  if(isPinSupported){
    final widgets= await HomeWidget.getInstalledWidgets();
    if(widgets.isEmpty || widgets[0].androidClassName==androidWidgetName){
      HomeWidget.requestPinWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.example.android_widget.CounterWidget',
      );
    }
  }
  runApp(const MyApp());
}

const _countKey='counter';
const String androidWidgetName = 'CounterWidget';

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {
  print(uri?.host);
  if (uri?.host == 'increment') {
    await incrementCounter();
  }
}


Future<int> get _value async {
  final value = await HomeWidget.getWidgetData<int>(_countKey, defaultValue: 0);
  return value!;
}

Future<void> incrementCounter() async {
  final oldValue = await _value;
  final newValue = oldValue + 1;
  _updateCounter(newValue);
}

void _updateCounter(int counter) {
  HomeWidget.saveWidgetData<int>(_countKey, counter);
  HomeWidget.updateWidget(
    androidName: androidWidgetName,
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page',),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _incrementCounter(){
    incrementCounter();
    setState(() {

    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            FutureBuilder(
                future: _value,
                builder: (_,snapshot){
                  return Text(
                    '${snapshot.data??0}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                }
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
