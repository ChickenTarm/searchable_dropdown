import 'package:flutter/material.dart';
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

class DropdownMuliAddingDialog<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final Widget hint;
  final bool isCaseSensitiveSearch;
  final dynamic closeButton;
  final TextInputType keyboardType;
  final List<int> Function(String, dynamic) searchFn;
  final List<int> selectedItems;
  final Widget Function(DropdownMenuItem, bool) displayItem;
  final dynamic doneButton;
  final String Function(List<int>) validator;
  final bool dialogBox;
  final PointerThisPlease<bool> displayMenu;
  final BoxConstraints menuConstraints;
  final Function callOnPop;
  final Color menuBackgroundColor;

  DropdownMuliAddingDialog({
    Key key,
    this.items,
    this.hint,
    this.isCaseSensitiveSearch = false,
    this.closeButton,
    this.keyboardType,
    this.searchFn,
    this.selectedItems,
    this.displayItem,
    this.doneButton,
    this.validator,
    this.dialogBox,
    this.displayMenu,
    this.menuConstraints,
    this.callOnPop,
    this.menuBackgroundColor,
  })  : assert(items != null),
        super(key: key);

  @override
  _DropdownMuliAddingDialogState<T> createState() =>
      new _DropdownMuliAddingDialogState<T>();
}

class _DropdownMuliAddingDialogState<T>
    extends State<DropdownMuliAddingDialog> {
  TextEditingController txtSearch = new TextEditingController();
  TextStyle defaultButtonStyle =
      new TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  List<int> shownIndexes = [];
  List<int> Function(String, dynamic) searchFn;

  _DropdownMuliAddingDialogState();

  List<int> get selectedResult {
    return widget.selectedItems;
  }

  void _updateShownIndexes(String keyword) {
    shownIndexes = searchFn(keyword, widget.items);
  }

  @override
  void initState() {
    if (widget.searchFn != null) {
      searchFn = widget.searchFn;
    } else {
      bool Function(dynamic, String) matchFn;
      if (widget.isCaseSensitiveSearch) {
        matchFn = (item, keyword) {
          return (item.value.toString().contains(keyword));
        };
      } else {
        matchFn = (item, keyword) {
          return (item.value
              .toString()
              .toLowerCase()
              .contains(keyword.toLowerCase()));
        };
      }
      searchFn = (keyword, items) {
        List<int> shownIndexes = [];
        int i = 0;
        widget.items.forEach((item) {
          if (matchFn(item, keyword) || (keyword?.isEmpty ?? true)) {
            shownIndexes.add(i);
          }
          i++;
        });
        return (shownIndexes);
      };
    }
    assert(searchFn != null);
    _updateShownIndexes('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 300),
      child: new Card(
        color: widget.menuBackgroundColor,
        margin: EdgeInsets.symmetric(
            vertical: widget.dialogBox ? 10 : 5,
            horizontal: widget.dialogBox ? 10 : 4),
        child: new Container(
          constraints: widget.menuConstraints,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              titleBar(),
              searchBar(),
              list(),
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
    return (widget.validator(selectedResult) == null);
  }

  Widget titleBar() {
    var validatorOutput;
    if (widget.validator != null) {
      validatorOutput = widget.validator(selectedResult);
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
            parameter: selectedResult,
            context: context, stringToWidgetFunction: (String string) {
            return (FlatButton.icon(
                onPressed: !valid
                    ? null
                    : () {
                        pop();
                        setState(() {});
                      },
                icon: Icon(Icons.close),
                label: Text(string)));
          })
        : SizedBox.shrink();
    return widget.hint != null
        ? new Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  prepareWidget(widget.hint),
                  Column(
                    children: <Widget>[doneButtonWidget, validatorOutputWidget],
                  ),
                ]),
          )
        : new Container(
            child: Column(
              children: <Widget>[doneButtonWidget, validatorOutputWidget],
            ),
          );
  }

  Widget searchBar() {
    return new Container(
      child: new Stack(
        children: <Widget>[
          new TextField(
            controller: txtSearch,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            autofocus: true,
            onChanged: (value) {
              _updateShownIndexes(value);
              setState(() {});
            },
            keyboardType: widget.keyboardType,
          ),
          new Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: new Center(
              child: new Icon(
                Icons.search,
                size: 24,
              ),
            ),
          ),
          txtSearch.text.isNotEmpty
              ? new Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: new Center(
                    child: new InkWell(
                      onTap: () {
                        _updateShownIndexes('');
                        setState(() {
                          txtSearch.text = '';
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: new Container(
                        width: 32,
                        height: 32,
                        child: new Center(
                          child: new Icon(
                            Icons.close,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : new Container(),
        ],
      ),
    );
  }

  void pop() {
    if (widget.dialogBox) {
      Navigator.pop(context);
    } else {
      widget.displayMenu.value = false;
      if (widget.callOnPop != null) {
        widget.callOnPop();
      }
    }
  }

  Widget list() {
    return new Expanded(
      child: Scrollbar(
        child: new ListView.builder(
          itemBuilder: (context, index) {
            DropdownMenuItem item = widget.items[shownIndexes[index]];
            return new InkWell(
              onTap: () {
                setState(() {
                  if (widget.selectedItems.contains(shownIndexes[index])) {
                    widget.selectedItems.remove(shownIndexes[index]);
                  } else {
                    widget.selectedItems.add(shownIndexes[index]);
                  }
                });
              },
              child: widget.displayItem == null
                  ? (Row(children: [
                      Icon(
                        widget.selectedItems.contains(shownIndexes[index])
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Flexible(child: item),
                    ]))
                  : widget.displayItem(
                      item, widget.selectedItems.contains(shownIndexes[index])),
            );
          },
          itemCount: shownIndexes.length,
        ),
      ),
    );
  }

  Widget closeButtonWrapper() {
    return (prepareWidget(widget.closeButton, parameter: selectedResult,
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
