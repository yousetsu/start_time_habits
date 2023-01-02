import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './const.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';
//ローカル通知の時間をセットするためタイムゾーンの定義が必要
import 'package:timezone/timezone.dart' as tz;


class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}
const String strCnsEveryDay = "EveryDay";
const String strCnsNormalDay = "NormarlDay";


class _SettingScreenState extends State<SettingScreen> {
  String? _type = strCnsNormalDay;
  bool isOnNotification = false;
  bool isEnable = false;
  DateTime everyTime = DateTime.utc(0, 0, 0);
  DateTime normalTime = DateTime.utc(0, 0, 0);
  DateTime holidayTime = DateTime.utc(0, 0, 0);
  String? notification = '';
  DateTime notificationTime = DateTime.utc(0, 0, 0);
  String? strMode = '';
  String? strFirstSet = '';
  @override
  void initState() {
    super.initState();
    loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
          //  crossAxisAlignment: CrossAxisAlignment.start,
              children:  <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.settings,size: 30,color: Colors.blue,),
                const Text('設定',style:TextStyle(fontSize: 30.0,color: Colors.blue)),
            ]),
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                   // const Padding(padding: EdgeInsets.only(left:50.0),),
                    Radio(activeColor: Colors.blue, value: strCnsEveryDay, groupValue: _type, onChanged: _handleRadio, autofocus:true,),
                    const Text('毎日', style:TextStyle(fontSize: 20.0),),
                  ],),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),),
                  onPressed: !(_type == strCnsEveryDay)? null : () async {
                    Picker(
                      adapter: DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: everyTime, customColumnType: [3, 4]),
                      title: const Text("Select Time"),
                      onConfirm: (Picker picker, List value) {
                        setState(() => {
                          everyTime = DateTime.utc(2016, 5, 1, value[0], value[1], 0),
                        _saveStrSetting('everystarttime',everyTime.toString()),
                          loadSetting()
                        });
                      },
                    ).showModal(context);
                  },
                  child: Text(style: const TextStyle(fontSize: 40),DateFormat.Hm().format(everyTime) ),
                ),

                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // const Padding(padding: EdgeInsets.only(left:50.0),),
                    Radio(activeColor: Colors.blue, value: strCnsNormalDay, groupValue: _type, onChanged: _handleRadio, autofocus:true,),
                    const Text('平日／土日ごと', style:TextStyle(fontSize: 20.0),),

                  ],),
                const Text('　平日', style:TextStyle(fontSize: 20.0),),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),),
                  onPressed:  !(_type == strCnsNormalDay)? null : () async {
                    Picker(
                      adapter: DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: normalTime, customColumnType: [3, 4]),
                      title: const Text("Select Time"),
                      onConfirm: (Picker picker, List value) {
                        setState(() => {
                          normalTime = DateTime.utc(2016, 5, 1, value[0], value[1], 0),
                          _saveStrSetting('normalstarttime',normalTime.toString()),
                          loadSetting()
                        });
                      },
                    ).showModal(context);
                  },
                  child: Text(style: const TextStyle(fontSize: 40),DateFormat.Hm().format(normalTime) ),
                ),
                const Text('　土日', style:TextStyle(fontSize: 20.0),),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),),
                  onPressed:!(_type == strCnsNormalDay)? null : () async {
                    Picker(
                      adapter: DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: holidayTime, customColumnType: [3, 4]),
                      title: const Text("Select Time"),
                      onConfirm: (Picker picker, List value) {
                        setState(() => {
                          holidayTime = DateTime.utc(2016, 5, 1, value[0], value[1], 0),
                          _saveStrSetting('holidaystarttime',holidayTime.toString()),
                          loadSetting()
                        });
                      },
                    ).showModal(context);
                  },
                  child: Text(style: const TextStyle(fontSize: 40),DateFormat.Hm().format(holidayTime) ),
                ),

                const Text('通知設定', style:TextStyle(fontSize: 20.0),),
                Switch(value: isOnNotification, onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        isOnNotification = value;
                        _saveStrSetting('notification',  isOnNotification? cnsNotificationOn:cnsNotificationOff);
                        setLocalNotification();
                        loadSetting();
                      });
                    }
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),),
                  onPressed: !isOnNotification? null : ()async {
                    Picker(
                      adapter: DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: notificationTime, customColumnType: [3, 4]),
                      title: const Text("Select Time"),
                      onConfirm: (Picker picker, List value) {
                        setState(() => {
                          notificationTime = DateTime.utc(2016, 5, 1, value[0], value[1], 0),
                          _saveStrSetting('notificationtime',notificationTime.toString()),

                          loadSetting()
                        });
                      },
                    ).showModal(context);
                  },
                  child: Text(style: const TextStyle(fontSize: 40),DateFormat.Hm().format(notificationTime) ),
                ),
              ],
          ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
          }else if (index == 3) {
            Navigator.pushNamed(context, '/achievement');
          }
        },
      ),
    );
  }
  /*------------------------------------------------------------------
設定画面プライベートメソッド
 -------------------------------------------------------------------*/
//ラジオボタン選択時の処理
  void _handleRadio(String? e){
    setState(() {
      _type = e;
      if(e == strCnsEveryDay){
        isEnable = false; //毎日・・・0
        _saveStrSetting('mode', cnsModeEveryDay);
      }else{
        isEnable = true; //平日・・・1
        _saveStrSetting('mode', cnsModeNormalDay);
      }
    });

    loadSetting();

  }
//-------------------------------------------------------------
//   DB処理
//-------------------------------------------------------------
/*------------------------------------------------------------------
設定画面ロード
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
        notification = item['notification'].toString();
        notificationTime = DateTime.parse(item['notificationtime'].toString());
        strFirstSet = item['firstset'].toString();
        _type = (strMode == '0')? strCnsEveryDay : strCnsNormalDay;
        isOnNotification = (notification == '0')?  false:true;
      });
    }
    await  database.close();
  }
//-------------------------------------------------------------
//   設定テーブルにデータ保存
//-------------------------------------------------------------
//設定テーブルにデータ保存
  void _saveStrSetting(String field ,String value) async {
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1);
    String query = "UPDATE setting set $field = '$value' ";
    await database.transaction((txn) async {
      //int id = await txn.rawInsert(query);
      await txn.rawInsert(query);
      //   print("insert: $id");
    });
    database.close();
  }
  //-------------------------------------------------------------
//   ローカル通知セット
//-------------------------------------------------------------
  Future<void> setLocalNotification() async {

    if(isOnNotification == false){
      debugPrint('そもそも通知制御しないのであれば通知セットしない(設定画面)');
      return;
    }

    //通知セットされているかどうか判定
    final List<ActiveNotification>? activeNotifications = await  flutterLocalNotificationsPlugin.getActiveNotifications();
    //既に通知がセットされているのであればローカル通知セットしない
    if(activeNotifications == null){
      debugPrint('既に通知がセットされているのであればローカル通知セットしない(設定画面)');
      return;
    }
    //タイマー時間算出
    String  strGoalTime;
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


    ///通知したい時間を算出 (目標時間 - 通知時間)
    int notiTimeSec = notificationTime.hour * 3600 +  notificationTime.minute*60 + notificationTime.second;
    int notifiSecond;
    ///通知したい時間
    DateTime dtNotifTime = goalTime.subtract(Duration(seconds: notiTimeSec)) ;
    ///通知したい時間 - 現在時刻 (秒換算)
    notifiSecond = dtNotifTime.difference(nowTime).inSeconds;

    if(notifiSecond <= 0){
      debugPrint('既に通知時間を過ぎているならローカル通知セットしない(設定画面)');
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
}

