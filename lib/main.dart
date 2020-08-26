import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

Future<Balance> fetchBalance(String key, String sec) async {
  var bsec = utf8.encode(sec);
  var hmac = Hmac(sha1, bsec);
  var md = md5.convert(utf8.encode(""));
  var dgist = hmac.convert(utf8.encode("/v1/info/balance$md"));
  var b64dgist = base64.encode(utf8.encode(dgist.toString()));
  print("Digest as bytes: ${dgist.bytes}");
  print("Digest as hex string: $dgist");
  print("Base64: $b64dgist");

//  final response = await http.get("https://api.zadarma.com/v1/info/balance",
//      headers: {"Authorization": "$key:$b64dgist",})
//      .timeout(const Duration(seconds: 15));
//
//    print("statusCode: ${response.statusCode}");
  //headers: ${response.headers}");
//    var bod=Utf8Decoder().convert(response.bodyBytes);
//    print("body: $bod");
//    print("request: ${response.request}");
//    print("contentLength: ${response.contentLength}");

//  Dio dio = Dio(BaseOptions(
//    baseUrl: "https://api.zadarma.com",
//    method: "/v1/info/balance",
//    connectTimeout: 15000,
//    receiveTimeout: 15000,
//    sendTimeout: 15000,
//    headers: {"Authorization": "$key:$b64dgist",},
//  ));
//
//  var response = await dio.get("https://api.zadarma.com/v1/info/balance");

  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient
      .getUrl(Uri.parse("https://api.zadarma.com/v1/info/balance"))
      .timeout(const Duration(seconds: 15));

  request.headers
      .add("Authorization", "$key:$b64dgist", preserveHeaderCase: true);
  HttpClientResponse response =
      await request.close().timeout(const Duration(seconds: 15));
  //print("@@@@length@@@ ${response.length}");

  String reply = await response.transform(utf8.decoder).join();
  print(reply);
  httpClient.close();

  print("@@@headers@@@@ ${response.headers}");
  print("@@@statusCode@@@@ ${response.statusCode}");
  print("@@@@reasonPhrase@@@ ${response.reasonPhrase}");
  print("@@@@reply@@@ $reply");
  //print("@@@body@@@@ ${Utf8Codec().decode(response.bodyBytes)}");

  if (response.statusCode == 200) {
    //return Balance.fromJson(jsonDecode(response.data));
    //return Balance.fromJson(jsonDecode(Utf8Codec().decode(response.bodyBytes)));
    return Balance.fromJson(jsonDecode(reply));
  } else {
    //print("^^^^^^^^^^^^^^^^    ${response.request}");
    //print("tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ${response.statusMessage}");
    // print("Authorization: $key:$b64dgist");

    //return Balance.fromJson(jsonDecode(response.data));
    //return Balance.fromJson(jsonDecode(Utf8Codec().decode(response.bodyBytes)));
    return Balance.fromJson(jsonDecode(reply));

    //throw Exception('Failed to load Balance');
  }
}

class Balance {
  String status;
  double balance;
  String currency;
  String message;

