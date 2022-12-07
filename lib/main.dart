import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import './habits.dart';
import './achievement.dart';
import './setting.dart';
import 'dart:io';

const String strCnsSqlCreateRireki ="CREATE TABLE IF NOT EXISTS rireki(id INTEGER PRIMARY KEY, goaltime TEXT, realtime TEXT, status TEXT, kaku1 INTEGER, kaku2 INTEGER, kaku3 TEXT, kaku4 TEXT)";
//-------------------------------------------------------------
//   DB
//-------------------------------------------------------------
/*------------------------------------------------------------------
全共通のメソッド
 -------------------------------------------------------------------*/
//初回起動分の処理
Future<void> firstRun() async {
  String dbpath = await getDatabasesPath();
  //設定テーブル作成
  String path = p.join(dbpath, "internal_assets.db");
  //設定テーブルがなければ、最初にassetsから作る
  var exists = await databaseExists(path);
  if (!exists) {
    // Make sure the parent directory exists
    //親ディレクリが存在することを確認
    try {
      await Directory(p.dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data = await rootBundle.load(p.join("assets", "external_assets.db"));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);

  } else {
    //print("Opening existing database");
  }
  //履歴テーブル作成
  path = p.join(dbpath, "rireki.db");
  await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(strCnsSqlCreateRireki);
        await db.close();
      });

}

//-------------------------------------------------------------
//   main
//-------------------------------------------------------------
void main() {
  //SQLfliteで必要？
  WidgetsFlutterBinding.ensureInitialized();
  //初回DB登録
  firstRun();
  //画面表示
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
  bool habitsFlg = false;
  MaterialColor primaryColor = Colors.orange;
  String strStarstop = 'START';
  int intNum = 1;//実行回数
  int intComboNum = 2;//連続実行回数
  int intDueNum = 3;//開始時間守った回数
  int intComboDueNum = 4;//連続で開始時間守った回数
  int intRestart = 5;//習慣再開回数
  @override
  void initState() {
    super.initState();
    loadPref();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('勉強時間アラーム')),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[
                Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(50.0),
                    alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(border: Border.all(color: Colors.lightBlueAccent), borderRadius: BorderRadius.circular(10), color: Colors.lightBlueAccent,),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  const <Widget>[
                        Text('習慣開始まで',style:TextStyle(fontSize: 20.0)),
                        Text('あと　時間　分　秒',style:TextStyle(fontSize: 20.0))
                      ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(20.0),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightBlueAccent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  <Widget>[
                      Text('習慣実行回数',style:TextStyle(fontSize: 20.0)),
                      Text('$intNum回',style:TextStyle(fontSize: 20.0))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(20.0),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightBlueAccent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  <Widget>[
                      Text('習慣連続実行回数',style:TextStyle(fontSize: 20.0)),
                      Text('$intComboNum回',style:TextStyle(fontSize: 20.0))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(20.0),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightBlueAccent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  <Widget>[
                      Text('開始時間前に始めた回数',style:TextStyle(fontSize: 20.0)),
                      Text('$intDueNum回',style:TextStyle(fontSize: 20.0))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(20.0),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightBlueAccent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  <Widget>[
                      Text('開始時間前に始めた連続回数',style:TextStyle(fontSize: 20.0)),
                      Text('$intComboDueNum回',style:TextStyle(fontSize: 20.0))
                    ],
                  ),
                ),
                SizedBox(
                  width: 200, height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: primaryColor, shape: const StadiumBorder(), elevation: 16,),
                    onPressed: buttonPressed,
                    child: Text( '習慣開始', style: const TextStyle(fontSize: 35.0, color: Colors.white,),),
                  ),
                ),
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
  Future<void> buttonPressed() async {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title:  Text('確認'),
            content: Text('習慣を開始しますか？'),
            actions: <Widget>[
              TextButton(
                  child: Text('はい'),
                  onPressed: () => Navigator.pop<String>(context, 'Yes')),
              TextButton(
                  child: Text('ちょっと待って'),
                  onPressed: () => Navigator.pop<String>(context, 'No')),
            ],
          )).then<void>((value) => resultAlert(value));
    }
  void resultAlert(String value) {
    setState(() {
      switch (value) {
        case 'Yes':




          //アチーブメントがあれば表示
          // showDialog(context: context,
          //     builder: (BuildContext context) => AlertDialog(
          //       title: Text(AppLocalizations.of(context)!.confirm),
          //       content: Text(AppLocalizations.of(context)!.moveforward),
          //       actions: <Widget>[
          //         TextButton(
          //             child: const Text('OK'),
          //             onPressed: () => Navigator.pop<String>(context, 'Ok')),
          //       ],
          //     )).then<void>((value) => resultSuccess(value));
          break;
        case 'No':
          break;
      }
    });
  }
  /*------------------------------------------------------------------
第一画面ロード
 -------------------------------------------------------------------*/
  void loadPref() async {
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
     Database database = await openDatabase(path, version: 1);
     List<Map> result = await database.rawQuery("SELECT * From habits  limit 1");
     for (Map item in result) {
       setState(() {
         intNum = item['num'];
         intComboNum = item['combo_num'];
         intDueNum = item['due_num'];
         intComboDueNum = item['combodue_num'];
         intRestart = item['restart'];
       });
    }
    database.close();
  }


}
