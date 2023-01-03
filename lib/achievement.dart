import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './global.dart';

List<Map> achievementUserMap = <Map>[];

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  List<Widget> _items = <Widget>[];
  String listNo ='';
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
          BottomNavigationBarItem(label:'ホーム', icon: Icon(Icons.home),backgroundColor: Colors.blue),
          BottomNavigationBarItem(label:'習慣状況', icon: Icon(Icons.calendar_month),backgroundColor: Colors.blue),
          BottomNavigationBarItem(label:'設定', icon: Icon(Icons.settings),backgroundColor: Colors.blue),
          BottomNavigationBarItem(label:'称号', icon: Icon(Icons.emoji_events),backgroundColor: Colors.blue),
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
              Text('No       ', style:  const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              Text('称号タイトル', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ])));
  }
  void getItems() async {
    List<Widget> list = <Widget>[];
    //アチーブメントユーザーマスタから達成状況をロード
    achievementUserMap = await  _loadAchievementUser();

    bool boolAchieveReleaseFlg = false;

    for (Map item in achievementMapList) {
      boolAchieveReleaseFlg = false;
      //既にアチーブメント達成してたら白色表示解放
      for (Map serchAchMap in achievementUserMap){
        if( item['No'] == serchAchMap['No']){
          boolAchieveReleaseFlg = true;
        }
      }
      list.add(

          ListTile(
        //tileColor: Colors.grey,
        // tileColor: (item['getupstatus'].toString() == cnsGetupStatusS)
        //     ? Colors.green
        //     : Colors.grey,
        // leading: (item['getupstatus'].toString() == cnsGetupStatusS)
        //     ? const Icon(Icons.thumb_up)
        //     : const Icon(Icons.redo),
        title:Text('${item['No']}        ${item['title']}',
          style:  TextStyle(color: boolAchieveReleaseFlg ? Colors.black : Colors.grey,fontSize: 15),),
              dense: true,
              selected: listNo == item['No'],
              onTap: () {listNo = item['No'];_tapTile();}
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
    int intRestart = 0;
    String strContent = '';
    bool boolAchRelease = false;
    //アチーブメントを達成していないものは表示しない
    for (Map serchAchMap in achievementUserMap){
      if( serchAchMap['No'] == listNo) {
        boolAchRelease = true;
      }
    }
   if (!boolAchRelease){
     return;
   }

    for (Map item in achievementMapList)
      {
        if(item['No'] == listNo) {
          strTitle = item['title'].toString();
          strBody = item['body'].toString();
          intNum = item['num'];
          intComboNum = item['combo_num'];
          intDueNum = item['due_num'];
          intCombodueNum = item['combodue_num'];
          intRestart = item['restart'];
        }
      }

    if(intNum > 0){
      strContent ='$strBody \n\n <達成条件>\n 習慣をはじめた回数　$intNum回以上\n ';
    }
    if(intComboNum > 0){
      strContent ='$strBody \n\n <達成条件>\n 習慣をはじめた継続日数　$intComboNum日以上\n ';
    }
    if(intDueNum > 0){
      strContent ='$strBody \n\n <達成条件>\n 目標時間内にはじめた回数　$intDueNum回以上\n ';
    }
    if(intCombodueNum > 0){
      strContent ='$strBody \n\n <達成条件>\n 目標時間内にはじめた継続日数　$intCombodueNum日以上\n ';
    }
    if(intRestart > 0){
      strContent ='$strBody \n\n <達成条件>\n リスタートした回数　$intRestart回以上\n ';
    }

    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title:  Text(strTitle,style:  TextStyle( fontSize: 18)),
          content: Text(strContent,style:  TextStyle( fontSize: 12)),
          actions: <Widget>[
            TextButton(
                child: Text('閉じる'),
                onPressed: () => Navigator.pop<String>(context, 'Yes')),
          ],
        ));
        //.then<void>((value) => resultAlert(value));
  }
  /*------------------------------------------------------------------
アチーブメントユーザーマスタロード
 -------------------------------------------------------------------*/
  Future<List<Map>> _loadAchievementUser() async{
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'achievement.db');
    Database database = await openDatabase(path, version: 1);
    List<Map> result = await database.rawQuery("SELECT * from achievement_user ");
   // await database.close();
    return result;

  }
}