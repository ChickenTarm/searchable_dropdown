import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:searchable_dropdown/src/searchable_multiple_dropdown/DropdownMultiAddingDialog.dart';
import 'package:searchable_dropdown/src/searchable_multiple_dropdown/SearchableDropdownController.dart';

const EdgeInsetsGeometry _kAlignedButtonPadding =
    EdgeInsetsDirectional.only(start: 16.0, end: 4.0);
const EdgeInsets _kUnalignedButtonPadding = EdgeInsets.zero;

class NotGiven {
  const NotGiven();
}

class PointerThisPlease<T> {
  T value;
  PointerThisPlease(this.value);
}

class SearchableMultiAddingDropdown extends StatefulWidget {
  final DropdownMenuItem<String> Function(String itemLabel) dropdownItemBuilder;
  final SearchableDropdownController searchableDropdownController;
  final TextStyle style;
  final Widget searchHint;
  final Widget hint;
  final Widget searchIcon;
  final Widget underline;
  final dynamic doneButton;
  final Widget label;
  final dynamic closeButton;
  final bool displayClearIcon;
  final Widget clearIcon;
  final Color iconEnabledColor;
  final Color iconDisabledColor;
  final bool isCaseSensitiveSearch;
  final List<int> Function(String, List<DropdownMenuItem<String>>) searchFn;
  final Widget Function(String) selectedValueWidgetBuilder;
  final TextInputType keyboardType;
  final String Function(List<int>) validator;
  final Widget Function(DropdownMenuItem<String>, bool) displayItem;
  final bool dialogBox;
  final BoxConstraints menuConstraints;
  final Color menuBackgroundColor;

  /// Search choices Widget with a multiple choice that opens a dialog or a menu to let the user do the selection conveniently with a search.
  ///
  /// @param style used for the hint if it is given is [String].
  /// @param searchHint [String]|[Widget]|[Function] with no parameter returning [String]|[Widget] displayed at the top of the search dialog box.
  /// @param hint [String]|[Widget]|[Function] with no parameter returning [String]|[Widget] displayed before any value is selected or after the selection is cleared.
  /// @param icon [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed next to the selected items or the hint if none.
  /// @param underline [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed below the selected items or the hint if none.
  /// @param doneButton [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed at the top of the search dialog box. Cannot be null in multiple selection mode.
  /// @param label [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed above the selected items or the hint if none.
  /// @param closeButton [String]|[Widget]|[Function] with parameter: __selectedItems__ returning [String]|[Widget] displayed at the bottom of the search dialog box.
  /// @param displayClearIcon whether or not to display an icon to clear the selected values.
  /// @param clearIcon [Icon] to be used for clearing the selected values.
  /// @param iconEnabledColor [Color] to be used for enabled icons.
  /// @param iconDisabledColor [Color] to be used for disabled icons.
  /// @param isCaseSensitiveSearch only used when searchFn is not specified.
  /// @param searchFn [Function] with parameters: __keyword__, __items__ returning [List<int>] as the list of indexes for the items to be displayed.
  /// @param selectedValueWidgetFn [Function] with parameter: __item__ returning [Widget] to be used to display the selected values.
  /// @param keyboardType used for the search.
  /// @param validator [Function] with parameter: __selectedItems__ returning [String] to be used to determine if the selection is valid, ex: must select atleast 3
  /// @param displayItem [Function] with parameters: __item__, __selected__ returning [Widget] to be displayed in the search list.
  /// @param dialogBox whether the search should be displayed as a dialog box or as a menu below the selected values if any.
  /// @param menuConstraints [BoxConstraints] used to define the zone where to display the search menu. Example: BoxConstraints.tight(Size.fromHeight(250)) . Not to be used for dialogBox = true.
  /// @param menuBackgroundColor [Color] background color of the menu whether in dialog box or menu mode.
  SearchableMultiAddingDropdown({
    Key key,
    @required this.dropdownItemBuilder,
    @required this.searchableDropdownController,
    this.style,
    this.searchHint,
    this.hint,
    this.searchIcon = const Icon(Icons.arrow_drop_down),
    this.underline,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.isCaseSensitiveSearch = false,
    this.closeButton,
    this.displayClearIcon = true,
    this.clearIcon = const Icon(Icons.clear),
    this.selectedValueWidgetBuilder,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.label,
    this.searchFn,
    this.doneButton,
    this.displayItem,
    this.dialogBox = true,
    this.menuConstraints,
    this.menuBackgroundColor,
  })  : assert(doneButton != null),
        assert(menuConstraints == null || !dialogBox),
        super(key: key);

  @override
  _SearchableMultiAddingDropdownState createState() =>
      new _SearchableMultiAddingDropdownState();
}

