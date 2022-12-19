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

  DateTime _currentDate = DateTime(2019, 2, 3);
  DateTime _currentDate2 = DateTime(2019, 2, 3);
  String _currentMonth = DateFormat.yMMM().format(DateTime(2019, 2, 3));
  DateTime _targetDateTime = DateTime(2019, 2, 3);
  static Widget _eventIcon = new Container(
    decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000)),
        border: Border.all(color: Colors.blue, width: 2.0)),
    child: new Icon(Icons.person, color: Colors.amber,),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(title: const Text('習慣状況')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 30.0, bottom: 16.0, left: 16.0, right: 16.0,),
                child: new Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(_currentMonth, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0,),)),
                    TextButton(
                      child: Text('PREV'),
                      onPressed: () {
                        setState(() {
                          _targetDateTime = DateTime(
                              _targetDateTime.year, _targetDateTime.month - 1);
                          _currentMonth =
                              DateFormat.yMMM().format(_targetDateTime);
                        });
                      },
                    ),
                    TextButton(
                      child: Text('NEXT'),
                      onPressed: () {
                        setState(() {
                          _targetDateTime = DateTime(
                              _targetDateTime.year, _targetDateTime.month + 1);
                          _currentMonth =
                              DateFormat.yMMM().format(_targetDateTime);
                        });
                      },
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: _calendarCarouselNoHeader,
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
  final _calendarCarouselNoHeader = CalendarCarousel<Event>(
    todayBorderColor: Colors.green,
    // onDayPressed: (date, events) {
    //   this.setState(() => _currentDate2 = date);
    //   events.forEach((event) => print(event.title));
    // },
    daysHaveCircularBorder: true,
    showOnlyCurrentMonthDate: false,
    weekendTextStyle: TextStyle(color: Colors.red,),
    thisMonthDayBorderColor: Colors.grey,
    weekFormat: false,
      firstDayOfWeek: 4,
   markedDatesMap: _markedDateMap,
    height: 420.0,
   // selectedDateTime: _currentDate2,
 //   targetDateTime: _targetDateTime,
    customGridViewPhysics: NeverScrollableScrollPhysics(),
    // markedDateCustomShapeBorder:
    // CircleBorder(side: BorderSide(color: Colors.yellow)),
    // markedDateCustomTextStyle: TextStyle(
    //   fontSize: 18,
    //   color: Colors.blue,
    // ),
    showHeader: false,
    todayTextStyle: TextStyle(color: Colors.blue,),
    todayButtonColor: Colors.yellow,
    selectedDayTextStyle: TextStyle(color: Colors.yellow,),
  //  minSelectedDate: _currentDate.subtract(Duration(days: 360)),
  //  maxSelectedDate: _currentDate.add(Duration(days: 360)),
    prevDaysTextStyle: TextStyle(fontSize: 16, color: Colors.pinkAccent,),
    inactiveDaysTextStyle: TextStyle(
      color: Colors.tealAccent,
      fontSize: 16,
    ),
    // onCalendarChanged: (DateTime date) {
    //   this.setState(() {
    //     _targetDateTime = date;
    //     _currentMonth = DateFormat.yMMM().format(_targetDateTime);
    //   });
    // },
    onDayLongPressed: (DateTime date) {
      print('long pressed date $date');
    },
  );
}