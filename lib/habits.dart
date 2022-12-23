import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './const.dart';

List<Map> mapRireki = <Map>[];

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState()  {
    super.initState();
    _loadRireki();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('習慣状況')),
        body:
              Container(
                margin: const EdgeInsets.only(top:20, left:20),
                child: CalendarCarousel<Event>(
                  //アイコンを表示する日付について、EventのList
                  markedDatesMap: _getMarkedDateMap(context),
                  markedDateShowIcon: true,
                  markedDateIconMaxShown: 1,
                  markedDateMoreShowTotal: null,
                  markedDateIconBuilder: (event)=>event.icon,  //アイコン
                ),
              ), //
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label:'ホーム', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label:'習慣状況', icon: Icon(Icons.calendar_month)),
          BottomNavigationBarItem(label:'設定', icon: Icon(Icons.settings)),
          BottomNavigationBarItem(label:'称号', icon: Icon(Icons.emoji_events)),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/setting');
          }else if (index == 3) {
            Navigator.pushNamed(context, '/achievement');
          }
        },
      ),
    );
  }
  EventList<Event> _getMarkedDateMap(BuildContext context){
    EventList<Event> _markedDateMap=new EventList<Event>(events: {});
    DateTime dateTime= DateTime(0, 0, 0);
    String strStatus ;
    for (Map item in mapRireki){
      dateTime = DateTime( DateTime.parse(item['realtime'].toString()).year,DateTime.parse(item['realtime'].toString()).month,DateTime.parse(item['realtime'].toString()).day);
      strStatus = item['status'].toString();
      _markedDateMap.add(dateTime,new Event(date: dateTime, icon: _getIcon(dateTime,strStatus))); //アイコンを作成
    }
    // dateTime = DateTime(2022, 12, 10);
    // _markedDateMap.add(dateTime,new Event(date: dateTime, icon: _getIcon(dateTime,'0')));
    // dateTime = DateTime(2022, 12, 11);
    // _markedDateMap.add(dateTime,new Event(date: dateTime, icon: _getIcon(dateTime,'1')));
    // dateTime = DateTime(2022, 12, 23);
    // _markedDateMap.add(dateTime,new Event(date: dateTime, icon: _getIcon(dateTime,'1')));
    return _markedDateMap;
  }
  Widget _getIcon(DateTime date , String status){

    bool _isToday=isSameDay(date, DateTime.now());//今日？
    CalendarCarousel _calendar_default=CalendarCarousel();
    Color _today_col=_calendar_default.todayButtonColor;  //今日の背景色

    return Container(
        decoration: new BoxDecoration(
          color: _isToday ? _today_col :Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(1000),
        ), //今日の場合は赤の円の背景　それ以外は無し
    child: Column(
        children: [
          Text(date.day.toString(),
            style: TextStyle(
                color: _isToday? Colors.white: getDayCol(date), fontWeight: FontWeight.w400
            ),//日付の文字　今日は白、それ以外は平日黒、休日赤
         ),
         //期限内に開始できたらダイアモンド、そのひ開始できたらサムズアップ
         SizedBox(height: 2,), Icon(status == cnsStatusHabitsDue ? Icons.diamond:Icons.thumb_up  , color: Colors.white, size: 16,), //日付と一緒に表示するアイコン
     ]
    ));
  }
  static bool isSameDay(DateTime day1, DateTime day2) {
    return ((day1.difference(day2).inDays) == 0 && (day1.day == day2.day));
  }
  Color getDayCol(DateTime _date){
    switch(_date.weekday){
      case DateTime.saturday:
      case DateTime.sunday:
        return Colors.red;
      default:
        return Colors.black;
    }
  }
  /*------------------------------------------------------------------
履歴データロード
 -------------------------------------------------------------------*/
  Future<String?> _loadRireki() async{

    String dbPath = await getDatabasesPath();
    String path =  p.join(dbPath, 'rireki.db');
    Database database = await openDatabase(path, version: 1);
    mapRireki = await database.rawQuery("SELECT * From rireki order by realtime desc");
    await database.close();

  }
}