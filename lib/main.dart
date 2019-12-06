import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wallett/dbmodel.dart';
import 'package:wallett/db.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'db.dart';
import 'dbmodel.dart';
import 'package:sembast/sembast.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
};

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallett',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      theme: ThemeData.dark().copyWith(
          primaryColor : Colors.amber,
          accentColor: Colors.grey[900],
          primaryTextTheme: TextTheme(
            title: TextStyle(
              color: Colors.black
            )
          )
        ),
      home: MyHomePage(title: 'Wallett'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
  // _MyHomePageState createState(){
  //   return _MyHomePageState();
  // }
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
  Map<DateTime, List> _events = {};
  List _selectedEvents;
  final _formKey = GlobalKey<FormState>();
  AnimationController _animationController;
  CalendarController _calendarController;
  void addMoney(Money object) async {
    int result = await dbHelper.insert(object);
  }
  DateTime selectedDate;
  DbHelper dbHelper = DbHelper();
  List<Money> usageList;
  List<String> dropItems = ['outcome', 'income'];
  String dropDownValue;
  final amountController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();
  int _radioValue1 = -1;
    @override
  void initState() {
    final _selectedDay = DateTime.now();

    _selectedEvents = _events[_selectedDay] ?? [];

    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    dropDownValue = dropItems.first;

    updateList();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void updateList() async {
    Future<List<Money>> usageListFuture = dbHelper.getMoneyList();
    var now = new DateTime.now();
    final today = new DateFormat("yyyy-MM-dd").format(now);
    // currentTime = DateTime.parse(today.year+'-'+today.month+'-'+today.day+' 00:00:00.000');
    await usageListFuture.then((usageList) {
      Map<DateTime, List> new_events = {};
      setState(() {
        for (int i=0; i<usageList.length; i++) {
          // _events[DateTime.parse(usageList[i].date+' 00:00:00.000')] = _events[DateTime.parse(usageList[i].date+' 00:00:00.000')][0] != null ? _events[DateTime.parse(usageList[i].date+' 00:00:00.000')].add([usageList[i].desc, usageList[i].amount, usageList[i].income]) : [[usageList[i].desc, usageList[i].amount, usageList[i].income]];
          if(_events[DateTime.parse(usageList[i].date+' 00:00:00.000')] != null){
            _events[DateTime.parse(usageList[i].date+' 00:00:00.000')].add([usageList[i].desc, usageList[i].amount, usageList[i].income, usageList[i].id, usageList[i].date]);
          }else{
            _events[DateTime.parse(usageList[i].date+' 00:00:00.000')] = [[usageList[i].desc, usageList[i].amount, usageList[i].income, usageList[i].id, usageList[i].date]];
          }
        }
        _selectedEvents = _events[DateTime.parse(today+' 00:00:00.000')] ?? [];
      });
    });
  }

  void updateLists() async {
    Future<List<Money>> usageListFuture = dbHelper.getMoneyList();
    var now = new DateTime.now();
    final today = new DateFormat("yyyy-MM-dd").format(now);
    // currentTime = DateTime.parse(today.year+'-'+today.month+'-'+today.day+' 00:00:00.000');
    await usageListFuture.then((usageList) {
      Map<DateTime, List> new_events = {};
      setState(() {
        _events.clear();
        for (int i=0; i<usageList.length; i++) {
          // _events[DateTime.parse(usageList[i].date+' 00:00:00.000')] = _events[DateTime.parse(usageList[i].date+' 00:00:00.000')][0] != null ? _events[DateTime.parse(usageList[i].date+' 00:00:00.000')].add([usageList[i].desc, usageList[i].amount, usageList[i].income]) : [[usageList[i].desc, usageList[i].amount, usageList[i].income]];
          if(_events[DateTime.parse(usageList[i].date+' 00:00:00.000')] != null){
            _events[DateTime.parse(usageList[i].date+' 00:00:00.000')].add([usageList[i].desc, usageList[i].amount, usageList[i].income, usageList[i].id]);
          }else{
            _events[DateTime.parse(usageList[i].date+' 00:00:00.000')] = [[usageList[i].desc, usageList[i].amount, usageList[i].income, usageList[i].id]];
          }
        }
        _selectedEvents = _events[DateTime.parse(today+' 00:00:00.000')] ?? [];
      });
    });
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    print(events);
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showMonthPicker(
                  context: context,
                  firstDate: DateTime( DateTime.now().year - 1 , 5),
                  lastDate: DateTime( DateTime.now().year + 1, 9 ),
                  initialDate: DateTime.now()
              );
    if (picked != null){
      print(picked);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Monthly(picked : picked)),
      );
      // setState(() {
      //   selectedDate = picked;
      // });
    }
  }

  Future<Null> _updateDialog(event) {
    setState(() {
      amountController.text = event[1].toString();
      descController.text = event[0].toString();
      dateController.text = event[4].toString();
      });
    showDialog(
      context: context,
      // builder: (BuildContext context) {
      //   return AlertDialog(
      //     content: Form(
      //       key: _formKey,
      //       child: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: <Widget>[
      //           // Padding(
      //           //   padding: EdgeInsets.all(8.0),
      //           //   child:
      //           // ),
      //           DropdownButton<String>(
      //             // hint : dropDownValue,
      //             value: dropDownValue,
      //             elevation: 16,
      //             underline: Container(
      //               height: 2,
      //             ),
      //             onChanged: (String newValue) {
      //               dropDownValue = newValue;
      //               setState(() {
      //                 print(newValue);
      //                 dropDownValue = 'income';
      //               });
      //             },
      //             items: <String>['outcome', 'income']
      //               .map<DropdownMenuItem<String>>((String value) {
      //                 return DropdownMenuItem<String>(
      //                   value: value,
      //                   child: Text(value),
      //                 );
      //             }).toList(),
      //           ),
      //           Padding(
      //             padding: EdgeInsets.all(8.0),
      //             child: TextFormField(
      //                 controller : amountController,
      //                 keyboardType: TextInputType.number,
      //                 decoration : const InputDecoration(
      //                     hintText : 'Amount',
      //                   ),
      //               ),
      //           ),
      //           Padding(
      //             padding: EdgeInsets.all(8.0),
      //             child: TextFormField(
      //                 controller : descController,
      //                 decoration : const InputDecoration(
      //                     hintText : 'Usage',
      //                   ),
      //               ),
      //           ),
      //           Padding(
      //             padding: EdgeInsets.all(8.0),
      //             child: TextFormField(
      //                 controller : dateController,
      //                 decoration : const InputDecoration(
      //                     hintText : 'Date',
      //                   ),
      //               ),
      //           ),
      //           Row(
      //               children : [
      //                 Expanded(
      //                     child : RaisedButton(
      //                       child: Text("Delete"),
      //                       onPressed: () {
      //                         if(dbHelper.delete(event[3]) != null){
      //                           updateLists();
      //                         };
      //                       },
      //                     ),
      //                   ),
      //                 Expanded(
      //                     child : RaisedButton(
      //                       child: Text("Update"),
      //                       onPressed: () {
      //                         // Dog({1 , "name", 12);
      //                         // Dog({id : 2, name : "bobby", age : 12});
      //                         int status = 0;
      //                         if(dropDownValue == 'income'){
      //                           status =1;
      //                         }
      //                         // Money money;
      //                         print(event);
      //                         final Money money = Money(amountController.text, descController.text, 1, dateController.text);
      //                         money.id = event[3];
      //                         if(dbHelper.update(money) != null){
      //                           updateLists();
      //                         };
      //                         // if (_formKey.currentState.validate()) {
      //                         //   _formKey.currentState.save();
      //                         // }
      //                       },
      //                     ),
      //                   ),
      //               ],
      //             ),
      //         ],
      //       ),
      //     ),
      //   );
      // }
      builder : (context) => dialogEditForm(event:event, update : updateLists),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title),
        actions : <Widget>[
          IconButton(
            icon: Icon(Icons.note),
            color : Colors.black,
            onPressed: () {
              _selectDate(context);
              // showMonthPicker(
              //     context: context,
              //     firstDate: DateTime( DateTime.now().year - 1 , 5),
              //     lastDate: DateTime( DateTime.now().year + 1, 9 ),
              //     initialDate: DateTime.now()
              // ).then((date) => () {
              //           print(date);
              //           if (date != null) {
              //             setState(() {
              //               print(date);
              //             });
              //           }
              //     });
              // final picked = showDatePicker(
              //     context: context,
              //     initialDate: selectedDate,
              //     firstDate: DateTime(2015, 8),
              //     lastDate: DateTime(2101));
              // if (picked != null && picked != selectedDate)
              //   setState(() {
              //     selectedDate = picked;
              //   });
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => Monthly()),
              // );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // _buildTableCalendar(),
            _buildTableCalendarWithBuilders(),
            // const SizedBox(height: 8.0),
            // _buildButtons(),
            // const SizedBox(height: 8.0),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
                context: context,
                builder : (context) => dialogForm(update : updateLists),
          );
        },
        child: Icon(Icons.navigation),
        backgroundColor: Colors.amber,
      ),
    );
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'id_ID',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.red),
        holidayStyle: TextStyle().copyWith(color: Colors.red),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.red),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.amber,
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[200],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

   // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.amber[400],
        todayColor: Colors.amber[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: true,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.amber, fontSize: 8.0),
        formatButtonDecoration: BoxDecoration(
          // color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.deepOrange[400]
            : _calendarController.isToday(date) ? Colors.deepOrange[400] : Colors.deepOrange[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  // Widget _buildButtons() {
  //   return Column(
  //     children: <Widget>[
  //       Row(
  //         mainAxisSize: MainAxisSize.max,
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  //           RaisedButton(
  //             child: Text('month'),
  //             onPressed: () {
  //               setState(() {
  //                 _calendarController.setCalendarFormat(CalendarFormat.month);
  //               });
  //             },
  //           ),
  //           RaisedButton(
  //             child: Text('2 weeks'),
  //             onPressed: () {
  //               setState(() {
  //                 _calendarController.setCalendarFormat(CalendarFormat.twoWeeks);
  //               });
  //             },
  //           ),
  //           RaisedButton(
  //             child: Text('week'),
  //             onPressed: () {
  //               setState(() {
  //                 _calendarController.setCalendarFormat(CalendarFormat.week);
  //               });
  //             },
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 8.0),
  //       RaisedButton(
  //         child: Text('setDay 10-07-2019'),
  //         onPressed: () {
  //           _calendarController.setSelectedDay(DateTime(2019, 7, 10), runCallback: true);
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8, color : Colors.white),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child:
                  Row(
                    children : <Widget>[
                        Expanded(
                            child : ListTile(
                              title: Text(event[0].toString()),
                              onTap: () {
                                  _updateDialog(event);
                                  print(event[0] == 1 ? 'income' : 'outcome');
                                },
                                // print('$event tapped!'),
                            ),
                          ),
                        Expanded(
                            child : ListTile(
                              title: Text(event[2] == 1 ? '+ Rp. '+event[1].toString() : '- Rp. '+event[1].toString(), textAlign : TextAlign.right),
                              onTap: () {
                                  _updateDialog(event);
                                  print(event);
                                },
                                // print('$event tapped!'),
                            ),
                          ),
                        // ListTile(
                        //   title: Text(event[2].toString()),
                        //   onTap: () => print('$event tapped!'),
                        // ),
                      ]
                    ),
              ))
          .toList(),
    );
  }
}

