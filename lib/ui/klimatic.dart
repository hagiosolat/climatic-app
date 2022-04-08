import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  const Klimatic({Key? key}) : super(key: key);

  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String? _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(builder: (BuildContext context) {
        return ChangeCity();
      }),
    );
    if (results != null && results.containsKey('enter')) {
      _cityEntered = results['enter'];
      print("From first screen " + results['enter'].toString());
    }
  }

  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Klimatic"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _goToNextScreen(context),
            icon: Icon(Icons.menu),
          )
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              "images/umbrella.png",
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 10.9, 28.9, 0.0),
            child: Text(
              "${_cityEntered ?? util.defaultCity}",
              style: cityStyle(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset("images/light_rain.png"),
          ),
          Container(
            ///margin: const EdgeInsets.fromLTRB(30.0, 370.0, 0.0, 0.0),
            alignment: Alignment.center,
            child: updateTempWidget(_cityEntered),
          )
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$appId&units=imperial";
    Uri apiUrl = Uri.parse(url);
    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateTempWidget(String? city) {
    return FutureBuilder(
        future: getWeather(util.appId, city ?? util.defaultCity),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map? content = snapshot.data;
            return Container(
              margin: const EdgeInsets.fromLTRB(30.0,250.0,0.0,0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    title: Text(
                      content!["main"]["temp"].toString() + " F",
                      style: tempStyle(),
                    ),
                    subtitle: ListTile(
                      title: Text(
                        "Humidity: ${content['main']['humidity'].toString()}\n"
                            "Min: ${content['main']['temp_min'].toString()} F\n"
                            "Max: ${content['main']['temp_max'].toString()} F",
                        style: extraDate(),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }
}

class ChangeCity extends StatelessWidget {
  var _cityFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Change city'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'images/white_snow.png',
              width: 400.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          ListView(
            children: [
              ListTile(
                title: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter City',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: FlatButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'enter': _cityFieldController.text,
                    });
                  },
                  textColor: Colors.white70,
                  color: Colors.redAccent,
                  child: Text("Get Weather"),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontStyle: FontStyle.italic,
  );
}

TextStyle tempStyle() {
  return TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: 49.9);
}

TextStyle extraDate(){
  return TextStyle(
      color: Colors.white70,
      fontStyle: FontStyle.normal,
      fontSize: 17.0);
}
