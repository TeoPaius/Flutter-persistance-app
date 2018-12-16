import 'package:flutter/material.dart';

class DialogExample extends StatefulWidget {

  @override
  _DialogExampleState createState() => new _DialogExampleState();
}

class _DialogExampleState extends State<DialogExample> {
  String _text = "initial";
  TextEditingController _c;
  @override
  initState(){
    _c = new TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(_text),
              new RaisedButton(onPressed: () {
                showDialog(child: new Dialog(
                  child: new Column(
                    children: <Widget>[
                      new TextField(
                        decoration: new InputDecoration(hintText: "Update Info"),
                        controller: _c,

                      ),
                      new FlatButton(
                        child: new Text("Save"),
                        onPressed: (){
                          setState((){
                            this._text = _c.text;
                          });
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),

                ), context: context);
              },child: new Text("Show Dialog"),)
            ],
          )
      ),
    );
  }
}