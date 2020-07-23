import 'package:flutter/material.dart';

class SearchableDropdownController extends ValueNotifier{
  List<String> _itemLabels = [];
  List<int> _selectedIndexes = [];

  SearchableDropdownController(List<String> initalItemLabels) : super(null) {
    _itemLabels = initalItemLabels;
  }

  List<String> get itemLabels {
    return _itemLabels;
  }

  set itemLabels(List<String> initalItemLabels) {
    _itemLabels = initalItemLabels;
    notifyListeners();
  }

  List<int> get selectedIndexes {
    return _selectedIndexes;
  }

  void addItemLabel(String itemLabel) {
    _itemLabels.add(itemLabel);
    notifyListeners();
  }

  bool isItemSelected(int itemIndex) {
    return _selectedIndexes.contains(itemIndex);
  }

  void unselectItem(int itemIndex) {
    _selectedIndexes.remove(itemIndex);
    notifyListeners();
  }

  void unselectItemLabel(String itemLabel) {
    unselectItem(_itemLabels.indexOf(itemLabel));
    notifyListeners();
  }

  void selectItemLabel(String itemLabel) {
    selectItem(_itemLabels.indexOf(itemLabel));
    notifyListeners();
  }

  void selectItem(int itemIndex) {
    _selectedIndexes.add(itemIndex);
    notifyListeners();
  }

  List<String> selectedItemLabels() {
    List<String> selectedItemLabels = [];

    for (int itemIndex in _selectedIndexes) {
      selectedItemLabels.add(_itemLabels[itemIndex]);
    }
    return selectedItemLabels;
  }

  void clear() {
    _selectedIndexes.clear();
    notifyListeners();
  }
}