class Monthly extends StatefulWidget {
  final DateTime picked;
  int loops;
  Monthly({Key key, @required this.picked}) : super(key: key);

  @override
  MonthlyStateful createState() {
    return MonthlyStateful(picked);
  }

}

class MonthlyStateful extends State<Monthly> {
  List<List> tableContent = [];
  final DateTime picked;
  MonthlyStateful(this.picked);

  @override
  void initState(){
    updateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly Usage"),
      ),
      body: Container(
          margin : const EdgeInsets.all(10.0),
          child :
            Padding(
                padding : const EdgeInsets.all(20),
                child : Table(
                    children :
                      tableContent.map((content) =>
                        TableRow(
                          decoration : BoxDecoration(
                              border: Border(bottom : BorderSide(color: content[3] == 1 ? Colors.black : Colors.white)),
                          ),
                          children : [
                            TableCell(
                              child : Row(
                                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                  children : <Widget>[
                                    Expanded(
                                        flex : 6,
                                        child : Text(content[0]),
                                      ),
                                    Expanded(
                                        flex : 2,
                                        child : Text(content[2] == 1 ? content[1] : content[3] == 1 ? 'Income' : ''),
                                      ),
                                    Expanded(
                                        flex : 2,
                                        child : Text(content[2] == 0 ? content[1] : content[3] == 1 ? 'Outcome' : ''),
                                      ),
                                  ]
                                ),
                            ),
                          ]
                        ),
                      ).toList(),
                  ),
              ),
        ),
    );
  }

  void updateList() {
    final String parsedDate = DateFormat('yyyy-MM').format(picked);
    DbHelper dbHelper = DbHelper();
    Future<List<Money>> usageListFuture = dbHelper.getMonthList(parsedDate);
    usageListFuture.then((usageList) {
        setState(() {
          tableContent.add(['Desc', 'Income', 'Outcome', 1]);
          for (int i=0; i<usageList.length; i++) {
            tableContent.add([usageList[i].desc,usageList[i].amount,usageList[i].income, 0]);
          }
          tableContent.add(['', 'Total', '25000', 2]);
        });
      });
  }

  // void updateListt() async {
  //   Future<List<Money>> usageListFuture = dbHelper.getMoneyList();
  //   var now = new DateTime.now();
  //   final today = new DateFormat("yyyy-MM-dd").format(now);
  //   // currentTime = DateTime.parse(today.year+'-'+today.month+'-'+today.day+' 00:00:00.000');
  //   await usageListFuture.then((usageList) {
  //     Map<DateTime, List> new_events = {};
  //     setState(() {
  //       for (int i=0; i<usageList.length; i++) {
  //         // _events[DateTime.parse(usageList[i].date+' 00:00:00.000')] = _events[DateTime.parse(usageList[i].date+' 00:00:00.000')][0] != null ? _events[DateTime.parse(usageList[i].date+' 00:00:00.000')].add([usageList[i].desc, usageList[i].amount, usageList[i].income]) : [[usageList[i].desc, usageList[i].amount, usageList[i].income]];
  //         if(_events[DateTime.parse(usageList[i].date+' 00:00:00.000')] != null){
  //           _events[DateTime.parse(usageList[i].date+' 00:00:00.000')].add([usageList[i].desc, usageList[i].amount, usageList[i].income]);
  //         }else{
  //           _events[DateTime.parse(usageList[i].date+' 00:00:00.000')] = [[usageList[i].desc, usageList[i].amount, usageList[i].income]];
  //         }
  //       }
  //       print(_events[DateTime.parse(today+' 00:00:00.000')]);
  //       print(_events);
  //       _selectedEvents = _events[DateTime.parse(today+' 00:00:00.000')] ?? [];
  //     });
  //   });
  // }
}

