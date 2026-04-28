import 'package:flutter/material.dart';
import 'business_user_model.dart';

class BusinessUserStore extends ChangeNotifier {
  static final BusinessUserStore _instance = BusinessUserStore._internal();
  factory BusinessUserStore() => _instance;
  BusinessUserStore._internal();

  final List<BusinessUser> _businesses = [];

  List<BusinessUser> get businesses => List.unmodifiable(_businesses);

  void addBusiness(BusinessUser business) {
    _businesses.add(business);
    notifyListeners();
  }

  void updateBusiness(BusinessUser updatedBusiness) {
    final index = _businesses.indexWhere((b) => b.id == updatedBusiness.id);
    if (index != -1) {
      _businesses[index] = updatedBusiness;
      notifyListeners();
    }
  }

  BusinessUser? getBusinessById(String id) {
    try {
      return _businesses.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}
