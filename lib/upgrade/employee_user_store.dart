import 'package:flutter/material.dart';
import 'employee_user_model.dart';

class EmployeeUserStore extends ChangeNotifier {
  static final EmployeeUserStore _instance = EmployeeUserStore._internal();
  factory EmployeeUserStore() => _instance;
  EmployeeUserStore._internal();

  final List<EmployeeUser> _employees = [];

  List<EmployeeUser> get employees => List.unmodifiable(_employees);

  void addEmployee(EmployeeUser employee) {
    _employees.add(employee);
    notifyListeners();
  }

  bool get hasData => _employees.isNotEmpty;

  void clear() {
    _employees.clear();
    notifyListeners();
  }
}
