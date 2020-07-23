import 'package:flutter/material.dart';

class PointerThisPlease<T> {
  T value;
  PointerThisPlease(this.value);
}

class NotGiven {
  const NotGiven();
}

Widget prepareWidget(dynamic object,
    {dynamic parameter = const NotGiven(),
    BuildContext context,
    Function stringToWidgetFunction}) {
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
    if (parameter is NotGiven) {
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

class DropdownDialog<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final Widget hint;
  final bool isCaseSensitiveSearch;
  final dynamic closeButton;
  final TextInputType keyboardType;
  final Function searchFn;
  final bool multipleSelection;
  final List<int> selectedItems;
  final Function displayItem;
  final dynamic doneButton;
  final Function validator;
  final bool dialogBox;
  final PointerThisPlease<bool> displayMenu;
  final BoxConstraints menuConstraints;
  final Function callOnPop;
  final Color menuBackgroundColor;

  DropdownDialog({
    Key key,
    this.items,
    this.hint,
    this.isCaseSensitiveSearch = false,
    this.closeButton,
    this.keyboardType,
    this.searchFn,
    this.multipleSelection,
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
  _DropdownDialogState<T> createState() => _DropdownDialogState<T>();
}

class _DropdownDialogState<T> extends State<DropdownDialog> {
  TextEditingController txtSearch = TextEditingController();
  TextStyle defaultButtonStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );
  List<int> shownIndexes = [];
  Function searchFn;

  _DropdownDialogState();

  dynamic get selectedResult {
    return (widget.multipleSelection
        ? widget.selectedItems
        : widget.selectedItems?.isNotEmpty ?? false
            ? widget.items[widget.selectedItems.first]?.value
            : null);
  }

  void _updateShownIndexes(String keyword) {
    shownIndexes = searchFn(keyword, widget.items);
  }

  @override
  void initState() {
    if (widget.searchFn != null) {
      searchFn = widget.searchFn;
    } else {
      Function matchFn;
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
            : validatorOutput;

    Widget doneButtonWidget =
        widget.multipleSelection || widget.doneButton != null
            ? prepareWidget(widget.doneButton,
                parameter: selectedResult,
                context: context, stringToWidgetFunction: (string) {
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
        ? Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  prepareWidget(widget.hint),
                  Column(
                    children: <Widget>[
                      doneButtonWidget,
                      validatorOutputWidget,
                    ],
                  ),
                ]),
          )
        : Container(
            child: Column(
              children: <Widget>[
                doneButtonWidget,
                validatorOutputWidget,
              ],
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
              setState(() {});
            },
            keyboardType: widget.keyboardType,
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(Icons.search, size: 24.0),
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
                        _updateShownIndexes('');
                        setState(() {
                          txtSearch.text = '';
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: Container(
                        width: 32,
                        height: 32,
                        child: Center(
                          child: Icon(Icons.close, size: 24.0),
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
      if (widget.callOnPop != null) {
        widget.callOnPop();
      }
    }
  }

  Widget list() {
    return Expanded(
      child: Scrollbar(
        child: ListView.builder(
          itemBuilder: (context, index) {
            DropdownMenuItem item = widget.items[shownIndexes[index]];
            return InkWell(
              onTap: () {
                if (widget.multipleSelection) {
                  setState(() {
                    if (widget.selectedItems.contains(shownIndexes[index])) {
                      widget.selectedItems.remove(shownIndexes[index]);
                    } else {
                      widget.selectedItems.add(shownIndexes[index]);
                    }
                  });
                } else {
                  widget.selectedItems.clear();
                  widget.selectedItems.add(shownIndexes[index]);
                  if (widget.doneButton == null) {
                    pop();
                  } else {
                    setState(() {});
                  }
                }
              },
              child: widget.multipleSelection
                  ? widget.displayItem == null
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
                      : widget.displayItem(item,
                          widget.selectedItems.contains(shownIndexes[index]))
                  : widget.displayItem == null
                      ? item
                      : widget.displayItem(item, item.value == selectedResult),
            );
          },
          itemCount: shownIndexes.length,
        ),
      ),
    );
  }

  Widget closeButtonWrapper() {
    return (prepareWidget(widget.closeButton, parameter: selectedResult,
            stringToWidgetFunction: (string) {
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
