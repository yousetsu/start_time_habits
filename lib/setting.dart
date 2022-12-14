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
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}
const String strCnsEveryDay = "EveryDay";
const String strCnsNormalDay = "NormarlDay";
RewardedAd? _rewardedAd;
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
    _createRewardedAd();
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
                const Text('目標開始時間の設定',style:TextStyle(fontSize: 30.0,color: Colors.blue)),
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
                          setLocalNotification(),
                          loadSetting(),
                          _showRewardedAd()
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
                          setLocalNotification(),
                          loadSetting(),
                          _showRewardedAd()
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
                         setLocalNotification(),
                          loadSetting(),
                          _showRewardedAd()
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
 //   await  database.close();
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
      await txn.rawInsert(query);
    });
 //   database.close();
  }
  //-------------------------------------------------------------
//   ローカル通知セット
//-------------------------------------------------------------
  Future<void> setLocalNotification() async {

    //通知制御オンオフ判定
    if(isOnNotification == false){
      return;
    }
    ///通知セットされているかどうか判定
    //→不要。同じアラームIDなら上書きされるため

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
      return;
    }

    ///通知セット
    await flutterLocalNotificationsPlugin.zonedSchedule(
        alarmID,
        cnsAppTitle,
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

  }
  /*------------------------------------------------------------------
動画準備
 -------------------------------------------------------------------*/
  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: strCnsRewardID,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            //  print('$ad loaded.');
            _rewardedAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            //  print('RewardedAd failed to load: $error');
            _rewardedAd = null;
          },
        ));

  }
  /*------------------------------------------------------------------
動画実行
 -------------------------------------------------------------------*/
  void _showRewardedAd() async {
    int rewardcnt = 0;
    rewardcnt = await _loadRewardCnt();
    if(rewardcnt >= 2 ) {
      _rewardedAd!.setImmersiveMode(true);
      _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            print('$ad with reward $RewardItem(${reward.amount}, ${reward
                .type})');
          });
      _rewardedAd = null;
      rewardcnt = 0;
    }else{
      rewardcnt++;
      _updRewardCnt(rewardcnt);
    }

  }
  //-------------------------------------------------------------
//   リワード回数を取得
//-------------------------------------------------------------
  Future<int> _loadRewardCnt() async {
    int rewardcnt = 0;
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1);
    List<Map> result = await database.rawQuery("SELECT rewardcnt From setting  limit 1");
    for (Map item in result) {
      setState(() {rewardcnt = item['rewardcnt'];});
    }
    return rewardcnt;
  }
  //-------------------------------------------------------------
//   リワード回数を更新
//-------------------------------------------------------------
  Future<void> _updRewardCnt(int rewardCnt) async {
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1);
    String query = "UPDATE setting set rewardcnt = '$rewardCnt' ";
    await database.transaction((txn) async {
      await txn.rawInsert(query);
    });
  }
}