typedef void dialogFormCallback();
typedef void dialogEditFormCallback();

class dialogForm extends StatefulWidget{
  final dialogFormCallback update;
  dialogForm({this.update});
  _dialogForm createState() => _dialogForm();
}

class _dialogForm extends State<dialogForm>{
  final amountController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();
  DateTime selectedDate;
  DbHelper dbHelper = DbHelper();
  final _formKey = GlobalKey<FormState>();
  List<String> dropItems = ['outcome', 'income'];
  String dropDownValue;
  int _groupValue = 0;
  final now = new DateTime.now();
  final today = new DateFormat("yyyy-MM-dd").format(new DateTime.now());
  @override
  Widget build(BuildContext context){
      setState(() {
            dateController.text = today;
        });
      return AlertDialog(
        content : Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Padding(
              //   padding: EdgeInsets.all(8.0),
              //   child:
              // ),
              // DropdownButton<String>(
              //   // hint : dropDownValue,
              //   value: dropDownValue,
              //   elevation: 16,
              //   underline: Container(
              //     height: 2,
              //   ),
              //   onChanged: (String newValue) {
              //     // dropDownValue = newValue.toString();
              //     setState(() {
              //       dropDownValue = newValue;
              //       print(dropDownValue);
              //     });
              //   },
              //   items: dropItems
              //     .map<DropdownMenuItem<String>>((String value) {
              //       return DropdownMenuItem<String>(
              //         value: value,
              //         child: Text(value),
              //       );
              //   }).toList(),
              // ),
              Container(
                  child : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children : <Widget>[
                        new Radio(
                          value: 1,
                          groupValue: _groupValue,
                          activeColor : Colors.amber,
                          onChanged: (value) => setState(() => this._groupValue = value),
                        ),
                        new Text(
                          'income',
                          style: new TextStyle(fontSize: 13.0),
                        ),
                        new Radio(
                          value: 0,
                          groupValue: _groupValue,
                          activeColor : Colors.amber,
                          onChanged: (value) => setState(() => this._groupValue = value),
                        ),
                        new Text(
                          'outcome',
                          style: new TextStyle(fontSize: 13.0),
                        ),
                      ],
                    ),
                ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                    controller : amountController,
                    keyboardType: TextInputType.number,
                    decoration : const InputDecoration(
                        hintText : 'Amount',
                      ),
                  ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                    controller : descController,
                    decoration : const InputDecoration(
                        hintText : 'Usage',
                      ),
                  ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: new GestureDetector(
                    onTap : () {
                        print('tapped');
                      },
                    behavior: HitTestBehavior.opaque,
                    child : TextFormField(
                            controller : dateController,
                            decoration : const InputDecoration(
                                hintText : 'Date',
                              ),
                          ),
                      ),
                  ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text("Save"),
                  color : Colors.amber,
                  textColor : Colors.black,
                  onPressed: () {
                    int status = 0;
                    if(dropDownValue == 'income'){
                      status =1;
                    }
                    final Money money = Money(amountController.text, descController.text, _groupValue, dateController.text);
                    if(dbHelper.insert(money) != null){
                      widget.update();
                    }
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                    }
                  },
                ),
              )
            ],
          ),
        )
      );
  }
}

