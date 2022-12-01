import 'package:flutter/material.dart';
class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
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
        currentIndex: 3,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label:'ホーム', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label:'習慣状況', icon: Icon(Icons.calendar_month)),
          BottomNavigationBarItem(label:'設定', icon: Icon(Icons.settings)),
          BottomNavigationBarItem(label:'称号', icon: Icon(Icons.emoji_events)),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/habits');
          }else if (index == 2) {
            Navigator.pushNamed(context, '/setting');
          }
        },
      ),
    );
  }
}