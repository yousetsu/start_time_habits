import 'package:flutter/material.dart';
import './habits.dart';
import './achievement.dart';
import './setting.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF2196f3),
        hintColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFF515254),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: const Color(0xFF2196f3)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/habits': (context) => const HabitsScreen(),
        '/setting': (context) => const SettingScreen(),
        '/achievement': (context) => const AchievementScreen(),
      },
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第一画面')),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text('第一画面です',style:TextStyle(fontSize: 20.0)),
              ]
          )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label:'ホーム', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label:'習慣状況', icon: Icon(Icons.calendar_month)),
          BottomNavigationBarItem(label:'設定', icon: Icon(Icons.settings)),
          BottomNavigationBarItem(label:'称号', icon: Icon(Icons.emoji_events)),
        ],
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/habits');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/setting');
          }else if (index == 3) {
            Navigator.pushNamed(context, '/achievement');
          }
        },
      ),
    );
  }
}
