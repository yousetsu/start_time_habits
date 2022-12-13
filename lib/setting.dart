import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
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
                const Text('設定',style:TextStyle(fontSize: 20.0)),

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
                        _saveStrSetting('notification',  isOnNotification? '1':'0');
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
        _saveStrSetting('mode', '0');
      }else{
        isEnable = true; //平日・・・1
        _saveStrSetting('mode', '1');
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
    database.close();
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

}

