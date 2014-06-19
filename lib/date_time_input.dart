library date_time_input;

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_browser.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbols.dart';
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:async';


@CustomTag('date-time-input')
class DateTimeInput extends PolymerElement  {
  static bool initializing = false;
  int firstDayOfWeek=6;
  DateTime today = new DateTime.now();


  @published String dateTimeString;
  @published String dateTimeId;

  Timer timer;
  @observable List<String> monthTexts;
  @observable List<String> weekdayTexts;
  //@observable List<int> weekList;
  @observable bool initialized = false;
  @observable bool started = false;
  @observable bool showDiv=false;
  @observable bool closing=false;
  @observable String datetime;
  @observable String inputplaceholder="";
  @observable int inputmaxlength=9999;
  String _internalDateTime;
  // displayed as the default string
  @observable int day;
//  @published String get dateTimeString =>_internalDateTime ;
  @observable DateTime currentdate = new DateTime.now();
  //@observable String datetime;
  //@observable String monthText;
  @observable List<List<int>> calendarList = [];

//  @observable List aCalendarList = toObservable(freshCalendarList());
//  void set dateTimeString(String n) { _internalDateTime = n; }

  DateTimeInput.created(): super.created() {
    if(!initializing){
      initializing = true;
      findSystemLocale().then((_){
        initializeDateFormatting(Intl.systemLocale, null).then((_){
          _initializeTexts(new DateFormat.E().dateSymbols);
          newCalendarList;
          initialized = true;
        });
      });
    }
  }

  void attached() {
    super.attached();
    if(dateTimeString == null || dateTimeString.isEmpty || dateTimeString.length == 0){
      currentdate = new DateTime.now();
      dateTimeString=currentdate.toString().substring(0,16);
    }
  }


  List freshCalendarList(){
    //print("getting fresh calendarlist");
    DateTime first = new DateTime(currentdate.year,currentdate.month,1);
    DateTime last = new DateTime(currentdate.year,currentdate.month+1,1).subtract(new Duration(days:1));
    List<List<int>> calendarList = [];
    List<int> weekList = [null,null,null,null,null,null,null];
    //print("firstDayOfWeek is $firstDayOfWeek");
    int pos = (first.weekday)-firstDayOfWeek;
    if(pos>=7)
      pos-=7;
    if(pos<0)
      pos+=7;
    for(int i=1;i<=last.day;i++){
      weekList[pos]=i;
      pos++;
      if(pos>=7){
        calendarList.add(weekList);
        weekList = [null,null,null,null,null,null,null];
        pos=0;
      }
    }
    if(pos>0)
      calendarList.add(weekList);
    //print("calendarlist =  $calendarList");
    return calendarList;
  }

  List get newCalendarList{
    //print("getting calendarlist");
    DateTime first = new DateTime(currentdate.year,currentdate.month,1);
    DateTime last = new DateTime(currentdate.year,currentdate.month+1,1).subtract(new Duration(days:1));
    //List<List<int>> calendarList = [];
    calendarList = [];
    List<int> weekList = [null,null,null,null,null,null,null];
    //print("firstDayOfWeek is $firstDayOfWeek");
    int pos = (first.weekday)-firstDayOfWeek;
    if(pos>=7)
      pos-=7;
    if(pos<0)
      pos+=7;
    for(int i=1;i<=last.day;i++){
      weekList[pos]=i;
      pos++;
      if(pos>=7){
        calendarList.add(weekList);
        weekList = [null,null,null,null,null,null,null];
        pos=0;
      }
    }
    if(pos>0)
      calendarList.add(weekList);
    //print("calendarlist =  $calendarList");
    return calendarList;
  }


  bool isToday(int day){
    if(currentdate.year==currentdate.year&&currentdate.month==currentdate.month&&day==currentdate.day){
//      print("day is $day and TRUE");
      return true;
    } else {
//      print("day is $day and FALSE");
      return false;
    }
  }


  void onValueChange(Event e, var detail, Node target){
    try{
      currentdate = DateTime.parse(dateTimeString);
      newCalendarList;
    }catch(e){
      currentdate = new DateTime.now();
    }
  }

