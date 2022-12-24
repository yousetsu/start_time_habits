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
    String strTitle ='';
    String strBody ='';
    int intNum = 0;
    int intComboNum = 0;
    int intDueNum = 0;
    int intCombodueNum = 0;
    String strCondition ='';
    String strContent = '';
    for (Map item in achievementMapList)
      {
        if(item['id'] == _index) {
          strTitle = item['title'].toString();
          strBody = item['body'].toString();
          intNum = item['num'];
          intComboNum = item['combo_num'];
          intDueNum = item['due_num'];
          intCombodueNum = item['combodue_num'];
        }
      }

    if(intNum > 0){
      strContent ='$strBody \n\n <達成条件>\n 習慣実行回数　$intNum回以上\n ';
    }
    if(intComboNum > 0){
      strContent ='$strBody \n\n <達成条件>\n 習慣連続実行回数　$intComboNum回以上\n ';
    }
    if(intComboNum > 0){
      strContent ='$intDueNum \n\n <達成条件>\n 目標時間内に実行した回数　$intDueNum回以上\n ';
    }
    if(intCombodueNum > 0){
      strContent ='$intCombodueNum \n\n <達成条件>\n 目標時間内に実行した連続回数　$intCombodueNum回以上\n ';
    }
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title:  Text(strTitle),
          content: Text(strContent),
          actions: <Widget>[
            TextButton(
                child: Text('閉じる'),
                onPressed: () => Navigator.pop<String>(context, 'Yes')),
          ],
        ));
        //.then<void>((value) => resultAlert(value));
  }
}