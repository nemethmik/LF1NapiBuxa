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
        primarySwatch: Colors.blue,
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
  //String amount;
  //String description;
  final amountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  bool isBusy = true;
  @override
  void initState() {
    queryExpensesAsyncSetState(); //Set State is very here, too
    super.initState();
  }
  void _addExpenseAsync() async {
    // print(this.amount);
    // print(this.description);
    setState(()=> isBusy = true);
    try {
      var e = Expense.auto(description: descriptionCtrl.text, amount: double.parse(amountCtrl.text));
      await ExpenseService.inst.addExpenseAsync(user: "DEMO",expense: e);
      queryExpensesAsyncSetState();
    } catch(error) {
      print(error.toString());
      setState(()=> isBusy = false);
    }
  }
  Iterable<Expense> _expenses = {};
  Future<void> queryExpensesAsyncSetState() async {
    setState(()=> isBusy = true);
    var queryResult = await ExpenseService.inst.queryExpensesAsync(user: "DEMO");
    setState(() {
      _expenses = queryResult;
      isBusy = false;
    });
  } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              color: Colors.blue,
              child: Text("Graph"),
            ),
            _expenseTextInputFields(),
            isBusy ? Center(child: CircularProgressIndicator(),) : _expenseList(),
          ],
        ),
      ),
    );
  }

  Widget _expenseTextInputFields() => 
    Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: "Description"),
              controller: descriptionCtrl,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Amount"),
              controller: amountCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            FlatButton(
              textColor: Colors.purple,
              child: Text("Add"),
              onPressed: _addExpenseAsync,
            )
          ],
        ),
      ),
    );

  Widget _expenseList() => Container(
    height: 300,
    child: ListView.builder(
      itemCount: _expenses.length, 
      itemBuilder: (BuildContext context, int index) {
        return _expenseCard(_expenses.toList()[index]);
      },),
  );

  Widget _expenseCard(Expense e) => Card(
      //color: Colors.amber,
      child: Row(children: <Widget>[
    Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Text(
        "\$${e.amount.toStringAsFixed(2)}",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
            fontSize: 20),
      ),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.purple, width: 2)),
      padding: EdgeInsets.all(10),
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          e.description,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat.yMd().format(e.date),
          style: TextStyle(color: Colors.grey),
        )
      ],
    )
  ]));
}
