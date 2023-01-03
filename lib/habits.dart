import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './const.dart';

List<Map> mapRireki = <Map>[];
EventList<Event> markedDateMap = new EventList<Event>(events: {});
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}
class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState()  {
    super.initState();
    markedDateMap.clear();
    makeMarkedDateMap();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('習慣状況カレンダー')),
        body:SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[
              Container(
                child: CalendarCarousel<Event>(
                  //アイコンを表示する日付について、EventのList
                  markedDatesMap: markedDateMap,
                  markedDateShowIcon: true,
                  height: 420.0,
                  markedDateIconMaxShown: 1,
                  markedDateMoreShowTotal: null,
                  markedDateIconBuilder: (event)=>event.icon,  //アイコン
                ),
              ),
              ]
          ),

        ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label:'ホーム', icon: Icon(Icons.home),backgroundColor: Colors.blue),
          BottomNavigationBarItem(label:'習慣状況', icon: Icon(Icons.calendar_month),backgroundColor: Colors.blue),
          BottomNavigationBarItem(label:'設定', icon: Icon(Icons.settings),backgroundColor: Colors.blue),
          BottomNavigationBarItem(label:'称号', icon: Icon(Icons.emoji_events),backgroundColor: Colors.blue),
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
  Widget _getIcon(DateTime date , String strStatus,DateTime realDate){

    bool _isToday=isSameDay(date, DateTime.now());//今日？
    CalendarCarousel _calendar_default=CalendarCarousel();
    Color _today_col=_calendar_default.todayButtonColor;  //今日の背景色
    debugPrint('strStatus:$strStatus');
    return Container(
        decoration: new BoxDecoration(
          color: _isToday ? _today_col :Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(1000),
        ), //今日の場合は赤の円の背景　それ以外は無し
    child: Column(
        children: [
          Text(date.day.toString(), style: TextStyle(color: _isToday? Colors.white: getDayCol(date), fontWeight: FontWeight.w400),//日付の文字　今日は白、それ以外は平日黒、休日赤
         ),
         Text('${realDate.hour.toString().padLeft(2, '0')}:${realDate.minute.toString().padLeft(2, '0')}', style: TextStyle(color: isStatus(strStatus)?Colors.blue:Colors.black  ,fontSize: 12) ),
        ]
    ));
  }
  static bool isSameDay(DateTime day1, DateTime day2) {
    return ((day1.difference(day2).inDays) == 0 && (day1.day == day2.day));
  }
  static bool isStatus(String status) {
    return (status == cnsStatusHabitsDue);
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
    String path =   p.join(dbPath, 'rireki.db');
    Database database = await openDatabase(path, version: 1);
    mapRireki = await database.rawQuery("SELECT * From rireki order by realtime desc");
 //   await database.close();
  }
  /*------------------------------------------------------------------
MarkedDateMap作成
 -------------------------------------------------------------------*/
  void makeMarkedDateMap() async{

    DateTime dateTime= DateTime(0, 0, 0);
    DateTime realTime= DateTime(0, 0, 0);
    String strStatus ;
    await _loadRireki();

    for (Map item in mapRireki){
      dateTime = DateTime( DateTime.parse(item['realtime'].toString
        ()).year,DateTime.parse(item['realtime'].toString()).month,DateTime.parse(item['realtime'].toString()).day);
      strStatus = item['status'].toString();
      realTime  = DateTime.parse(item['realtime'].toString());
      setState(() {
        markedDateMap.add(dateTime, new Event(
            date: dateTime, icon: _getIcon(dateTime, strStatus,realTime))); //アイコンを作成
      });
    }
  }

}