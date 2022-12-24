import 'package:flutter/material.dart';
import './global.dart';
class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  List<Widget> _items = <Widget>[];
  String _index ='';
  @override
  void initState() {
    super.initState();
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('称号')),
     // body: SingleChildScrollView(
     //   child:Column(
          body: Column(
          children: <Widget>[
            _listHeader(),
            Expanded(
              child: ListView(
                children: _items,
              ),
            ),
          ],
        ),
      //),
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
  Widget _listHeader() {
    return Container(
        decoration:  const BoxDecoration(
            border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
        child: ListTile(
            title:  Row(children:  <Widget>[
              Expanded(child:  Text('No', style:  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(child:  Text('title', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ])));
  }
  void getItems() async {
    List<Widget> list = <Widget>[];

    for (Map item in achievementMapList) {
      list.add(ListTile(
        //tileColor: Colors.grey,
        // tileColor: (item['getupstatus'].toString() == cnsGetupStatusS)
        //     ? Colors.green
        //     : Colors.grey,
        // leading: (item['getupstatus'].toString() == cnsGetupStatusS)
        //     ? const Icon(Icons.thumb_up)
        //     : const Icon(Icons.redo),
        title:Text('      ${item['id']}             ${item['title']}',
          style: const TextStyle(color: Colors.grey,fontSize: 20),),
        dense: true,
          selected: _index == item['id'],
          onTap: () {
            _index = item['id'];
            _tapTile();
          }
      ));
    }
    setState(() {
      _items = list;
    });
  }
  void _tapTile() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title:  Text('内容'),
          content: Text('No. $_index を選択しました'),
          actions: <Widget>[
            TextButton(
                child: Text('閉じる'),
                onPressed: () => Navigator.pop<String>(context, 'Yes')),
          ],
        ));
        //.then<void>((value) => resultAlert(value));
  }
}