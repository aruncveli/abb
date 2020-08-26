import 'dart:convert';
import 'dart:io';

import 'package:abb/abbUsageChart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AbbStatefulWidget extends StatefulWidget {
  AbbStatefulWidget({Key key}) : super(key: key);

  @override
  _AbbStatefulWidgetState createState() => _AbbStatefulWidgetState();
}

class _AbbStatefulWidgetState extends State<AbbStatefulWidget> {
  static const uri = 'https://myabb.in/totalBalance';
  static const emptyFormFields = [
    'connType',
    'packageName',
    'addOnStartTime',
    'addOnEndTime',
    'cYear',
    'cMonth',
    'uploadByte',
    'downloadByte',
    'totalByte',
    'Sub.SubscriberIdentity',
    'QoSProfile.Name',
    'CS.GatewayAddress',
    'CS.GatewayName',
    'CS.UserIdentity',
    'CS.SessionIPv4',
    'Sub.DataPackage',
    'CREATE_TIME',
    'LAST_UPDATE_TIME',
    'ACTIVE_PCC_RULE_NAMES',
    'CS.SessionID'
  ];

  double _balance;
  double _downloaded;
  double _uploaded;
  String _connectionType;
  String _packageName;

  String _idCache;

  TextEditingController _idFieldController = TextEditingController();

  Future<bool> _data;
  bool _refreshing = false;

  initState() {
    super.initState();
    _data = _fetchData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asianet Broadband Usage'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _displaySubscriberDialog(),
          )
        ],
      ),
      body: _refreshing
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<bool>(
              future: _data,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == false)
                    return Center(
                        child: Text('Invalid Subscriber ID. Check Settings.'));
                  else
                    return Center(
                        child: AbbUsageChart.getUsageChart(
                            _balance,
                            _downloaded,
                            _uploaded,
                            _connectionType,
                            _packageName));
                } else
                  return Center(child: CircularProgressIndicator());
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
        onPressed: () => _fetchData(),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Future<bool> _fetchData() async {
    setState(() {
      _refreshing = true;
    });
    var formData = new Map<String, String>();
    for (var emptyFormField in emptyFormFields)
      formData.putIfAbsent(emptyFormField, () => '');

    if (_idCache == null) await _readId();
    if (_idCache == null) {
      setState(() {
        _refreshing = false;
      });
      return false;
    }
    formData.putIfAbsent('subscriberCode', () => _idCache);

    http.Response response = await http.post(uri, body: formData);
    var responseBody = jsonDecode(response.body);
    if (responseBody[0]['Msg'] == 'SUCCESS') {
      var usage = jsonDecode(responseBody[0]['usage']);
      setState(() {
        _balance = usage[0]['balance']['totalOctets'];
        _downloaded = usage[0]['curretUsage']['downloadOctets'];
        _uploaded = usage[0]['curretUsage']['uploadOctets'];
        _connectionType = responseBody[0]['connType'];
        _packageName = responseBody[0]['packageName'];
        _refreshing = false;
      });
      return true;
    } else {
      _refreshing = false;
      return false;
    }
  }

  _displaySubscriberDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Set Subscriber ID'),
            content: TextField(
                controller: _idFieldController,
                decoration: InputDecoration(hintText: 'Enter ID here')),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () => _writeId(_idFieldController.text),
                  child: new Text('SUBMIT'))
            ],
          );
        });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/id.txt');
  }

  _writeId(String id) async {
    Navigator.of(context).pop();
    _idCache = id;
    _idFieldController.text = id;
    final file = await _localFile;
    file.writeAsString('$id');
    setState(() {
      _data = _fetchData();
    });
  }

  Future<String> _readId() async {
    if (_idCache == null) {
      try {
        final file = await _localFile;
        _idCache = await file.readAsString();
        _idFieldController.text = _idCache;
      } catch (e) {
        return "";
      }
    }
    return _idCache;
  }
}