class dialogEditForm extends StatefulWidget{
  final List event;
  final dialogEditFormCallback update;
  dialogEditForm({this.event, this.update});
  _dialogEditForm createState() => _dialogEditForm(event);
}

class _dialogEditForm extends State<dialogEditForm>{
  final List event;
  _dialogEditForm(this.event);
  final amountController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();
  DateTime selectedDate;
  DbHelper dbHelper = DbHelper();
  final _formKey = GlobalKey<FormState>();
  List<String> dropItems = ['outcome', 'income'];
  String dropDownValue;
  int _groupValue = 0;
  @override
  Widget build(BuildContext context){
    setState(() {
        amountController.text = event[1].toString();
        descController.text = event[0].toString();
        dateController.text = event[4].toString();
      });
    return AlertDialog(
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Padding(
              //   padding: EdgeInsets.all(8.0),
              //   child:
              // ),
              // DropdownButton<String>(
              //   // hint : dropDownValue,
              //   value: dropDownValue,
              //   elevation: 16,
              //   underline: Container(
              //     height: 2,
              //   ),
              //   onChanged: (String newValue) {
              //     dropDownValue = newValue;
              //     setState(() {
              //       print(newValue);
              //       dropDownValue = 'income';
              //     });
              //   },
              //   items: <String>['outcome', 'income']
              //     .map<DropdownMenuItem<String>>((String value) {
              //       return DropdownMenuItem<String>(
              //         value: value,
              //         child: Text(value),
              //       );
              //   }).toList(),
              // ),
              Container(
                  child : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children : <Widget>[
                        new Radio(
                          value: 0,
                          groupValue: _groupValue,
                          activeColor : Colors.amber,
                          onChanged: (value) => setState(() => this._groupValue = value),
                        ),
                        new Text(
                          'income',
                          style: new TextStyle(fontSize: 13.0),
                        ),
                        new Radio(
                          value: 1,
                          groupValue: _groupValue,
                          activeColor : Colors.amber,
                          onChanged: (value) => setState(() => this._groupValue = value),
                        ),
                        new Text(
                          'outcome',
                          style: new TextStyle(fontSize: 13.0),
                        ),
                      ],
                    ),
                ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                    controller : amountController,
                    keyboardType: TextInputType.number,
                    decoration : const InputDecoration(
                        hintText : 'Amount',
                      ),
                  ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                    controller : descController,
                    decoration : const InputDecoration(
                        hintText : 'Usage',
                      ),
                  ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                    controller : dateController,
                    decoration : const InputDecoration(
                        hintText : 'Date',
                      ),
                  ),
              ),
              Row(
                  children : [
                    Expanded(
                        child : RaisedButton(
                          child: Text("Delete"),
                          color : Colors.amber,
                          textColor : Colors.black,
                          onPressed: () {
                            if(dbHelper.delete(event[3]) != null){
                              widget.update();
                            };
                          },
                        ),
                      ),
                    Expanded(
                        child : RaisedButton(
                          child: Text("Update"),
                          color : Colors.amber,
                          textColor : Colors.black,
                          onPressed: () {
                            // Dog({1 , "name", 12);
                            // Dog({id : 2, name : "bobby", age : 12});
                            int status = 0;
                            if(dropDownValue == 'income'){
                              status =1;
                            }
                            // Money money;
                            print(event);
                            final Money money = Money(amountController.text, descController.text, _groupValue, dateController.text);
                            money.id = event[3];
                            if(dbHelper.update(money) != null){
                              widget.update();
                            };
                            // if (_formKey.currentState.validate()) {
                            //   _formKey.currentState.save();
                            // }
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      );
  }
}