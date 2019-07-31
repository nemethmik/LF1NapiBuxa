import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './expenseservicedemoimpl.dart' show ExpenseService;
import './expense.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Napi Buxa',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        accentColor: Colors.pink,
        fontFamily: "Quicksand",
        textTheme: ThemeData.light().textTheme.copyWith(
          title: TextStyle(fontFamily: "OpenSans",fontSize: 18,fontWeight: FontWeight.bold,),
        ),
        appBarTheme: AppBarTheme(textTheme: ThemeData.light().textTheme.copyWith(
          title: TextStyle(fontFamily: "OpenSans",fontSize: 20,fontWeight: FontWeight.bold,),
        ))
      ),
      
      home: MyHomePage(title: 'Personal Expenses'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final _amountCtrl = TextEditingController();
  // final _descriptionCtrl = TextEditingController();
  bool _isBusy = true;
  @override
  void initState() {
    _queryExpensesAsyncSetState(); //Set State is very here, too
    super.initState();
  }
  void _addExpenseAsync(String description,double amount,DateTime date) async {
    setState(()=> _isBusy = true);
    try {
      var e = Expense.auto(description: description, amount: amount,date: date);
      await ExpenseService.inst.addExpenseAsync(user: "DEMO",expense: e);
      _queryExpensesAsyncSetState();
    } catch(error) {
      print(error.toString());
      setState(()=> _isBusy = false);
    }
  }
  void _deleteExpense(int id) async {
    setState(()=> _isBusy = true);
    try {
      await ExpenseService.inst.deleteExpenseByIdAsync(id);
      _queryExpensesAsyncSetState();
    } catch(error) {
      print(error.toString());
      setState(()=> _isBusy = false);
    }
  }
  Iterable<Expense> _expenses = {};
  Future<void> _queryExpensesAsyncSetState() async {
    setState(()=> _isBusy = true);
    var queryResult = await ExpenseService.inst.queryExpensesAsync(user: "DEMO");
    setState(() {
      _expenses = queryResult;
      _isBusy = false;
    });
  } 
  void _openExpenseDetailsDialog(){
    showModalBottomSheet(context: context, builder: (BuildContext _) {
      //return _expenseTextInputFields();
      return ExpenseDetailsDialog(addExpenseAsync: _addExpenseAsync,);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), 
            onPressed: _openExpenseDetailsDialog,)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add), 
        onPressed: _openExpenseDetailsDialog,),
      body:  
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if(MediaQuery.of(context).orientation == Orientation.portrait) _lastWeekExpenseGraph(),
            _isBusy ? Center(child: CircularProgressIndicator(),) : _expenseList(),
          ],
        ),
    );
  }
  double _weeklyTotal = 0.0; //calculated by _lastWeekExpenseAmounts
  Map<DateTime,double> _lastWeekExpenseAmounts() {
    final Map<DateTime,double> m = {};
    for(int i = 6;i >= 0;i--) {      
      final weekDay = DateTime.now().subtract(Duration(days: i));
      final dayStr = DateFormat.yMd().format(weekDay);
      double total = 0.0;
      _weeklyTotal = 0.0;
      // _expenses.forEach((e){
      //   if(DateFormat.yMd().format(e.date) == dayStr) total += e.amount;
      // });
      for (var e in _expenses){
        _weeklyTotal += e.amount;
        if(DateFormat.yMd().format(e.date) == dayStr) total += e.amount;
      }
      m[weekDay] = total;
    }
    return m;
  }
  Widget _chartBar(String label, double dailyAmount,double weeklyTotal) {
    double percentageOfTotal = weeklyTotal > 0 ? dailyAmount / weeklyTotal : 0;
    return Column(children: <Widget>[
      Text(dailyAmount > 0 ? "\$" + dailyAmount.toStringAsFixed(0) : ""),
      SizedBox(height: 4,),
      Container(height: 60,width: 10,
        child: Stack(children: <Widget>[
          Container(decoration: BoxDecoration(
              border: Border.all(color: Colors.grey,width: 1),
              color: Color.fromRGBO(220, 220, 220, 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FractionallySizedBox(heightFactor: percentageOfTotal,
            child: Container(decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),),)
        ],),),
      SizedBox(height: 4,),
      Text(label),
    ],);
  }
  Widget _lastWeekExpenseGraph() =>
    Card(
      elevation: 6, margin: EdgeInsets.all(8),
      color: Colors.blue,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
        children: <Widget>[
          for(var e in _lastWeekExpenseAmounts().entries)  
            _chartBar(DateFormat.E().format(e.key).substring(0,2), e.value, _weeklyTotal)    
          ],
        ),
    );

  Widget _expenseList() =>  _expenses.isEmpty // Ternary conditional expression 
  ? Container(height: 300,child: Column(children: <Widget>[
      Text("No expenses",style: Theme.of(context).textTheme.title,),
      SizedBox(height: 16,),
      Image.asset("assets/images/waiting.png", height: 200,),
    ],),) 
  : Expanded(child: 
      ListView.builder(
        shrinkWrap: true,
        itemCount: _expenses.length, 
        itemBuilder: (BuildContext context, int index) {
          // return _expenseCard(_expenses.toList()[index]);
          return _expenseTile(_expenses.toList()[index]);
      },),
    );


  Widget _expenseTile(Expense e) => Card( elevation: 5,
    margin: EdgeInsets.all(4),
      child: ListTile(
      leading: CircleAvatar(radius: 30,
        child: FittedBox(child: Text("\$" + e.amount.toStringAsFixed(0))),),
      title: Text(e.description,style: Theme.of(context).textTheme.title,),
      subtitle: Text(DateFormat.yMd().format(e.date),),
      trailing: IconButton(icon: Icon(Icons.delete), color:Theme.of(context).errorColor,
        onPressed: () {_deleteExpense(e.id);},),
    ),
  );
}

class ExpenseDetailsDialog extends StatefulWidget {
  final void Function(String,double,DateTime) addExpenseAsync;
  const ExpenseDetailsDialog({Key key, this.addExpenseAsync}) : super(key: key);
  @override
  _ExpenseDetailsDialogState createState() => _ExpenseDetailsDialogState();
}

class _ExpenseDetailsDialogState extends State<ExpenseDetailsDialog> {
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DateTime _pickedDate = DateTime.now();
  void _onDatePicked() async {
    DateTime dateChosen = await showDatePicker(context: context, initialDate: DateTime.now(), 
      firstDate: DateTime(DateTime.now().year), lastDate: DateTime.now(),
    );
    setState(() {
      _pickedDate = dateChosen;
    }); 
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: "Description"),
              controller: _descriptionCtrl,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Amount"),
              controller: _amountCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            Row(children: <Widget>[
              Expanded(child: Text( _pickedDate == null ? "No Date" : DateFormat.yMd().format(_pickedDate))),
              FlatButton(child: Text("Pick"),
                  onPressed: _onDatePicked,
                  textColor: Theme.of(context).primaryColor,)
            ],),
            RaisedButton(
              textColor: Colors.purple,
              child: Text("Add"),
              onPressed: (){
                double amount = 0.0;
                try{amount = double.parse(_amountCtrl.text);}catch(e){print(e);}
                widget.addExpenseAsync(_descriptionCtrl.text, amount,_pickedDate);
                Navigator.of(context).pop();//Close the modal dialog box
              },
            )
          ],
        ),
      ),
    );
  }
}