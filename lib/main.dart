import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import './habits.dart';
import './achievement.dart';
import './setting.dart';
import './const.dart';
import 'dart:io';
import './global.dart';

const String strCnsSqlCreateRireki ="CREATE TABLE IF NOT EXISTS rireki(id INTEGER PRIMARY KEY, goaltime TEXT, realtime TEXT, status TEXT, kaku1 INTEGER, kaku2 INTEGER, kaku3 TEXT, kaku4 TEXT)";
const String strCnsSqlCreateAchievement ="CREATE TABLE IF NOT EXISTS achievement_user(id INTEGER PRIMARY KEY, No TEXT,kaku1 INTEGER, kaku2 INTEGER, kaku3 TEXT, kaku4 TEXT)";

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
  //
  path = p.join(dbpath, "achievement.db");
  await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(strCnsSqlCreateAchievement);
        await db.close();
      });

}
//-------------------------------------------------------------
//   main
//-------------------------------------------------------------
void main() async{
  //SQLfliteで必要？
  WidgetsFlutterBinding.ensureInitialized();

  await firstRun();

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
  String? strMode = '';
  DateTime everyTime = DateTime.utc(0, 0, 0);
  DateTime normalTime = DateTime.utc(0, 0, 0);
  DateTime holidayTime = DateTime.utc(0, 0, 0);
  @override
  void initState() {
    super.initState();
    loadPref();
    loadSetting();
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
          //履歴・習慣状況テーブルに更新
          //アチーブメント判定・表示、データ登録
          saveRirekiHabitsData();
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
    await database.close();
  }
  /*------------------------------------------------------------------
設定情報のロード
 -------------------------------------------------------------------*/
  void loadSetting() async {
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1);
    List<Map> result = await database.rawQuery("SELECT * From setting  limit 1");
    for (Map item in result) {
      setState(() {
        strMode = item['mode'].toString();
        normalTime = DateTime.parse(item['normalstarttime'].toString());
        holidayTime = DateTime.parse(item['holidaystarttime'].toString());
        everyTime = DateTime.parse(item['everystarttime'].toString());
      });
    }
    await database.close();
  }
  /*------------------------------------------------------------------
直前の履歴データロード
 -------------------------------------------------------------------*/
  Future<String?> _loadStrRireki(String field) async{
    String? strValue = "";
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'rireki.db');
    Database database = await openDatabase(path, version: 1);
    List<Map> result = await database.rawQuery("SELECT $field From (SELECT $field From rireki order by realtime desc ) limit 1");
    for (Map item in result) {
      strValue = item[field].toString();
    }
    await database.close();
    return strValue;

  }

