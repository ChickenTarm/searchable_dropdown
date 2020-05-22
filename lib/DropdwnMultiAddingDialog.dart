import 'package:flutter/material.dart';
import 'package:searchable_dropdown/SearchableDropdownController.dart';
import 'package:searchable_dropdown/searchable_multiple_dropdown.dart';

class NotGiven {
  const NotGiven();
}

Widget prepareWidget(dynamic object,
    {List<int> parameter,
    BuildContext context,
    Widget Function(String) stringToWidgetFunction}) {
  if (object == null) {
    return (null);
  }
  if (object is Widget) {
    return (object);
  }
  if (object is String) {
    if (stringToWidgetFunction == null) {
      return (Text(object));
    } else {
      return (stringToWidgetFunction(object));
    }
  }
  if (object is Function) {
    if (parameter == null) {
      if (context == null) {
        return (prepareWidget(object(),
            stringToWidgetFunction: stringToWidgetFunction));
      } else {
        return (prepareWidget(object(context),
            stringToWidgetFunction: stringToWidgetFunction));
      }
    }
    if (context == null) {
      return (prepareWidget(object(parameter),
          stringToWidgetFunction: stringToWidgetFunction));
    }
    return (prepareWidget(object(parameter, context),
        stringToWidgetFunction: stringToWidgetFunction));
  }
  return (Text("Unknown type: ${object.runtimeType.toString()}"));
}

class DropdownMuliAddingDialog extends StatefulWidget {
  final List<DropdownMenuItem<String>> items;
  final DropdownMenuItem<String> Function(String itemLabel) dropdownItemBuilder;
  final SearchableDropdownController searchableDropdownController;
  final Widget hint;
  final bool isCaseSensitiveSearch;
  final dynamic closeButton;
  final TextInputType keyboardType;
  final List<int> Function(String, List<DropdownMenuItem<String>>) searchFn;
  final Widget Function(DropdownMenuItem<String>, bool) displayItem;
  final dynamic doneButton;
  final String Function(List<int>) validator;
  final bool dialogBox;
  final PointerThisPlease<bool> displayMenu;
  final BoxConstraints menuConstraints;
  final Color menuBackgroundColor;

  DropdownMuliAddingDialog({
    Key key,
    this.items,
    this.dropdownItemBuilder,
    this.searchableDropdownController,
    this.hint,
    this.isCaseSensitiveSearch = false,
    this.closeButton,
    this.keyboardType,
    this.searchFn,
    this.displayItem,
    this.doneButton,
    this.validator,
    this.dialogBox,
    this.displayMenu,
    this.menuConstraints,
    this.menuBackgroundColor,
  })  : assert(items != null),
        super(key: key);

  @override
  _DropdownMuliAddingDialogState createState() =>
      _DropdownMuliAddingDialogState();
}

class _DropdownMuliAddingDialogState extends State<DropdownMuliAddingDialog> {
  TextEditingController txtSearch = TextEditingController();
  TextStyle defaultButtonStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  List<int> shownIndexes = [];

  _DropdownMuliAddingDialogState();

  void _updateShownIndexes(String keyword) {
    setState(() {
      shownIndexes = widget.searchFn(keyword, widget.items);
    });
  }

  void update() {
    setState(() {
    });
  }

