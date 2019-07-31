import './expense.dart';
import './iexpenseservice.dart';

class _ExpenseServiceDemoImpl implements IExpenseService {
  final Map<int,Expense> _expenses = {};
  _ExpenseServiceDemoImpl(){
    addExpenseAsync(expense: Expense(id: 1, date: DateTime.now(), description: "New shoe", amount: 10.5, ));
    addExpenseAsync(expense: Expense(id: 2, date: DateTime.now(), description: "Sony A9 battery", amount: 20, ));
    addExpenseAsync(expense: Expense(id: 3, date: DateTime.now().subtract(Duration(days: 1)), description: "Socks", amount: 32.7, ));
    addExpenseAsync(expense: Expense(id: 4, date: DateTime.now().subtract(Duration(days: 3)), description: "Wine", amount: 20.89, ));
    addExpenseAsync(expense: Expense(id: 5, date: DateTime.now().subtract(Duration(days: 7)), description: "Peanuts", amount: 15.8, ));
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
  @override
  Future deleteExpenseByIdAsync(int id) {
    _expenses.remove(id);
    return null;
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