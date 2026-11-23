import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wedding_info.dart';
import '../models/checklist_item.dart';
import '../models/expense_item.dart';
import '../models/guest_item.dart';
import '../models/vendor_item.dart';
import '../models/rundown_item.dart';
import '../utils/default_data.dart';
import '../theme/app_theme.dart';

class WeddingProvider with ChangeNotifier {
  late WeddingInfo _weddingInfo;
  List<ChecklistItem> _checklist = [];
  List<ExpenseItem> _expenses = [];
  List<GuestItem> _guests = [];
  List<VendorItem> _vendors = [];
  List<RundownItem> _rundowns = [];
  WeddingThemePalette _currentTheme = WeddingThemePalette.roseGold;
  bool _isLoading = true;

  WeddingProvider() {
    _weddingInfo = DefaultData.weddingInfo;
    _checklist = DefaultData.checklistItems;
    _expenses = DefaultData.expenses;
    _guests = DefaultData.guests;
    _vendors = DefaultData.vendors;
    _rundowns = DefaultData.rundowns;
    loadData();
  }

  // Getters
  WeddingInfo get weddingInfo => _weddingInfo;
  List<ChecklistItem> get checklist => _checklist;
  List<ExpenseItem> get expenses => _expenses;
  List<GuestItem> get guests => _guests;
  List<VendorItem> get vendors => _vendors;
  List<RundownItem> get rundowns => _rundowns;
  WeddingThemePalette get currentTheme => _currentTheme;
  bool get isLoading => _isLoading;

  // Countdown calculations
  int get daysRemaining {
    final diff = _weddingInfo.weddingDate.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inDays;
  }

  int get hoursRemaining {
    final diff = _weddingInfo.weddingDate.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inHours % 24;
  }

  int get minutesRemaining {
    final diff = _weddingInfo.weddingDate.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inMinutes % 60;
  }

  // Budget calculations
  double get totalBudget => _weddingInfo.totalBudget;

  double get totalEstimatedExpense {
    return _expenses.fold(0.0, (sum, item) => sum + item.estimatedCost);
  }

  double get totalActualExpense {
    return _expenses.fold(
      0.0,
      (sum, item) => sum + (item.actualCost > 0 ? item.actualCost : item.estimatedCost),
    );
  }

  double get totalPaidExpense {
    return _expenses.fold(0.0, (sum, item) => sum + item.paidAmount);
  }

  double get remainingBudget => totalBudget - totalActualExpense;

  double get budgetProgressPercentage {
    if (totalBudget <= 0) return 0.0;
    final ratio = totalActualExpense / totalBudget;
    return ratio.clamp(0.0, 1.0);
  }

  // Checklist calculations
  int get totalChecklistCount => _checklist.length;
  int get completedChecklistCount => _checklist.where((c) => c.isDone).length;
  double get checklistProgress {
    if (totalChecklistCount == 0) return 0.0;
    return completedChecklistCount / totalChecklistCount;
  }

  // Guest calculations
  int get totalGuests => _guests.fold(0, (sum, item) => sum + item.pax);
  int get totalAttendingGuests => _guests
      .where((g) => g.rsvpStatus == RsvpStatus.attending)
      .fold(0, (sum, item) => sum + item.pax);
  int get invitationsSentCount => _guests.where((g) => g.isInvitationSent).length;

  // Local Storage Persistence
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final weddingInfoString = prefs.getString('nikah_wedding_info');
      if (weddingInfoString != null) {
        _weddingInfo = WeddingInfo.fromJson(jsonDecode(weddingInfoString));
      }

      final checklistString = prefs.getString('nikah_checklist');
      if (checklistString != null) {
        final List<dynamic> list = jsonDecode(checklistString);
        _checklist = list.map((e) => ChecklistItem.fromJson(e)).toList();
      }

      final expenseString = prefs.getString('nikah_expenses');
      if (expenseString != null) {
        final List<dynamic> list = jsonDecode(expenseString);
        _expenses = list.map((e) => ExpenseItem.fromJson(e)).toList();
      }

      final guestString = prefs.getString('nikah_guests');
      if (guestString != null) {
        final List<dynamic> list = jsonDecode(guestString);
        _guests = list.map((e) => GuestItem.fromJson(e)).toList();
      }

      final vendorString = prefs.getString('nikah_vendors');
      if (vendorString != null) {
        final List<dynamic> list = jsonDecode(vendorString);
        _vendors = list.map((e) => VendorItem.fromJson(e)).toList();
      }

      final rundownString = prefs.getString('nikah_rundowns');
      if (rundownString != null) {
        final List<dynamic> list = jsonDecode(rundownString);
        _rundowns = list.map((e) => RundownItem.fromJson(e)).toList();
      }

