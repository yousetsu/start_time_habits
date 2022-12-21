import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:intl/intl.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {

  String _currentMonth = DateFormat.yMMM().format(DateTime(2019, 2, 3));
  DateTime _targetDateTime = DateTime(2019, 2, 3);

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<DateTime> _days=[DateTime(2020, 12, 20), DateTime(2020, 12, 21)]; //アイコンを表示する日

    return Scaffold(
      appBar: AppBar(title: const Text('習慣状況')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Container(
              //   margin: EdgeInsets.only(top: 30.0, bottom: 16.0, left: 16.0, right: 16.0,),
              //   child: new Row(
              //     children: <Widget>[
              //       Expanded(
              //           child: Text(_currentMonth, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0,),)),
              //       TextButton(
              //         child: Text('PREV'),
              //         onPressed: () {
              //           setState(() {
              //             _targetDateTime = DateTime(
              //                 _targetDateTime.year, _targetDateTime.month - 1);
              //             _currentMonth =
              //                 DateFormat.yMMM().format(_targetDateTime);
              //           });
              //         },
              //       ),
              //       TextButton(
              //         child: Text('NEXT'),
              //         onPressed: () {
              //           setState(() {
              //             _targetDateTime = DateTime(
              //                 _targetDateTime.year, _targetDateTime.month + 1);
              //             _currentMonth =
              //                 DateFormat.yMMM().format(_targetDateTime);
              //           });
              //         },
              //       )
              //     ],
              //   ),
              // ),
              Container(
                margin: const EdgeInsets.only(top:20, left:20),
                child: CalendarCarousel<Event>(
                  //アイコンを表示する日付について、EventのList
                  markedDatesMap: _getMarkedDateMap(_days, context),
                  markedDateShowIcon: true,
                  markedDateIconMaxShown: 1,
                  markedDateMoreShowTotal: null,
                  markedDateIconBuilder: (event)=>event.icon,  //アイコン
                ),
              ), //
            ],
          ),
        ),
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
  EventList<Event> _getMarkedDateMap(List<DateTime> days, BuildContext context){
    EventList<Event> _markedDateMap=new EventList<Event>(events: {});
    for (DateTime _date in days){
      _markedDateMap.add(_date,
          new Event(
            date: _date,
            icon: _getIcon(_date), //アイコンを作成
          ));
    }
    return _markedDateMap;
  }
  Widget _getIcon(DateTime date){

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
         SizedBox(height: 2,),
    Icon(Icons.brightness_1, color: Colors.blue, size: 16,), //日付と一緒に表示するアイコン
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
}