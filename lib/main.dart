
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lab/run.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';

class AnimatedListSample extends StatefulWidget {
  @override
  _AnimatedListSampleState createState() => _AnimatedListSampleState();
}


Future<bool> sync()  async
{

  checkNet().then((ret) async{
    if(ret)
    {
      for(Run r in _AnimatedListSampleState._list._items)
        {
          if(r.id == "") {
            final response =
            await http.post('http://192.168.43.94:1337/runs/',
                headers: {'Content-Type': 'application/json'},
                body: json.encode(r),
                encoding: Encoding.getByName('utf-8'));

            if (response.statusCode == 200) {
              Run ret = Run.fromJson(json.decode(response.body));
              r.id = ret.id;
              _AnimatedListSampleState.saveToPreferences();
            } else {
              // If that response was not OK, throw an error.
              throw Exception('Failed to load runs');
            }
          }
      }
    }
  });
}

Future<bool> deleteRun(String id) async {
  sync();
  final response =
  await http.delete('http://192.168.43.94:1337/runs/' + id);

  if (response.statusCode == 200) {

    _AnimatedListSampleState.saveToPreferences();

  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load runs');
  }
}

Future<bool> fetchAllRuns() async {
  sync();
  final response =
  await http.get('http://192.168.43.94:1337/runs');

  if (response.statusCode == 200) {

    // If server returns an OK response, parse the JSON
    for(Map<String,dynamic> m in json.decode(response.body))
    {
      Run r = Run.fromJson(m);
      _AnimatedListSampleState._list.insert(_AnimatedListSampleState._list.length, r);

    }
    _AnimatedListSampleState.saveToPreferences();

  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load runs');
  }
}

Future<bool> updateRun(Run r) async
{
  sync();
  checkNet().then((ret)async {
    if (ret) {

      final response =
      await http.put('http://192.168.43.94:1337/runs/' + r.id, headers: {'Content-Type': 'application/json'},
          body: json.encode(r),
          encoding: Encoding.getByName('utf-8'));

      if (response.statusCode == 200) {
        _AnimatedListSampleState.saveToPreferences();
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load runs');
      }
    }
    else {
      Fluttertoast.showToast(
          msg: "NO NET",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          bgcolor: "#e74c3c",
          textcolor: '#ffffff'
      );
    }
  });
}

Future<bool> createRun(Run r, int index) async
{
  sync();
  checkNet().then((ret) async{
    if(ret)
      {

        final response =
        await http.post('http://192.168.43.94:1337/runs/', headers: {'Content-Type': 'application/json'},
            body: json.encode(r),
            encoding: Encoding.getByName('utf-8'));

        if (response.statusCode == 200) {
          Run ret = Run.fromJson(json.decode(response.body));
          _AnimatedListSampleState._list.insert(index, ret);
          _AnimatedListSampleState.saveToPreferences();
        } else {
          // If that response was not OK, throw an error.
          throw Exception('Failed to load runs');
        }
      }else
        {
          _AnimatedListSampleState._list.insert(index, r);
        }
  });

}




class _AnimatedListSampleState extends State<AnimatedListSample> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  static ListModel<Run> _list;
  Run _selectedItem;
  Run _nextItem; // The next item inserted when the user presses the '+' button.

  @override
  void initState() {
    super.initState();
    _list = ListModel<Run>(
      listKey: _listKey,
      //initialItems: <Run>[new Run(1,"a", 1.0), new Run(2,"b", 2.0), new Run(2,"b", 2.0)],
      removedItemBuilder: _buildRemovedItem,
    );


    Future<bool> net  = checkNet();
    net.then((ret){
      if(ret == true)
        {
          fetchAllRuns().then((el) {});
        }
        else
          {

            getFromPreferences();
          }
    });



    _nextItem = new Run(1, "2018-11-05T22:00:00.000Z", 1);
    _nextItem.id = "";
  }

  static void  getFromPreferences() async
  {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String listJson = prefs.get('list');
      for(Map<String,dynamic> m in json.decode(listJson))
      {
        Run r = Run.fromJson(m);
        _list.insert(_list.length, r);
      }

  }

  static void  saveToPreferences() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String listJson = json.encode(_list._items);
    prefs.setString('list', listJson);
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  Widget _buildRemovedItem(
      Run item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: item,
      selected: false,
      // No gesture detector here: we don't want removed items to be interactive.
    );
  }

  // Insert the "next item" into the list model.
  void _insert() {
    final int index =
    _selectedItem == null ? _list.length : _list.indexOf(_selectedItem);
    createRun(_nextItem, index);
    saveToPreferences();

  }

  // Remove the selected item from the list model.
  void _remove() {
    checkNet().then((ret) {
      if(ret == true)
        {
          if (_selectedItem != null) {
            deleteRun(_selectedItem.id);
            _list.removeAt(_list.indexOf(_selectedItem));
            setState(() {
              _selectedItem = null;
            });
          }

          saveToPreferences();
        }
        else
          {
            Fluttertoast.showToast(
                msg: "NO NET",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                bgcolor: "#e74c3c",
                textcolor: '#ffffff'
            );
          }
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AnimatedList'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _insert,
              tooltip: 'insert a new item',
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: _remove,
              tooltip: 'remove the selected item',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _list.length,
            itemBuilder: _buildItem,
          ),
        ),
      ),
    );
  }
}

class ListModel<E> {
  ListModel({
    @required this.listKey,
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  })  : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(index,
              (BuildContext context, Animation<double> animation) {
            return removedItemBuilder(removedItem, context, animation);
          });
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

class CardItem extends StatelessWidget {
  const CardItem(
      {Key key,
        @required this.animation,
        this.onTap,
        @required this.item,
        this.selected: false})
      : assert(animation != null),
        assert(item != null),
        assert(selected != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final Run item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.display1;
    if (selected)
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 128.0,

            child: Card(
              //color: Colors.primaries[item % Colors.primaries.length],
              child: Center(
                child: Row(
                  children: <Widget>[
                    new Flexible(
                    child:
                      new TextField(
                        controller: new TextEditingController(text: item.length.toString()),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Title',
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          item.length = int.parse(value);
                          updateRun(item);
                          _AnimatedListSampleState.saveToPreferences();
                        },
                        style: new TextStyle(
                          fontSize: 30.0,
                          height: 1.0,
                          color: Colors.black,
                        ),
                        //textAlign: TextAlign.center,
                      ),
                    ),
                    new Flexible(
                      child:
                      new TextField(
                        controller: new TextEditingController(text: item.date.toString()),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Title',
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          item.date = value;
                          updateRun(item);
                          _AnimatedListSampleState.saveToPreferences();
                        },
                        style: new TextStyle(
                          fontSize: 30.0,
                          height: 2.0,
                          color: Colors.black,
                        ),
                        //textAlign: TextAlign.center,
                      ),
                    ),
                    new Flexible(
                      child:
                      new TextField(
                        controller: new TextEditingController(text: item.duration.toString()),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Title',
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          item.duration = int.parse(value);
                          updateRun(item);
                          _AnimatedListSampleState.saveToPreferences();
                        },
                        style: new TextStyle(
                          fontSize: 30.0,
                          height: 2.0,
                          color: Colors.black,
                        ),
                        //textAlign: TextAlign.center,
                      ),
                    ),
                  ]
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> checkNet() async
{
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      log("has net");
      return true;
    }
  } on SocketException catch (_) {
    log(_.toString());
    return false;
  }
}


void main() {
  runApp(AnimatedListSample());
}