      final themeId = prefs.getString('nikah_theme_id');
      if (themeId != null) {
        _currentTheme = WeddingThemePalette.fromId(themeId);
      }
    } catch (e) {
      debugPrint('Error loading data from SharedPreferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nikah_wedding_info', jsonEncode(_weddingInfo.toJson()));
      await prefs.setString('nikah_checklist', jsonEncode(_checklist.map((e) => e.toJson()).toList()));
      await prefs.setString('nikah_expenses', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
      await prefs.setString('nikah_guests', jsonEncode(_guests.map((e) => e.toJson()).toList()));
      await prefs.setString('nikah_vendors', jsonEncode(_vendors.map((e) => e.toJson()).toList()));
      await prefs.setString('nikah_rundowns', jsonEncode(_rundowns.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving data to SharedPreferences: $e');
    }
  }

  // Wedding Info Methods
  void updateWeddingInfo(WeddingInfo info) {
    _weddingInfo = info;
    notifyListeners();
    _saveAll();
  }

  // Checklist Methods
  void addChecklistItem(ChecklistItem item) {
    _checklist.insert(0, item);
    notifyListeners();
    _saveAll();
  }

  void updateChecklistItem(ChecklistItem item) {
    final index = _checklist.indexWhere((c) => c.id == item.id);
    if (index != -1) {
      _checklist[index] = item;
      notifyListeners();
      _saveAll();
    }
  }

  void toggleChecklistStatus(String id) {
    final index = _checklist.indexWhere((c) => c.id == id);
    if (index != -1) {
      final current = _checklist[index];
      _checklist[index] = current.copyWith(isDone: !current.isDone);
      notifyListeners();
      _saveAll();
    }
  }

  void deleteChecklistItem(String id) {
    _checklist.removeWhere((c) => c.id == id);
    notifyListeners();
    _saveAll();
  }

  // Expense Methods
  void addExpenseItem(ExpenseItem item) {
    _expenses.insert(0, item);
    notifyListeners();
    _saveAll();
  }

  void updateExpenseItem(ExpenseItem item) {
    final index = _expenses.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _expenses[index] = item;
      notifyListeners();
      _saveAll();
    }
  }

  void deleteExpenseItem(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    _saveAll();
  }

  // Guest Methods
  void addGuestItem(GuestItem item) {
    _guests.insert(0, item);
    notifyListeners();
    _saveAll();
  }

  void updateGuestItem(GuestItem item) {
    final index = _guests.indexWhere((g) => g.id == item.id);
    if (index != -1) {
      _guests[index] = item;
      notifyListeners();
      _saveAll();
    }
  }

  void toggleInvitationSent(String id) {
    final index = _guests.indexWhere((g) => g.id == id);
    if (index != -1) {
      final current = _guests[index];
      _guests[index] = current.copyWith(isInvitationSent: !current.isInvitationSent);
      notifyListeners();
      _saveAll();
    }
  }

  void deleteGuestItem(String id) {
    _guests.removeWhere((g) => g.id == id);
    notifyListeners();
    _saveAll();
  }

  // Vendor Methods
  void addVendorItem(VendorItem item) {
    _vendors.insert(0, item);
    notifyListeners();
    _saveAll();
  }

  void updateVendorItem(VendorItem item) {
    final index = _vendors.indexWhere((v) => v.id == item.id);
    if (index != -1) {
      _vendors[index] = item;
      notifyListeners();
      _saveAll();
    }
  }

  void deleteVendorItem(String id) {
    _vendors.removeWhere((v) => v.id == id);
    notifyListeners();
    _saveAll();
  }

  // Rundown Methods
  void addRundownItem(RundownItem item) {
    _rundowns.add(item);
    notifyListeners();
    _saveAll();
  }

  void updateRundownItem(RundownItem item) {
    final index = _rundowns.indexWhere((r) => r.id == item.id);
    if (index != -1) {
      _rundowns[index] = item;
      notifyListeners();
      _saveAll();
    }
  }

  void deleteRundownItem(String id) {
    _rundowns.removeWhere((r) => r.id == id);
    notifyListeners();
    _saveAll();
  }

  // Theme Switcher
  void setTheme(WeddingThemePalette palette) async {
    _currentTheme = palette;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nikah_theme_id', palette.id);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  // Reset to default
  void resetToDefault() {
    _weddingInfo = DefaultData.weddingInfo;
    _checklist = DefaultData.checklistItems;
    _expenses = DefaultData.expenses;
    _guests = DefaultData.guests;
    _vendors = DefaultData.vendors;
    _rundowns = DefaultData.rundowns;
    _currentTheme = WeddingThemePalette.roseGold;
    notifyListeners();
    _saveAll();
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('nikah_theme_id', WeddingThemePalette.roseGold.id);
      });
    } catch (_) {}
  }
}
