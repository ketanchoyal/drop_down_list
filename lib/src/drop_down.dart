import 'package:flutter/material.dart';

class DropDown<T extends SearchableItem> {
  /// This gives the button text or it sets default text as 'click me'.
  final String? buttonText;

  /// This gives the bottom sheet title.
  final String? bottomSheetTitle;

  /// This will give the submit button text.
  final String? submitButtonText;

  /// This will give the submit button background color.
  final Color? submitButtonColor;

  /// This will give the hint to the search text filed.
  final String? searchHintText;

  /// This will give the background color to the search text filed.
  final Color? searchBackgroundColor;

  /// This will give the default search controller to the search text field.
  final TextEditingController searchController;

  /// This will give the call back to the selected items (multiple) from list.
  final Function(List<T>)? selectedItems;

  /// This will give the call back to the selected item (single) from list.
  final Function(T)? selectedItemValue;

  /// This will give selection choise for single or multiple for list.
  final bool enableMultipleSelection;

  final void Function(BuildContext context, int index)? listItemBuildListener;

  final Stream<List<SelectedListItem<T>>> stream;

  DropDown({
    Key? key,
    this.buttonText,
    this.bottomSheetTitle,
    this.submitButtonText,
    this.submitButtonColor,
    this.searchHintText,
    this.searchBackgroundColor,
    required this.searchController,
    this.selectedItems,
    this.selectedItemValue,
    required this.enableMultipleSelection,
    this.listItemBuildListener,
    required this.stream,
  });
}

class DropDownState<T extends SearchableItem> {
  DropDown<T> dropDown;
  DropDownState(this.dropDown);

  /// This gives the bottom sheet widget.
  void showModal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MainBody<T>(
              dropDown: dropDown,
            );
          },
        );
      },
    );
  }
}

abstract class SearchableItem {
  List<String> get searchableStrings;
}

/// This is Model class. Using this model class, you can add the list of data with title and its selection.
class SelectedListItem<T extends SearchableItem> {
  bool isSelected;
  final String name;
  final String id;
  final T value;
  final Function(T)? onTap;

  SelectedListItem(this.isSelected, this.name, this.id,
      {required this.value, this.onTap});
}

/// This is main class to display the bottom sheet body.
class MainBody<T extends SearchableItem> extends StatefulWidget {
  final DropDown<T> dropDown;

  const MainBody({required this.dropDown, Key? key}) : super(key: key);

  @override
  State<MainBody> createState() => _MainBodyState<T>();
}

class _MainBodyState<T extends SearchableItem> extends State<MainBody<T>> {
  /// This list will set when the list of data is not available.
  List<SelectedListItem<T>> mainList = [];
  String _searchString = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.13,
      maxChildSize: 0.9,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Bottom sheet title text
                  Text(
                    widget.dropDown.bottomSheetTitle ?? 'Title',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  Expanded(
                    child: Container(),
                  ),

                  /// Done button
                  Visibility(
                    visible: widget.dropDown.enableMultipleSelection,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                          onPressed: () {
                            List<SelectedListItem<T>> selectedList = mainList
                                .where((element) => element.isSelected == true)
                                .toList();
                            List<T> selectedItems = [];

                            for (var element in selectedList) {
                              selectedItems.add(element.value);
                            }

                            widget.dropDown.selectedItems?.call(selectedItems);
                            _onUnfocusKeyboardAndPop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                widget.dropDown.submitButtonColor ??
                                    Colors.blue,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child:
                              Text(widget.dropDown.submitButtonText ?? 'Done')),
                    ),
                  ),
                ],
              ),
            ),

            /// A [TextField] that displays a list of suggestions as the user types with clear button.
            _AppTextField(
              dropDown: widget.dropDown,
              onTextChanged: _buildSearchList,
              onClearTap: _onClearTap,
            ),

            /// Listview (list of data with check box for multiple selection & on tile tap single selection)
            Expanded(
              child: StreamBuilder<List<SelectedListItem<T>>>(
                  stream: widget.dropDown.stream,
                  builder: (context, snapshot) {
                    final mainList = snapshot.data ?? [];
                    this.mainList.clear();
                    this.mainList.addAll(mainList);
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: mainList.length,
                      itemBuilder: (context, index) {
                        if (widget.dropDown.listItemBuildListener != null) {
                          widget.dropDown.listItemBuildListener!(
                              context, index);
                        }
                        if (!mainList[index]
                            .value
                            .searchableStrings
                            .join(' ')
                            .toLowerCase()
                            .contains(_searchString.toLowerCase())) {
                          return const SizedBox(
                            height: 0.0,
                            width: 0.0,
                          );
                        }
                        return InkWell(
                          child: Container(
                            // color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: ListTile(
                                title: Text(
                                  mainList[index].name,
                                ),
                                trailing: widget
                                        .dropDown.enableMultipleSelection
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            mainList[index].isSelected =
                                                !mainList[index].isSelected;
                                          });
                                        },
                                        child: mainList[index].isSelected
                                            ? const Icon(Icons.check_box)
                                            : const Icon(
                                                Icons.check_box_outline_blank),
                                      )
                                    : const SizedBox(
                                        height: 0.0,
                                        width: 0.0,
                                      ),
                              ),
                            ),
                          ),
                          onTap: widget.dropDown.enableMultipleSelection
                              ? null
                              : () {
                                  // widget.dropDown.selectedItem
                                  //     ?.call(
                                  //   (mainList[index].name)
                                  // );
                                  widget.dropDown.selectedItemValue
                                      ?.call((mainList[index].value));
                                  _onUnfocusKeyboardAndPop();
                                },
                        );
                      },
                    );
                  }),
            ),
          ],
        );
      },
    );
  }

  /// This helps when search enabled & show the filtered data in list.
  _buildSearchList(String userSearchTerm) {
    _searchString = userSearchTerm;
    setState(() {});
  }

  /// This helps when want to clear text in search text field.
  void _onClearTap() {
    widget.dropDown.searchController.clear();
    _searchString = '';
    setState(() {});
  }

  /// This helps to unfocus the keyboard & pop from the bottom sheet.
  _onUnfocusKeyboardAndPop() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }
}

/// This is search text field class.
class _AppTextField extends StatefulWidget {
  final DropDown dropDown;
  final Function(String) onTextChanged;
  final VoidCallback onClearTap;

  const _AppTextField(
      {required this.dropDown,
      required this.onTextChanged,
      required this.onClearTap,
      Key? key})
      : super(key: key);

  @override
  State<_AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<_AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        controller: widget.dropDown.searchController,
        cursorColor: Colors.black,
        onChanged: (value) {
          widget.onTextChanged(value);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.dropDown.searchBackgroundColor ?? Colors.black12,
          contentPadding:
              const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 15),
          hintText: widget.dropDown.searchHintText ?? 'Search',
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          prefixIcon: const IconButton(
            icon: Icon(Icons.search),
            onPressed: null,
          ),
          suffixIcon: GestureDetector(
            onTap: widget.onClearTap,
            child: const Icon(
              Icons.cancel,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