  @override
  void initState() {
    _updateShownIndexes('');
    widget.searchableDropdownController.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    widget.searchableDropdownController.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 300),
      child: Card(
        color: widget.menuBackgroundColor,
        margin: EdgeInsets.symmetric(
            vertical: widget.dialogBox ? 10 : 5,
            horizontal: widget.dialogBox ? 10 : 4),
        child: Container(
          constraints: widget.menuConstraints,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              titleBar(),
              searchBar(),
              searchResults(),
              closeButtonWrapper(),
            ],
          ),
        ),
      ),
    );
  }

  bool get valid {
    if (widget.validator == null) {
      return (true);
    }
    return (widget
            .validator(widget.searchableDropdownController.selectedIndexes) ==
        null);
  }

  Widget titleBar() {
    var validatorOutput;
    if (widget.validator != null) {
      validatorOutput =
          widget.validator(widget.searchableDropdownController.selectedIndexes);
    }

    Widget validatorOutputWidget = valid
        ? SizedBox.shrink()
        : validatorOutput is String
            ? Text(
                validatorOutput,
                style: TextStyle(color: Colors.red, fontSize: 13),
              )
            : null;

    Widget doneButtonWidget = widget.doneButton != null
        ? prepareWidget(widget.doneButton,
            parameter: widget.searchableDropdownController.selectedIndexes,
            context: context, stringToWidgetFunction: (String string) {
            return (FlatButton.icon(
                onPressed: !valid
                    ? null
                    : () {
                        pop();
                      },
                icon: Icon(Icons.close),
                label: Text(string)));
          })
        : SizedBox.shrink();
    return widget.hint != null
        ? Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                prepareWidget(widget.hint),
                Column(
                  children: <Widget>[doneButtonWidget, validatorOutputWidget],
                ),
              ],
            ),
          )
        : Container(
            child: Column(
              children: <Widget>[doneButtonWidget, validatorOutputWidget],
            ),
          );
  }

  Widget searchBar() {
    return Container(
      child: Stack(
        children: <Widget>[
          TextField(
            controller: txtSearch,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            autofocus: true,
            onChanged: (value) {
              _updateShownIndexes(value);
            },
            keyboardType: widget.keyboardType,
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.search,
                size: 24,
              ),
            ),
          ),
          txtSearch.text.isNotEmpty
              ? Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        txtSearch.clear();
                        _updateShownIndexes(txtSearch.text);
                      },
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: Container(
                        width: 32,
                        height: 32,
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void pop() {
    if (widget.dialogBox) {
      Navigator.pop(context);
    } else {
      widget.displayMenu.value = false;
    }
  }

  Widget searchResults() {
    if (shownIndexes.isEmpty && txtSearch.text.isNotEmpty) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.add),
          title: Text("Add tag"),
          onTap: () {
            widget.items.add(widget.dropdownItemBuilder(txtSearch.text));
            widget.searchableDropdownController.addItemLabel(txtSearch.text);
            widget.searchableDropdownController
                .selectItem(widget.items.length - 1);
            txtSearch.clear();
            _updateShownIndexes(txtSearch.text);
          },
        ),
      );
    }
    return Expanded(
      child: Scrollbar(
        child: ListView.builder(
          itemBuilder: (context, index) {
            DropdownMenuItem<String> item = widget.items[shownIndexes[index]];
            return InkWell(
              onTap: () {
                if (widget.searchableDropdownController
                    .isItemSelected(shownIndexes[index])) {
                  widget.searchableDropdownController
                      .unselectItem(shownIndexes[index]);
                } else {
                  widget.searchableDropdownController
                      .selectItem(shownIndexes[index]);
                }
              },
              child: widget.displayItem == null
                  ? (Row(children: [
                      Icon(
                        widget.searchableDropdownController
                                .isItemSelected(shownIndexes[index])
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Flexible(child: item),
                    ]))
                  : widget.displayItem(
                      item,
                      widget.searchableDropdownController
                          .isItemSelected(shownIndexes[index])),
            );
          },
          itemCount: shownIndexes.length,
        ),
      ),
    );
  }

  Widget closeButtonWrapper() {
    return (prepareWidget(widget.closeButton,
            parameter: widget.searchableDropdownController.selectedIndexes,
            stringToWidgetFunction: (String string) {
          return (Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    pop();
                  },
                  child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 2),
                      child: Text(
                        string,
                        style: defaultButtonStyle,
                        overflow: TextOverflow.ellipsis,
                      )),
                )
              ],
            ),
          ));
        }) ??
        SizedBox.shrink());
  }
}
