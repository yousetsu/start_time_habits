import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';
class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}
const String strCnsEveryDay = "EveryDay";
const String strCnsNormalDay = "NormarlDay";


class _SettingScreenState extends State<SettingScreen> {
  String? _type = '';
  bool isOn = false;
  bool isEnable = false;
  DateTime everyTime = DateTime.utc(0, 0, 0);
  DateTime normalTime = DateTime.utc(0, 0, 0);
  DateTime holidayTime = DateTime.utc(0, 0, 0);
  DateTime notificationTime = DateTime.utc(0, 0, 0);
  @override
  void initState() {
    super.initState();
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
                  onPressed: () async {
                    Picker(
                      adapter: DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: everyTime, customColumnType: [3, 4]),
                      title: const Text("Select Time"),
                      onConfirm: (Picker picker, List value) {
                        setState(() => {
                          everyTime = DateTime.utc(2016, 5, 1, value[0], value[1], 0),
                        //  _saveStrSetting('goalsleeptime',_goalsleeptime.toString()),
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
                  onPressed: () async {
                    Picker(
                      adapter: DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: normalTime, customColumnType: [3, 4]),
                      title: const Text("Select Time"),
                      onConfirm: (Picker picker, List value) {
                        setState(() => {
                          normalTime = DateTime.utc(2016, 5, 1, value[0], value[1], 0),
                          //  _saveStrSetting('goalsleeptime',_goalsleeptime.toString()),
                        });
                      },
                    ).showModal(context);
                  },
                  child: Text(style: const TextStyle(fontSize: 40),DateFormat.Hm().format(normalTime) ),
                ),
                const Text('　土日', style:TextStyle(fontSize: 20.0),),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),),
                  onPressed: () async {
                    Picker(
                      adapter: DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: holidayTime, customColumnType: [3, 4]),
                      title: const Text("Select Time"),
                      onConfirm: (Picker picker, List value) {
                        setState(() => {
                          holidayTime = DateTime.utc(2016, 5, 1, value[0], value[1], 0),
                          //  _saveStrSetting('goalsleeptime',_goalsleeptime.toString()),
                        });
                      },
                    ).showModal(context);
                  },
                  child: Text(style: const TextStyle(fontSize: 40),DateFormat.Hm().format(holidayTime) ),
                ),

                const Text('通知設定', style:TextStyle(fontSize: 20.0),),
                Switch(value: isOn, onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {isOn = value;});
                    }
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),),
                  onPressed: () async {
                    Picker(
                      adapter: DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: notificationTime, customColumnType: [3, 4]),
                      title: const Text("Select Time"),
                      onConfirm: (Picker picker, List value) {
                        setState(() => {
                          notificationTime = DateTime.utc(2016, 5, 1, value[0], value[1], 0),
                          //  _saveStrSetting('goalsleeptime',_goalsleeptime.toString()),
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
        isEnable = false;
      }else{
        isEnable = true;
      }
    });
  }
}
