import 'package:app_offine/services/user_service.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter API Cached'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UserService _userService = UserService();
  var _subscription;
  bool isConnection = false;
  String connecting = '';
  final TextEditingController _controller = TextEditingController();
  var _searchKey = '';

  List<Map<String, dynamic>> _userData = [];
  @override
  Widget build(BuildContext context) {
    _loadUser();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        print('press');
                        _loadUser();
                      },
                      child: const Text('loadUser'),
                    ),
                    Spacer(),
                    Text("connecting: $isConnection By $connecting")
                  ],
                ),
                TextFormField(
                  controller: _controller,
                  onChanged: (String value) {
                    setState(() {
                      _searchKey = value;
                      _userData = _userData
                          .where((element) => element['name']
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                      if (_userData.isEmpty) {
                        _loadUser();
                      }
                    });
                  },
                ),
                SizedBox(
                  // color: Colors.amberAccent,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: _listView(),
                )
              ],
            ),
          ),
        ));
  }

  @override
  dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  initState() {
    super.initState();
    _getConnection();
    _loadUser();
  }

  void _getConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        isConnection = true;
        connecting = 'Mobile';
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        isConnection = true;
        connecting = 'wifi';
      });
    } else {
      setState(() {
        isConnection = false;
      });
    }
  }

  Future _getUser() async {
    var result = await _userService.fetchUser();
    return result;
  }

  Future _getUserModelList() async {
    List<Map<String, dynamic>> projetcList = await _userService.fetchUser();
    return projetcList;
  }

  Widget _listUser() {
    return FutureBuilder(
      builder: (context, snapshot) {
        var _itemCount =
            snapshot.data != null ? snapshot.data.toString().length : 0;
        if (snapshot.connectionState == ConnectionState.none &&
            snapshot.hasData == null) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }
        return ListView.builder(
          itemCount: _itemCount,
          itemBuilder: (context, index) {
            var _data = snapshot.data.toString();

            if (snapshot.data != null) {
              return Text("decode[index]['name']");
            }
            return Container();
          },
        );
      },
      future: _getUserModelList(),
    );
  }

  Widget _listView() {
    return ListView.builder(
      itemCount: _userData.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(_userData[i]['name']),
        );
      },
    );
  }

  void _loadUser() async {
    _userData = await _getUser();
    print(_userData);
  }
}
