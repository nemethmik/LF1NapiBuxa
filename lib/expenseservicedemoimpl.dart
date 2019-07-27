import './expense.dart';
import './iexpenseservice.dart';

class _ExpenseServiceDemoImpl implements IExpenseService {
  final Map<int,Expense> _expenses = {};
  _ExpenseServiceDemoImpl(){
    addExpenseAsync(expense: Expense(id: 1, date: DateTime.now(), description: "New shoe", amount: 100.5, ));
    addExpenseAsync(expense: Expense(id: 2, date: DateTime.now(), description: "Sony A9", amount: 2000, ));
  }
  @override
  Future<Iterable<Expense>> queryExpensesAsync({String user, DateTime from, DateTime to}) async {
    await Future.delayed(Duration(seconds: 1)); //To simulate network delays    
    return _expenses.values;
  }
  @override
  Future<int> addExpenseAsync({String user,Expense expense}) async {
    if(expense.id == null) throw Exception("No ID defined for expense");
    _expenses[expense.id] = expense;
    await Future.delayed(Duration(seconds: 2)); //To simulate network delays
    return expense.id;
  }
  @override
  Future<Expense> getExpenseByIdAsync(int id) async {
    return _expenses[id];
  }
}
abstract class ExpenseService {
  static final IExpenseService inst = _ExpenseServiceDemoImpl();
}
// Factory cannot be used for programming this interface returning concept
// class ExpenseService {
//   static final IExpenseService _instance = _ExpenseServiceDemoImpl();
//   factory ExpenseService() => _instance;
// }