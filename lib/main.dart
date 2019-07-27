import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './expenseservicedemoimpl.dart' show ExpenseService;
import './expense.dart';

void main() => runApp(NapiBuxaApp());

class NapiBuxaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Napi Buxa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NapiBuxaHomePage(title: 'Personal Expenses'),
    );
  }
}

class NapiBuxaHomePage extends StatefulWidget {
  NapiBuxaHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _NapiBuxaHomePageState createState() => _NapiBuxaHomePageState();
}

class _NapiBuxaHomePageState extends State<NapiBuxaHomePage> {
  final amountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  Future<Iterable<Expense>> _expensesFuture;
  @override
  void initState() {
    _expensesFuture = ExpenseService.inst.queryExpensesAsync(user: "DEMO");
    super.initState();
  }
  void _addExpenseAsync() async {
    setState(()=>_expensesFuture = null);
    try {
      var e = Expense.auto(description: descriptionCtrl.text, amount: double.parse(amountCtrl.text));
      await ExpenseService.inst.addExpenseAsync(user: "DEMO",expense: e);
      setState(() {
        _expensesFuture = ExpenseService.inst.queryExpensesAsync(user: "DEMO");
      });
    } catch(error) {
      setState(() {_expensesFuture = _throwError(error);});
    }
  }
  Future<Iterable<Expense>> _throwError(dynamic error) async {throw error;}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              color: Colors.blue,
              child: Text("Graph"),
            ),
            _expenseTextInputFields(),
            FutureBuilder<Iterable<Expense>>(future: _expensesFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch(snapshot.connectionState) {
                  case ConnectionState.done:
                    if(snapshot.hasError) return Text(snapshot.error.toString());
                    return _expenseList(snapshot.data);
                  default: return Center(child: CircularProgressIndicator(),);
                }
            },)
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
              //onChanged: (v){description = v;},
            ),
            TextField(
              decoration: InputDecoration(labelText: "Amount"),
              controller: amountCtrl,
              //onChanged: (v) => amount = v,
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

  Widget _expenseList(Iterable<Expense> expenses) => Column(
    children: <Widget>[
      ...expenses.map((e) => _expenseCard(e))
    ]);

  Widget _expenseCard(Expense e) => Card(
      //color: Colors.amber,
      child: Row(children: <Widget>[
    Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Text(
        "\$${e.amount}",
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
