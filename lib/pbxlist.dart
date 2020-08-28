import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fetchbalance.dart';

class PbxCallsList extends StatefulWidget {
  final String text;

  PbxCallsList({Key key, @required this.text}) : super(key: key);

  @override
  _PbxCallsListState createState() => _PbxCallsListState();
}

class _PbxCallsListState extends State<PbxCallsList> {
  String _head = "";
  var _callsList;

  @override
  void initState() {
    super.initState();
    print("aaaaaaaaaaaaaaaaaaaa: ${widget.text}");
    getJSStringParam("/v1/statistics/pbx/", widget.text).then((value) {
      print(value);
      var b = json.decode(value);
      if (b['status'] == 'success') {
        _head = "start: ${b['start']} end: ${b['end']}";
        _callsList = b['stats'];
        print("+callList.length: ${_callsList.length}");
      } else
        _head = "Error: ${b['message']}";
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List of PBX Calls (${ _callsList == null ? 0 : _callsList.length})"),
      ),
      body: Container(
        child: Column(
          children: [
            Dismissible(
              key: UniqueKey(),
              child: Text(_head),
            ),
            Expanded(
                child: ListView.separated(
              itemCount: _callsList == null ? 0 : _callsList.length,
              itemBuilder: (BuildContext context, int i) {
                Color _dispC;
                Color _isRecorded;
                switch (_callsList[i]['is_recorded']) {
                  case 'true':
                    {
                      _isRecorded = Colors.greenAccent;
                    }
                    break;
                  default:
                    {
                      _isRecorded = Colors.white;
                    }
                    break;
                }
                switch (_callsList[i]['disposition']) {
                  case 'answered':
                    {
                      _dispC = Colors.lightGreenAccent;
                    }
                    break;
                  case 'no answer':
                    {
                      _dispC = Colors.purpleAccent;
                    }
                    break;
                  case 'failed':
                    {
                      _dispC = Colors.redAccent;
                    }
                    break;
                  case 'busy':
                    {
                      _dispC = Colors.pinkAccent;
                    }
                    break;
                  default:
                    {
                      _dispC = Colors.white;
                    }
                    break;
                }
                return Container(
                  padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_callsList[i]['callstart']),
                          //SizedBox(width: 10,),
                          _callsList[i]['is_recorded'] == 'true'
                              ? InkWell(
                                  child: Text("${_callsList[i]['seconds'] ~/ 60}:${NumberFormat("00").format(_callsList[i]['seconds'] % 60)}",
                                    //_callsList[i]['seconds'].toString(),
                                    style: TextStyle(backgroundColor: _isRecorded),
                                  ),
                                  onTap: () async {
                                    String _jsstr = await getJSStringParam("/v1/pbx/record/request/", "call_id=${_callsList[i]['call_id']}");
                                    String _mp3Url = json.decode(_jsstr)['link'];
                                    if (await canLaunch(_mp3Url)) {
                                      await launch(_mp3Url);
                                    } else {
                                      throw 'Could not launch $_mp3Url';
                                    }
                                    return;
                                    /*return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SimpleDialog(children: [
                                          Text(
                                            //_callsList[i]['call_id'],
                                            _mp3Url
                                          ), //style: TextStyle(fontSize: 14),),
                                        ]);
                                      },
                                    );*/
                                  })
                              : Text("${_callsList[i]['seconds'] ~/ 60}:${NumberFormat("00").format(_callsList[i]['seconds'] % 60)}",
                                  style: TextStyle(backgroundColor: _isRecorded),
                                ),
                        ],
                      ),
                      InkWell(
                        onTap: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => SimpleDialog(
                              //title: Text("dial title"),
                              children: [
                                Text(JsonEncoder.withIndent("        ").convert(_callsList[i])),
                              ],
                            )),
                        child: Row(
                          children: [
                            Text("From: " + _callsList[i]['sip']),
                            SizedBox(
                              width: 10,
                            ),
                            _callsList[i]['sip']!=_callsList[i]['clid']?Text("(" + _callsList[i]['clid'] + ")"):SizedBox(),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text("To:"),
                          SizedBox(width: 20,),
                          Text(
                            _callsList[i]['destination'].toString(),
                            style: TextStyle(backgroundColor: _dispC),
                          ),
                        ],
                      ),
                      //Text(JsonEncoder.withIndent("       ").convert(_callsList[i])),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 2,
                thickness: 2,
                color: Colors.orange,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