  void show(Event e, var detail, Node target){
    //print("show is pressed");
    onValueChange(e, detail, target);
    showDiv=true;
    closing=false;
  }

  void close(Event e, var detail, Node target){
    //print("close is pressed");
    closing=true;
    if(timer!=null)
      timer.cancel();
    timer = new Timer(new Duration(seconds:1), (){
      if(closing){
        showDiv=false;
      }
    });
  }

  void chooseDay(Event e, var detail, Node target){
    String nodeval = target.text;
    print("event $e, detail $detail, node: $nodeval");
    int day = int.parse(target.text);
    //target.nodeValue
    print("run ChooseDay, day is $day");
    closing=false;
    if(day != null){
      currentdate=new DateTime(currentdate.year, currentdate.month, day, currentdate.hour, currentdate.minute);
      dateTimeString=currentdate.toString().substring(0,16);
    }
    $[dateTimeId].focus();

  }
/*
  void chooseDay(Event e, int day, Node target){
    print("run ChooseDay");
    closing=false;
    date=new DateTime(date.year, date.month, day, date.hour, date.minute);
    dateTimeString=date.toString().substring(0,16);
    $[dateTimeId].focus();

  }
*/
  void previousDay(Event e, var detail, Node target ){
    closing=false;
    currentdate = new DateTime(currentdate.year, currentdate.month,currentdate.day-1,currentdate.hour,currentdate.minute, 1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }

  void nextDay(Event e, var detail, Node target ){
    closing=false;
    currentdate = new DateTime(currentdate.year, currentdate.month,currentdate.day+1,currentdate.hour,currentdate.minute, 1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }

  void previousMonth(Event e, var detail, Node target ){
    closing=false;
    currentdate = new DateTime(currentdate.year, currentdate.month-1,currentdate.day,currentdate.hour,currentdate.minute, 1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }

  void nextMonth(Event e, var detail, Node target ){
    closing=false;
    currentdate = new DateTime(currentdate.year, currentdate.month+1,currentdate.day,currentdate.hour,currentdate.minute, 1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }

  void previousYear(Event e, var detail, Node target ){
    closing=false;
    currentdate = new DateTime(currentdate.year-1, currentdate.month,currentdate.day,currentdate.hour,currentdate.minute,1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }

  void nextYear(Event e, var detail, Node target){
    closing=false;
    currentdate = new DateTime(currentdate.year+1, currentdate.month,currentdate.day,currentdate.hour,currentdate.minute,1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }

  void previousHour(Event e, var detail, Node target){
    closing=false;
    currentdate = new DateTime(currentdate.year, currentdate.month, currentdate.day, currentdate.hour-1,currentdate.minute,1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }

  void nextHour(Event e, var detail, Node target){
    closing=false;
    currentdate = new DateTime(currentdate.year, currentdate.month, currentdate.day, currentdate.hour+1,currentdate.minute,1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }

  void previousMinute(Event e, var detail, Node target){
    closing=false;
    currentdate = new DateTime(currentdate.year, currentdate.month, currentdate.day, currentdate.hour,currentdate.minute-1,1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }
  void nextMinute(Event e, var detail, Node target){
    closing=false;
    currentdate = new DateTime(currentdate.year, currentdate.month, currentdate.day, currentdate.hour,currentdate.minute+1,1);
    dateTimeString=currentdate.toString().substring(0,16);
    $[dateTimeId].focus();
  }

  @published String get monthText{
    return monthTexts[currentdate.month-1];
  }

  void _initializeTexts(DateSymbols ds){
//    print("into initializeTexts");
//    print(ds.FIRSTDAYOFWEEK);
    firstDayOfWeek = ds.FIRSTDAYOFWEEK;
//    print("firstDayOfweek is $firstDayOfWeek");
    weekdayTexts = [];
    for(int i=0; i<7; i++){
      int k = firstDayOfWeek+i;
      if(k>=7)
        k = k - 7;
      weekdayTexts.add(ds.STANDALONESHORTWEEKDAYS[k]);
    }
    monthTexts = ds.STANDALONESHORTMONTHS;
//    print("weekdayText and monthText is $weekdayTexts and $monthTexts");
  }


}
