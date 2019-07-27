import "package:meta/meta.dart";
//import 'package:flutter/foundation.dart';
class Expense {
  final int id;
  final String description;
  final double amount;
  final DateTime date;
  Expense({@required this.id, @required this.description, @required this.amount, @required this.date});
  Expense.auto({@required this.description, @required this.amount}) : 
    id  = DateTime.now().millisecondsSinceEpoch, date = DateTime.now();
}