//-------------------------------------------------------------
//   データベースにデータ保存
//-------------------------------------------------------------

  void saveRirekiHabitsData() async {
    String strNowDate = DateTime.now().toString();
    String strGoalTime;
    //比較用の変数
    DateTime dtNowDate = DateTime.utc(0,0,0,DateTime.now().hour,DateTime.now().minute,0);
    DateTime dtGoalTime;

    //ステータス
    String strStatus = cnsStatusHabits; //習慣を実行

    //履歴テーブルからデータ取得
    String dbPath = await getDatabasesPath();

    //前回の時刻
    String? strPreRealTime;
    //前回のステータス
    String? strPreStatus;

    //履歴テーブルから直前の時刻を取得
    strPreRealTime = await _loadStrRireki('realtime') ;

    //履歴テーブルから直前のステータスを取得
    strPreStatus = await _loadStrRireki('status') ;

    //習慣状況テーブルにデータ保存
    String habitsPath = p.join(dbPath, 'internal_assets.db');

    //期限を守れているか判定
    //毎日
    if (strMode == cnsModeEveryDay){
      strGoalTime = everyTime.toString();
    }else{
      //土日の場合
      if (DateTime.now().weekday == 6 || DateTime.now().weekday == 7) {
        strGoalTime = holidayTime.toString();
      }
      //平日の場合
      else {
        strGoalTime = normalTime.toString();
      }
    }
    //比較用
    dtGoalTime = DateTime.parse(strGoalTime.toString());

    //ステータス判定
    //現在時刻が、目標時間以内だったら期限内実成功
    // 目標時間　>　現在時間
    if(dtGoalTime.isAfter(dtNowDate)) {
      strStatus = cnsStatusHabitsDue; //習慣を期限内に実行
    }

    //実行回数をカウントアップ
    setState(() {intNum++;});

    //直前の日時が1日前だったら、連続実行回数をカウントアップ
    DateTime dtPreRealTime =  DateTime.parse(strPreRealTime.toString());
    DateTime dtNowDateYest = dtNowDate.add(const Duration(days: -1));

    if(dtPreRealTime.isAtSameMomentAs(dtNowDateYest)){
      setState(() {intComboNum++;});
    }

    //期限を守っていればカウントアップ
    if(strStatus == cnsStatusHabitsDue){
      setState(() {intDueNum++;});
    }

    //昨日のデータが存在しかつ、前回今回共に　習慣を守っていればカウントアップ
    if(dtPreRealTime.isAtSameMomentAs(dtNowDateYest)) {
      if(strPreStatus == cnsStatusHabitsDue && strStatus == cnsStatusHabitsDue){
        setState(() {intComboDueNum++;});
      }
    }

    //前回の実績がなかったらカウントアップ
    if(dtPreRealTime.isAtSameMomentAs(dtNowDateYest) == false ){
      setState(() {intRestart++;});
    }
    //習慣テーブルにアップデート
    String strHapitsPath = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(strHapitsPath, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(strCnsSqlCreateRireki);
        });
    String query =
        'Update habits set num = $intNum,combo_num = $intComboNum ,due_num = $intDueNum,combodue_num = $intComboDueNum ,restart = $intRestart';
    await database.transaction((txn) async {
//      int id = await txn.rawInsert(query);
      await txn.rawInsert(query);
      //   print("insert: $id");
    });
    database.close();

    //履歴テーブルに登録
    String path = p.join(dbPath, 'rireki.db');
     database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(strCnsSqlCreateRireki);
        });
     query =
        'INSERT INTO rireki(goaltime,realtime, status,kaku1,kaku2,kaku3,kaku4) values("$strGoalTime","$strNowDate","$strStatus",null,null,null,null)';
    await database.transaction((txn) async {
//      int id = await txn.rawInsert(query);
      await txn.rawInsert(query);
      //   print("insert: $id");
    });
    await database.close();

   //アチーブメントユーザーマスタから達成状況をロード
    List<Map> achievementUserMap = await  _loadAchievementUser();

    //アチーブメント判定
    String strTitle ='';
    String strContent = '';
    String strNo = '';
    bool boolAchievementFlg = false;
    bool boolAlreadyAchieveFlg = false;

    for (Map item in achievementMapList)
    {
      boolAlreadyAchieveFlg = false;
      boolAchievementFlg = false;

      //既にアチーブメント達成してたら除外
      for (Map serchAchMap in achievementUserMap){
       if( item['No'] == serchAchMap['No']){
         boolAlreadyAchieveFlg = true;
       }
      }
      if(boolAlreadyAchieveFlg){
        //既に称号を獲得していたら次へ
        continue;
      }
      // Map<dynamic, dynamic> find = achievementUserMap.firstWhere((No) => item['No'] == 0);
      // if (find.isNotEmpty){
      //   continue;
      // }

      //アチーブメント判定
      if(item['num'] != 0 && item['num'] <= intNum){
        boolAchievementFlg = true;
        strNo    = item['No'];
        strTitle = item['title'];
        strContent ='$strTitle \n\n <達成条件>\n 習慣実行回数　${item['num']}回以上\n ';
      }
      if(item['combo_num'] != 0 && item['combo_num'] <= intComboNum){
        boolAchievementFlg = true;
        strNo    = item['No'];
        strTitle = item['title'];
        strContent ='$strTitle \n\n <達成条件>\n 習慣連続実行回数　${item['combo_num']}回以上\n ';

      }
      if(item['due_num'] != 0 && item['due_num'] <= intDueNum){
        boolAchievementFlg = true;
        strNo    = item['No'];
        strTitle = item['title'];
        strContent ='$strTitle \n\n <達成条件>\n 目標時間内に実行した回数　${item['due_num']}回以上\n ';
      }
      if(item['combodue_num'] != 0 && item['combodue_num'] <= intComboDueNum){
        boolAchievementFlg = true;
        strNo    = item['No'];
        strTitle = item['title'];
        strContent ='$strTitle \n\n <達成条件>\n 目標時間内に実行した連続回数　${item['combodue_num']}回以上\n ';
      }
    }
    //アチーブメントダイアログ表示（共通）
    if(boolAchievementFlg){
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title:  Text('称号獲得！'),
            content: Text(strContent),
            actions: <Widget>[
              TextButton(
                  child: Text('閉じる'),
                  onPressed: () => Navigator.pop<String>(context, 'Yes')),
            ],
          ));

    //アチーブメントユーザーマスタに登録
    path = p.join(dbPath, 'achievement.db');
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(strCnsSqlCreateAchievement);
        });
    query = 'INSERT INTO achievement_user(No,kaku1,kaku2,kaku3,kaku4) values("$strNo",null,null,null,null)';
    await database.transaction((txn) async {
//      int id = await txn.rawInsert(query);
      await txn.rawInsert(query);
      //   print("insert: $id");
    });
    await database.close();
    }
  }
  /*------------------------------------------------------------------
アチーブメントユーザーマスタロード
 -------------------------------------------------------------------*/
  Future<List<Map>> _loadAchievementUser() async{
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'achievement.db');
    Database database = await openDatabase(path, version: 1);
    List<Map> result = await database.rawQuery("SELECT * from achievement_user ");
    await database.close();
    return result;

  }
}