  Balance(
      {this.status,
      this.balance = -1.01,
      this.currency = "",
      this.message = ""});

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
        status: json['status'],
        balance: 0.0 + (json['balance'] ?? 0),
        currency: json['currency'],
        message: json['message']);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _balance = "";
  String _timeZone = "";

  Future<String> getJSString(String method) async {
    print("^^^^^^^^^^^ $method ^^^");
    var bsec = utf8.encode(_mySec);
    var hmac = Hmac(sha1, bsec);
    var md = md5.convert(utf8.encode(""));
    var dgist = hmac.convert(utf8.encode("$method$md"));
    var b64dgist = base64.encode(utf8.encode(dgist.toString()));
    print("_ Digest as bytes: ${dgist.bytes}");
    print("_ Digest as hex string: $dgist");
    print("_ Base64: $b64dgist");

    HttpClient httpClient = new HttpClient();
    httpClient.connectionTimeout = const Duration(seconds: 15);
    httpClient.idleTimeout = const Duration(seconds: 15);
    HttpClientRequest request = await httpClient
        .getUrl(Uri.parse("https://api.zadarma.com$method"))
        .timeout(const Duration(seconds: 15));

    request.headers
        .add("Authorization", "$_myKey:$b64dgist", preserveHeaderCase: true);
    HttpClientResponse response =
        await request.close().timeout(const Duration(seconds: 15));

    String reply = await response.transform(utf8.decoder).join();
    print(reply);
    httpClient.close();

    print("_ @@@headers@@@@ ${response.headers}");
    print("_ @@@statusCode@@@@ ${response.statusCode}");
    print("_ @@@@reasonPhrase@@@ ${response.reasonPhrase}");
    print("_ @@@@reply@@@ $reply");
    return reply;

    // var b = reply;
    // var jb = json.decode(b);
    // setState(() {
    //   if (jb['status'] == 'success')
    //     _balance = "Balance: ${jb['balance']} ${jb['currency']}";
    //   else
    //     _balance = b;
    // });
  }

  void _getBalanceTh() {
    var bsec = utf8.encode(_mySec);
    var hmac = Hmac(sha1, bsec);
    var md = md5.convert(utf8.encode(""));
    var dgist = hmac.convert(utf8.encode("/v1/info/balance$md"));
    var b64dgist = base64.encode(utf8.encode(dgist.toString()));
    print("_ Digest as bytes: ${dgist.bytes}");
    print("_ Digest as hex string: $dgist");
    print("_ Base64: $b64dgist");

    HttpClient httpClient = new HttpClient();

    httpClient
        .getUrl(Uri.parse("https://api.zadarma.com/v1/info/balance"))
        .timeout(const Duration(seconds: 15))
        .then((request) {
      request.headers
          .add("Authorization", "$_myKey:$b64dgist", preserveHeaderCase: true);
      return request
          .close()
          .timeout(const Duration(seconds: 15))
          .then((response) {
        print("_ @@@headers@@@@ ${response.headers}");
        print("_ @@@statusCode@@@@ ${response.statusCode}");
        print("_ @@@@reasonPhrase@@@ ${response.reasonPhrase}");
        response.transform(utf8.decoder).join().then((v) {
          String b = v;
          httpClient.close();
          print("_ @@@@reply@@@ $b");
          var jb = json.decode(b);
          setState(() {
            if (jb['status'] == 'success')
              _balance = "Balance: ${jb['balance']} ${jb['currency']}";
            else if (jb['status'] == 'error')
              _balance = "Error: ${jb['message']}";
            else
              _balance = b;
          });
        });
      });
    });
  }

  void _getStringJS(String method, String stringToSet) {
    var bsec = utf8.encode(_mySec);
    var hmac = Hmac(sha1, bsec);
    var md = md5.convert(utf8.encode(""));
    var dgist = hmac.convert(utf8.encode("$method$md"));
    var b64dgist = base64.encode(utf8.encode(dgist.toString()));
    print("_ Digest as bytes: ${dgist.bytes}");
    print("_ Digest as hex string: $dgist");
    print("_ Base64: $b64dgist");

    HttpClient httpClient = new HttpClient();

    httpClient
        .getUrl(Uri.parse("https://api.zadarma.com$method"))
        .timeout(const Duration(seconds: 15))
        .then((request) {
      request.headers
          .add("Authorization", "$_myKey:$b64dgist", preserveHeaderCase: true);
      return request
          .close()
          .timeout(const Duration(seconds: 15))
          .then((response) {
        print("_ @@@headers@@@@ ${response.headers}");
        print("_ @@@statusCode@@@@ ${response.statusCode}");
        print("_ @@@@reasonPhrase@@@ ${response.reasonPhrase}");
        response.transform(utf8.decoder).join().then((v) {
          String b = v;
          httpClient.close();
          print("_ @@@@reply@@@ $b");
          setState(() {
            stringToSet = b;
          });
          print("@@ $stringToSet @@");
          print("@@ $_timeTxt @@");
/*          var jb = json.decode(b);
          setState(() {
            if (jb['status'] == 'success')
              _balance = "Balance: ${jb['balance']} ${jb['currency']}";
            else if (jb['status'] == 'error')
              _balance = "Error: ${jb['message']}";
            else
              _balance = b;
          });*/
        });
      });
    });
  }

  final EncryptedSharedPreferences eShPr = EncryptedSharedPreferences();
  String _mySec;
  String _myInd = '';
  String _myKey;

  void getKeyAndSec() {
    eShPr.getString('myInd').then((ind) {
      _myInd = ind;
      print(
          "++++++!!+++-----------------+++++++ myInd: $ind +++++++++++++++-------++++++");
      eShPr.getString('mySec$_myInd').then((String s) {
        print(
            "++++!!+++++----------------+++++++++++ mySec$_myInd $s +++++++++++--------------++++++");
        setState(() => _mySec = s);
        eShPr.getString('myKey$_myInd').then((String s) {
          print(
              "++++!!+++++----------------+++++++++++ myKey$_myInd $s +++++++++++--------------++++++");
          setState(() => _myKey = s);
          _getBalanceTh();
        });
      });
    });
  }

  String _tariffTxt;
  List<Text> _sipJS = [];
  List<Text> _internalJS = [];
  String _timeTxt;

  void _incrementCounter() async {
    var _timeJSb = json.decode(await getJSString("/v1/info/timezone/"));
    if (_timeJSb['status'] == 'success') {
      setState(() {
        _timeTxt = _timeJSb['datetime'] + "     " + _timeJSb['timezone'];
      });
    } else if (_timeJSb['status'] == 'error') {
      setState(() {
        _timeTxt = "Error: ${_timeJSb['message']}";
      });
    }

    _timeJSb = json.decode(await getJSString("/v1/tariff"));
    if (_timeJSb['status'] == 'success') {
      String a;
      if (_timeJSb['info']['is_active'] == 'true') {
        a = "active";
      } else {
        a = "not active";
      }
      _tariffTxt = "Name: ${_timeJSb['info']['tariff_name']} $a";
    } else if (_timeJSb['status'] == 'error')
      setState(() => _tariffTxt = "Error: ${_timeJSb['message']}");
    //_tariffTxt = await getJSString("/v1/tariff/");

    _timeJSb = json.decode(await getJSString("/v1/sip/"));
    if (_timeJSb['status'] == 'success') {
      _sipJS.clear();

      await Future.forEach(_timeJSb['sips'], (sip) async {
        var sipst = json.decode(await getJSString("/v1/sip/${sip['id']}/status/"));
        Color c;
        if (sipst['status'] == 'success' && sipst['is_online'] == 'true')
          c = Colors.greenAccent;
        else
          c = Colors.redAccent;
        _sipJS.add(
            Text(sip['id'] + " " + sip['display_name'],
              style: TextStyle(backgroundColor: c,),
            )
        );
      });

    } else if (_timeJSb['status'] == 'error')
      setState(() => _sipJS.add(Text("Error: ${_timeJSb['message']}")));
    //_sipJS = await getJSString("/v1/sip/");

    _timeJSb = json.decode(await getJSString("/v1/pbx/internal/"));
    _internalJS.clear();
    if (_timeJSb['status'] == 'success') {
      _internalJS.add(Text("pbx_id: ${_timeJSb['pbx_id']}"));
      await Future.forEach(_timeJSb['numbers'], (n)  async {
        var d =
            await json.decode(await getJSString("/v1/pbx/internal/$n/status"));
        var c;
        if (d['is_online'] == 'true')
          c = Colors.lightGreenAccent;
        else
          c = Colors.redAccent;

        _internalJS.add(Text(
          "$n ${d['pbx_id']}",
          style: TextStyle(backgroundColor: c),
        ));
      });
      //_internalJS.sort((a,b) => a.data.compareTo(b.data));
    } else if (_timeJSb['status'] == 'error')
      setState(() => _internalJS.add(Text("Error: ${_timeJSb['message']}")));
    //_internalJS = await getJSString("/v1/pbx/internal/");

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      //futureBalance = fetchBalance(_myKey, _mySec);
    });
  }

  Future<Balance> futureBalance;

  @override
  void initState() {
    super.initState();

    eShPr.getString('myInd').then((ind) {
      _myInd = ind;
      print(
          "+++++++++++-----------------+++++++ myInd: $ind +++++++++++++++-------++++++");
      eShPr.getString('mySec$_myInd').then((String s) {
        print(
            "+++++++++++----------------+++++++++++ mySec$_myInd $s +++++++++++--------------++++++");
        setState(() => _mySec = s);
        eShPr.getString('myKey$_myInd').then((String s) {
          print(
              "+++++++++++----------------+++++++++++ myKey$_myInd $s +++++++++++--------------++++++");
          setState(() => _myKey = s);
          //futureBalance = fetchBalance(_myKey, _mySec);
          if (_myKey == '' || _mySec == '') {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsRoute()))
                .then((value) => getKeyAndSec());
          } else {
            _getBalanceTh();
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: InkWell(
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsRoute()))
                      .then((value) => getKeyAndSec());
                },
                icon: Icon(Icons.more_vert),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          padding: EdgeInsets.all(16.0),
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).

          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Secret $_myInd: $_mySec",
              style: TextStyle(
                fontFamily: 'Monospace',
              ),
            ),
            Text(
              "   Key $_myInd: $_myKey",
              style: TextStyle(
                fontFamily: 'Monospace',
              ),
            ),
            Divider(),
            Text(
              'You have pushed floating button times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Divider(),
            Text(_balance),
            Divider(),
            Text(_timeTxt ?? 'time not set'),
            Divider(),
            Text(_tariffTxt ?? 'time not set'),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _sipJS,
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _internalJS,
            ),
            Divider(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SettingsRoute extends StatefulWidget {
  @override
  _SettingsRouteState createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  final EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences();

  TextEditingController myControllerKey;
  TextEditingController myControllerSec;
  TextEditingController myControllerInd;

  FocusNode mySaveFocus;

  String _myKey;
  String _myInd;
  String _mySec;

  @override
  void initState() {
    super.initState();

    mySaveFocus = FocusNode();
    encryptedSharedPreferences.getString('myInd').then((String _value) {
      setState(() {
        _myInd = _value;
        myControllerInd = TextEditingController(text: _value);
      });
      //myControllerInd.text = _value;
      encryptedSharedPreferences
          .getString('myKey$_myInd')
          .then((String _value) {
        setState(() {
          _myKey = _value;
          myControllerKey = TextEditingController(text: _value);
        });
        encryptedSharedPreferences
            .getString('mySec$_myInd')
            .then((String _value) {
          setState(() {
            _mySec = _value;
            myControllerSec = TextEditingController(text: _value);
          });
        });
      });
    });
  }

  @override
  void dispose() {
    mySaveFocus.dispose();
    myControllerKey.dispose();
    myControllerSec.dispose();
    myControllerInd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Token Key"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                onSubmitted: (s) {
                  setState(() {
                    _myKey = s;
                  });
                  encryptedSharedPreferences.setString('myKey$_myInd', s);
                  FocusScope.of(context).nextFocus();
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.vpn_key),
                  hintText: "Enter Key",
                  helperText: "Enter Key",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                ),
                controller: myControllerKey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onSubmitted: (s) {
                  setState(() {
                    _mySec = s;
                  });
                  encryptedSharedPreferences.setString('mySec$_myInd', s);
                  mySaveFocus.requestFocus();
                  //mySaveFocus.;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.security),
                  hintText: "Enter Secret",
                  helperText: "Enter Secret",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                ),
                controller: myControllerSec,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlineButton(
                  onPressed: () {
                    setState(() {
                      _myInd = myControllerInd.text;
                      encryptedSharedPreferences
                          .getString('myKey$_myInd')
                          .then((String _value) {
                        _myKey = _value;
                        myControllerKey.text = _value;
                        encryptedSharedPreferences
                            .getString('mySec$_myInd')
                            .then((String _value) {
                          _mySec = _value;
                          myControllerSec.text = _value;
                        });
                      });
                    });
                    // Navigate back to first route when tapped.
                    //Navigator.pop(context);
                  },
                  //child: Text('Cancel'),
                  child: Text('Load'),
                  focusNode: mySaveFocus,
                ),
                /* Padding(
                child:*/
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                    //padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      //maxLength: 5,
                      //autofocus: true,
                      //textInputAction: TextInputAction.next,
                      onSubmitted: (s) {
                        setState(() {
                          _myInd = s;
                        });
                        encryptedSharedPreferences.setString('myInd', s);
                        FocusScope.of(context).nextFocus();
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.trending_flat),
                        hintText: "Enter Index",
                        //helperText: "Enter Index",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                      ),
                      controller: myControllerInd,
                    ),
                  ),
                ),
                //),
                RaisedButton(
                  onPressed: () {
                    setState(() {
                      _myInd = myControllerInd.text;
                      _mySec = myControllerSec.text;
                      _myKey = myControllerKey.text;
                    });
                    encryptedSharedPreferences.setString(
                        'myKey$_myInd', myControllerKey.text);
                    encryptedSharedPreferences.setString(
                        'mySec$_myInd', myControllerSec.text);
                    encryptedSharedPreferences.setString(
                        'myInd', myControllerInd.text);
                  },
                  child: Text("Save"),
                ),
              ],
            ),
            Divider(
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
              child: Text(_myKey ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
              child: Text(_mySec ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
              child: Text(_myInd ?? ''),
            ),
            Divider(
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
