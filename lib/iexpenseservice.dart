import "package:meta/meta.dart";
import './expense.dart';

abstract class IExpenseService {
  Future<Iterable<Expense>> queryExpensesAsync({@required String user, DateTime from, DateTime to});
  Future<int> addExpenseAsync({@required String user,@required Expense expense}); //ID automatically generated
  Future<Expense> getExpenseByIdAsync(int id);
}