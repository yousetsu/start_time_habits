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
//時間になったらローカル通知を出すため
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//kIsWeb(Web判定)を使うため
import 'package:flutter/foundation.dart';
//ローカル通知の時間をセットするためタイムゾーンの定義が必要
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';


const String strCnsSqlCreateRireki ="CREATE TABLE IF NOT EXISTS rireki(id INTEGER PRIMARY KEY, goaltime TEXT, realtime TEXT, status TEXT, kaku1 INTEGER, kaku2 INTEGER, kaku3 TEXT, kaku4 TEXT)";
const String strCnsSqlCreateAchievement ="CREATE TABLE IF NOT EXISTS achievement_user(id INTEGER PRIMARY KEY, No TEXT,kaku1 INTEGER, kaku2 INTEGER, kaku3 TEXT, kaku4 TEXT)";
//アラーム用のID
const int alarmID = 123456788;
//-------------------------------------------------------------
///ローカル通知のための準備
//-------------------------------------------------------------

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
String? selectedNotificationPayload;
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();
final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();
const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');
class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
const String navigationActionId = 'id_3';
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}
//タイムゾーン初期化メソッド定義
Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}
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

  //タイムゾーン初期化
  await _configureLocalTimeZone();


  //通知のための初期化
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
      Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
  }
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  //画面表示
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        //primaryColor: const Color(0xFF2196f3),
        primaryColor: Colors.blue,
        hintColor: const Color(0xFF2196f3),
        canvasColor: Colors.white,
      //  canvasColor: const Color(0xFF515254),
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
  String notificationFlg = '0';
  DateTime notificationTime = DateTime.utc(0, 0, 0);
  String firstSet = '0';

  String limitTimeText = '';
  String limitTime = '';
  bool todayHabitsStart = false; //本日の習慣開始ボタンを押したか？
  DateTime goalTimeParse = DateTime.utc(0, 0, 0);

  String strGoalTime = '';

  DateTime dtNowDate = DateTime.utc(0, 0, 0);


  @override
  void initState() {
    super.initState();
    init();
    Timer.periodic(Duration(seconds: 1), _onTimer);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('はじめる習慣')),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[
                Container(
                    margin: const EdgeInsets.all(25.0),
                    padding: const EdgeInsets.all(20.0),
                    alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(10), color: Colors.blue,),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:   <Widget>[
                        Text('本日の目標開始時間',style:TextStyle(color: Colors.white,fontSize: 20.0)),
                        Text( '${goalTimeParse.hour.toString().padLeft(2, '0')}:${goalTimeParse.minute.toString().padLeft(2, '0')}',style:TextStyle(color: Colors.white,fontSize: 40.0)),
                        Text(limitTimeText.toString(),style:TextStyle(color: Colors.white,fontSize: 20.0)),
                        Text(limitTime.toString(),style:TextStyle(color: Colors.white,fontSize: 40.0))
                      ],
                  ),
                ),

                SizedBox(
                  width: 200, height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor:todayHabitsStart?Colors.grey:primaryColor, shape: const StadiumBorder(), elevation: 16,),
                    onPressed: todayHabitsStart?null:buttonPressed,
                    child: Text( todayHabitsStart?'済':'習慣開始', style: const TextStyle(fontSize: 30.0, color: Colors.white,),),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.all(25.0),
                  padding: const EdgeInsets.all(20.0),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                  ),
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  <Widget>[
                      Row(children:  <Widget>[Icon(Icons.toc,color: Colors.white,), Text('実績',style:TextStyle(fontSize: 25.0,color: Colors.white),),],),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:  <Widget>[
                            Text('習慣開始    ',style:TextStyle(fontSize: 20.0,color: Colors.white)),
                            Text('$intNum',style:TextStyle(fontSize: 40.0,color: Colors.white)),
                            Text('    回',style:TextStyle(fontSize: 20.0,color: Colors.white)),
                          ]),

                      Text('現在　$intComboNum日継続中',style:TextStyle(fontSize: 20.0,color: Colors.white)),
                      Text('',),
                      Text('目標時間内に開始　$intDueNum回',style:TextStyle(fontSize: 20.0,color: Colors.white)),
                      Text('現在　$intComboDueNum日継続中',style:TextStyle(fontSize: 20.0,color: Colors.white))
                    ],
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
          todayHabitsStart = true;
          //履歴・習慣状況テーブルに更新
        debugPrint("習慣開始はい押下");
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
  Future<void>  loadPref() async {
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
  Future<void>  loadSetting() async {
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
        notificationFlg = item['notification'].toString();
        notificationTime = DateTime.parse(item['everystarttime'].toString());
        firstSet = item['firstset'].toString();
      });
    }
    await database.close();
    debugPrint('loadSetting notificationFlg:$notificationFlg');
  }
  /*------------------------------------------------------------------
直前の履歴データロード
 -------------------------------------------------------------------*/
  Future<String?> _loadStrRireki(String field) async{
    String? strValue = "";
    debugPrint('getDatabasesPath');
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'rireki.db');
    debugPrint('openDatabase');
    debugPrint('path:$path');
    Database database = await openDatabase(path, version: 1);
    debugPrint('database.rawQuery');
    List<Map> result = await database.rawQuery("SELECT $field From (SELECT $field From rireki order by realtime desc ) limit 1");
    debugPrint('Map item in result');
    for (Map item in result) {
      debugPrint('strValue:$strValue');
      strValue = item[field].toString();
    }
    debugPrint('database.close()');
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
    DateTime dtNowDateVs = DateTime.utc(2016,5,1,dtNowDate.hour,dtNowDate.minute,0);
    DateTime dtGoalTime;

    //現在日時を退避
    dtNowDate = DateTime.parse(strNowDate.toString());


    //ステータス
    String strStatus = cnsStatusHabits; //習慣を実行

    //履歴テーブルからデータ取得
    String dbPath = await getDatabasesPath();

    //前回の時刻
    String? strPreRealTime;
    //前回のステータス
    String? strPreStatus;

    //履歴テーブルから直前の時刻を取得
    debugPrint('履歴テーブルから直前の時刻を取得');
    strPreRealTime = await _loadStrRireki('realtime') ;

    //履歴テーブルから直前のステータスを取得
    debugPrint('履歴テーブルから直前のステータスを取得');
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
    if(dtGoalTime.isAfter(dtNowDateVs)) {
      strStatus = cnsStatusHabitsDue; //習慣を期限内に実行
    }

    //実行回数をカウントアップ
    setState(() {intNum++;});

    //直前の日時が1日前だったら、連続実行回数をカウントアップ
    DateTime dtPreRealTime =  DateTime.parse(strPreRealTime.toString());
    DateTime dtNowDateYest = dtNowDateVs.add(const Duration(days: -1));

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
    debugPrint('習慣テーブルにアップデート');
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
    debugPrint('履歴テーブルに登録');
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

    for (Map item in achievementMapList) {
      boolAlreadyAchieveFlg = false;

      //既にアチーブメント達成してたら除外
      for (Map serchAchMap in achievementUserMap) {
        if (item['No'] == serchAchMap['No']) {
          boolAlreadyAchieveFlg = true;
        }
      }
      if (boolAlreadyAchieveFlg) {
        //既に称号を獲得していたら次へ
        continue;
      }
      // Map<dynamic, dynamic> find = achievementUserMap.firstWhere((No) => item['No'] == 0);
      // if (find.isNotEmpty){
      //   continue;
      // }

      //アチーブメント判定
      debugPrint('アチーブメント判定');
      if (item['num'] != 0 && item['num'] <= intNum) {
        boolAchievementFlg = true;
        strNo = item['No'];
        strTitle = item['title'];
        strContent = '$strTitle \n\n <達成条件>\n 習慣実行回数　${item['num']}回以上\n ';
        debugPrint('No:$strNo title:$strTitle content:$strContent');
      }
      if (item['combo_num'] != 0 && item['combo_num'] <= intComboNum) {
        boolAchievementFlg = true;
        strNo = item['No'];
        strTitle = item['title'];
        strContent =
        '$strTitle \n\n <達成条件>\n 習慣連続実行回数　${item['combo_num']}回以上\n ';
        debugPrint('No:$strNo title:$strTitle content:$strContent');
      }
      if (item['due_num'] != 0 && item['due_num'] <= intDueNum) {
        boolAchievementFlg = true;
        strNo = item['No'];
        strTitle = item['title'];
        strContent =
        '$strTitle \n\n <達成条件>\n 目標時間内に実行した回数　${item['due_num']}回以上\n ';
        debugPrint('No:$strNo title:$strTitle content:$strContent');
      }
      if (item['combodue_num'] != 0 && item['combodue_num'] <= intComboDueNum) {
        boolAchievementFlg = true;
        strNo = item['No'];
        strTitle = item['title'];
        strContent =
        '$strTitle \n\n <達成条件>\n 目標時間内に実行した連続回数　${item['combodue_num']}回以上\n ';
        debugPrint('No:$strNo title:$strTitle content:$strContent');
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
                TextButton(child: Text('閉じる'), onPressed: () => Navigator.pop<String>(context, 'Yes')),
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

    ///明日の通知分をセット
    //そもそも通知制御しないのであれば通知セットしない
    debugPrint('setLocalNotification notificationFlg:$notificationFlg');
    if(notificationFlg == cnsNotificationOff){
      debugPrint('そもそも通知制御しないのであれば通知セットしない(ボタン押下時)');
      return;
    }
    //明日の目標時刻タイマー時間算出
    DateTime goalTimeParse = DateTime.parse(strGoalTime.toString());
    /// 現在時刻のみを取得する
    DateTime nowTime = DateTime(2022,12,10,DateTime.now().hour,DateTime.now().minute,DateTime.now().second);

    ///明日の目標時間のみを取得する
    DateTime goalTime = DateTime(2022,12,11,goalTimeParse.hour,goalTimeParse.minute,goalTimeParse.second);

    ///通知したい時間を算出 (明日の目標時間 - 通知時間)
    int notiTimeSec = notificationTime.hour * 3600 +  notificationTime.minute*60 + notificationTime.second;
    int notifiSecond;
    ///通知したい時間
    DateTime dtNotifTime = goalTime.subtract(Duration(seconds: notiTimeSec)) ;
    ///通知したい時間 - 現在時刻 (秒換算)
    notifiSecond = dtNotifTime.difference(nowTime).inSeconds;

    ///通知セット
    await flutterLocalNotificationsPlugin.zonedSchedule(
        alarmID,
        '勉強時間アラーム',
        '習慣開始まで、あと${notificationTime.hour}時間${notificationTime.minute}分です。',
        tz.TZDateTime.now(tz.local).add(Duration(seconds: notifiSecond)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'full screen channel id', 'full screen channel name',
                channelDescription: 'full screen channel description',
                priority: Priority.high,
                playSound:false,
                importance: Importance.high,
                fullScreenIntent: true)),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);

    if(notifiSecond <= 0){
      debugPrint('$notifiSecond 秒後にローカル通知（ボタン押下時）');
      return;
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
  /*------------------------------------------------------------------
リアルタイムカウントダウン
 -------------------------------------------------------------------*/
  void _onTimer(Timer timer) {

    String  strGoalTime;
 //   debugPrint('strMode:$strMode');
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

    DateTime goalTimeParse = DateTime.parse(strGoalTime.toString());
    /// 現在時刻のみを取得する
    DateTime nowTime = DateTime(2022,12,10,DateTime.now().hour,DateTime.now().minute,DateTime.now().second);

    ///目標時間のみを取得する
    DateTime goalTime = DateTime(2022,12,10,goalTimeParse.hour,goalTimeParse.minute,goalTimeParse.second);

    ///目標時間 - 現在時刻
    int diffSecond;
    diffSecond = goalTime.difference(nowTime).inSeconds;

    // debugPrint('goalTime:$goalTime');
    // debugPrint('nowTime:$nowTime');
    // debugPrint('diffSecond:$diffSecond');

    int intHour;
    int intHourAmariSec;
    int intMinute;
    int intSecond;
    String minusFlg = '';
    if(diffSecond < 0) {
      diffSecond = diffSecond * -1;
      minusFlg = '-';
    }

    intHour = (diffSecond / 3600).floor();
    intHourAmariSec = (diffSecond % 3600).floor();
    intMinute = (intHourAmariSec / 60).floor();
    intSecond = (intHourAmariSec % 60).floor();

    /// 「時:分:秒」表記に文字列を変換するdateFormatを宣言する
   // var dateFormat = DateFormat('HH:mm:ss');
    /// nowをdateFormatでstringに変換する
   // String timeString = dateFormat.format(now);

    setState(() => {
      if(todayHabitsStart == false){
        limitTimeText = '習慣開始まであと',
        limitTime = '$minusFlg$intHour時間　$intMinute分　$intSecond秒'
       }else{
         limitTimeText = '既に習慣開始済み',
        limitTime = '${dtNowDate.hour.toString().padLeft(2,'0')}:${dtNowDate.minute.toString().padLeft(2,'0')}'
       }
    });

  }
  /*------------------------------------------------------------------
本日既に習慣を開始したかどうかを判定する
 -------------------------------------------------------------------*/
  Future<void>  judgeTodayStartTime() async {
    String? strPreRealTime = '';
    DateTime dtPreRealTime;
    //現在日付を取得
    DateTime dtNowDate = DateTime.now();
    //履歴テーブルから直前の日時を取得
    strPreRealTime = await _loadStrRireki('realtime');

    if(strPreRealTime != null){
      dtPreRealTime = DateTime.parse(strPreRealTime);
      // debugPrint(' todayHabitsStart1 $todayHabitsStart');
      // debugPrint(' dtPreRealTime ${dtPreRealTime.year} ${dtPreRealTime.month} ${dtPreRealTime.day})');
      // debugPrint(' dtNowDate ${dtNowDate.year} ${dtNowDate.month} ${dtNowDate.day})');
      if(dtNowDate.year == dtPreRealTime.year
          && dtNowDate.month == dtPreRealTime.month
          && dtNowDate.day == dtPreRealTime.day){
        setState(()=> {
          todayHabitsStart = true
        });
      }
    }else{
      setState(() =>{
        todayHabitsStart = false
      });
    }
 //   debugPrint(' todayHabitsStart2 $todayHabitsStart');
  }
  Future<void> setLocalNotification() async {

    //そもそも通知制御しないのであれば通知セットしない
    debugPrint('setLocalNotification notificationFlg:$notificationFlg');
    if(notificationFlg == cnsNotificationOff){
      debugPrint('そもそも通知制御しないのであれば通知セットしない');
      return;
    }

   //通知セットされているかどうか判定
    final List<ActiveNotification>? activeNotifications = await  flutterLocalNotificationsPlugin.getActiveNotifications();
    //既に通知がセットされているのであればローカル通知セットしない
    if(activeNotifications == null){
      debugPrint('既に通知がセットされているのであればローカル通知セットしない');
      return;
    }


    /// 現在時刻のみを取得する
    DateTime nowTime = DateTime(2022,12,10,DateTime.now().hour,DateTime.now().minute,DateTime.now().second);

    ///目標時間のみを取得する
    DateTime goalTime = DateTime(2022,12,10,goalTimeParse.hour,goalTimeParse.minute,goalTimeParse.second);

    ///通知時間のみを取得する
    DateTime notiTime = DateTime(2022,12,10,notificationTime.hour,notificationTime.minute,notificationTime.second);

    ///通知したい時間を算出 (目標時間 - 通知時間)
    int notiTimeSec = notificationTime.hour * 3600 +  notificationTime.minute*60 + notificationTime.second;
    int notifiSecond;
    ///通知したい時間
    DateTime dtNotifTime = goalTime.subtract(Duration(seconds: notiTimeSec)) ;
    ///通知したい時間 - 現在時刻 (秒換算)
    notifiSecond = dtNotifTime.difference(nowTime).inSeconds;

    if(notifiSecond <= 0){
      debugPrint('既に通知時間を過ぎているならローカル通知セットしない');
      return;
    }

    ///通知セット
    await flutterLocalNotificationsPlugin.zonedSchedule(
        alarmID,
        '勉強時間アラーム',
        '習慣開始まで、あと何時間何分です。',
        tz.TZDateTime.now(tz.local).add(Duration(seconds: notifiSecond)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'full screen channel id', 'full screen channel name',
                channelDescription: 'full screen channel description',
                priority: Priority.high,
                playSound:false,
                importance: Importance.high,
                fullScreenIntent: true)),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);

    if(notifiSecond <= 0){
      debugPrint('$notifiSecond 秒後にローカル通知');
      return;
    }
  }
  /*------------------------------------------------------------------
Goaltimeの算出
 -------------------------------------------------------------------*/
  Future<void> calGoaltime() async {
    //タイマー時間算出

    if (strMode == cnsModeEveryDay) {
      strGoalTime = everyTime.toString();
    } else {
      //土日の場合
      if (DateTime
          .now()
          .weekday == 6 || DateTime
          .now()
          .weekday == 7) {
        strGoalTime = holidayTime.toString();
      }
      //平日の場合
      else {
        strGoalTime = normalTime.toString();
      }
    }
     goalTimeParse = DateTime.parse(strGoalTime.toString());
  }
  /*------------------------------------------------------------------
初期処理
 -------------------------------------------------------------------*/
  void init() async {
  await  loadPref();
  await  loadSetting();
  await  calGoaltime();
  await  judgeTodayStartTime();
  await  setLocalNotification();
  }

}