class _SearchableMultiAddingDropdownState
    extends State<SearchableMultiAddingDropdown> {
  final FocusNode _defaultFocus = FocusNode();
  List<DropdownMenuItem<String>> dropdownMenuItems = [];
  PointerThisPlease<bool> displayMenu = PointerThisPlease<bool>(false);

  TextStyle get _textStyle =>
      widget.style ??
      (_enabled
          ? Theme.of(context).textTheme.subtitle1
          : Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(color: _disabledIconColor));
  bool get _enabled => dropdownMenuItems.isNotEmpty;

  Color get _enabledIconColor {
    if (widget.iconEnabledColor != null) {
      return widget.iconEnabledColor;
    }
    switch (Theme.of(context).brightness) {
      case Brightness.light:
        return Colors.grey.shade700;
      case Brightness.dark:
        return Colors.white70;
    }
    return Colors.grey.shade700;
  }

  Color get _disabledIconColor {
    if (widget.iconDisabledColor != null) {
      return widget.iconDisabledColor;
    }
    switch (Theme.of(context).brightness) {
      case Brightness.light:
        return Colors.grey.shade400;
      case Brightness.dark:
        return Colors.white10;
    }
    return Colors.grey.shade400;
  }

  bool get valid {
    if (widget.validator == null) {
      return (true);
    }
    return (widget
            .validator(widget.searchableDropdownController.selectedIndexes) ==
        null);
  }

  bool get hasSelection {
    return (widget.searchableDropdownController.selectedIndexes.isNotEmpty);
  }

  int indexFromValue(String value) {
    return (dropdownMenuItems.indexWhere((DropdownMenuItem<String> item) {
      return (item.value == value);
    }));
  }

  void update() {
    if (dropdownMenuItems.isEmpty &&
        widget.searchableDropdownController.itemLabels.isNotEmpty) {
      for (String label in widget.searchableDropdownController.itemLabels) {
        dropdownMenuItems.add(DropdownMenuItem(
          child: Text(label),
          value: label,
        ));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    widget.searchableDropdownController.addListener(update);

    for (String label in widget.searchableDropdownController.itemLabels) {
      dropdownMenuItems.add(DropdownMenuItem(
        child: Text(label),
        value: label,
      ));
    }

    _updateSelectedIndex();
    super.initState();
  }

  @override
  void dispose() {
    widget.searchableDropdownController.removeListener(update);
    super.dispose();
  }

  void _updateSelectedIndex() {
    if (!_enabled) {
      return;
    }
  }

  @override
  void didUpdateWidget(SearchableMultiAddingDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  Widget get menuWidget {
    return DropdownMultiAddingDialog(
      items: dropdownMenuItems,
      dropdownItemBuilder: widget.dropdownItemBuilder,
      searchableDropdownController: widget.searchableDropdownController,
      hint: widget.searchHint,
      isCaseSensitiveSearch: widget.isCaseSensitiveSearch,
      closeButton: widget.closeButton,
      keyboardType: widget.keyboardType,
      searchFn: widget.searchFn,
      doneButton: widget.doneButton,
      displayItem: widget.displayItem,
      validator: widget.validator,
      dialogBox: widget.dialogBox,
      displayMenu: displayMenu,
      menuConstraints: widget.menuConstraints,
      menuBackgroundColor: widget.menuBackgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (int itemIndex in widget.searchableDropdownController.selectedIndexes) {
      list.add(widget
          .selectedValueWidgetBuilder(dropdownMenuItems[itemIndex].value));
    }
    Widget selectedItemsWidget = Wrap(
      alignment: WrapAlignment.start,
      children: list,
    );
    final EdgeInsetsGeometry padding = ButtonTheme.of(context).alignedDropdown
        ? _kAlignedButtonPadding
        : _kUnalignedButtonPadding;

    Widget searchBox = InkWell(
        key: Key(
            "clickableResultPlaceHolder"), //this key is used for running automated tests
        onTap: !_enabled
            ? null
            : () async {
                if (widget.dialogBox) {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                    currentFocus.requestFocus(_defaultFocus);
                  }

                  await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return (menuWidget);
                      });
                } else {
                  displayMenu.value = true;
                }
              },
        child: Row(
          children: <Widget>[
            Expanded(child: widget.hint),
            widget.searchIcon,
          ],
        ));

    Widget result = DefaultTextStyle(
      style: _textStyle,
      child: Container(
        padding: padding.resolve(Directionality.of(context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(child: searchBox),
            !widget.displayClearIcon
                ? SizedBox()
                : InkWell(
                    onTap: clearSelection,
                    child: Container(
                      padding: padding.resolve(Directionality.of(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconTheme(
                            data: IconThemeData(
                              color: hasSelection && _enabled
                                  ? _enabledIconColor
                                  : _disabledIconColor,
                            ),
                            child: widget.clearIcon ?? Icon(Icons.clear),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );

    String validatorOutput;
    if (widget.validator != null) {
      validatorOutput =
          widget.validator(widget.searchableDropdownController.selectedIndexes);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.label ?? SizedBox.shrink(),
        Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: result,
            ),
            widget.underline is NotGiven
                ? SizedBox.shrink()
                : Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 8.0,
                    child: widget.underline ??
                        Container(
                          height: 1.0,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: valid ? Color(0xFFBDBDBD) : Colors.red,
                                  width: 0.0),
                            ),
                          ),
                        ),
                  ),
          ],
        ),
        valid
            ? SizedBox.shrink()
            : validatorOutput is String
                ? Text(
                    validatorOutput,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13.0,
                    ),
                  )
                : null,
        displayMenu.value ? menuWidget : SizedBox.shrink(),
        selectedItemsWidget,
      ],
    );
  }

  void clearSelection() {
    widget.searchableDropdownController.clear();
  }
}
