import 'package:flutter/material.dart';
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('習慣状況')),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text('習慣状況',style:TextStyle(fontSize: 20.0)),
              ]
          )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label:'ホーム', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label:'習慣状況', icon: Icon(Icons.calendar_month)),
          BottomNavigationBarItem(label:'設定', icon: Icon(Icons.settings)),
          BottomNavigationBarItem(label:'称号', icon: Icon(Icons.emoji_events)),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
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