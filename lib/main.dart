import 'package:flutter/material.dart';
import 'package:flutter_background_location/flutter_background_location.dart';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:http/http.dart';

// Initialized Variables
String deviceid = null;
var safe_or_not = null; // another request to the api
var response_body = null;

// Access information
String website_ip = "http://127.0.0.1";
String username = "admin";
String password = 'SuperSecretPwd';

void main() {

  runApp(MyApp());

 print("Starting Location Service");
  FlutterBackgroundLocation.startLocationService();
  FlutterBackgroundLocation.getLocationUpdates((location) {
    var latitude = location.latitude;
    var longitude = location.longitude;
    var loc = "$latitude, $longitude";
    print("Location Determined: $latitude,$longitude");
    _makeGetRequest("user_Location", deviceid, loc);
  });
}

_makeGetRequest(subdomain, user, params) async {
  // make GET request
  List userList = await Future.wait([_getId()]);
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  String url = '$website_ip:5000/api/v1/$subdomain?user=${userList[0]}&location=$params';
  Response response = await get(url, headers: <String, String>{'authorization': basicAuth} );
  print(response.body);
}

String parse_requests(requestBody){

  requestBody = requestBody.replaceAll('"', '');
  if (requestBody.toLowerCase().contains("safe")){
      return "No Harmful \nInteractions\n detected";
  }
  else{
    return "Harmful \ninteraction\ndetected on\n$requestBody";
  }

}

Future<String> _makeGetRequest_2(subdomain, user) async {
  // make GET request
  List userList = await Future.wait([_getId()]);
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  String url = '$website_ip:5000/api/v1/$subdomain?user=${userList[0]}';
  Response response = await get(url, headers: <String, String>{'authorization': basicAuth} );
  response_body = response.body;
  print("Response Body $response_body");
  return response_body;
}

Future<String> _getId() async {
   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    deviceid = iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

    deviceid = androidDeviceInfo.androidId; // unique ID on Android
    print("Android Device Info $deviceid");
    return deviceid;
  }

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'CoTracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),

    );
  }
}


class HomePage extends StatelessWidget {

  Widget futureWidget2(){
    return FutureBuilder<String>(
        future: _makeGetRequest_2("user_virusPotential", deviceid),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // modify snapshot
          if (!snapshot.hasData) {
            // while data is loading:
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
          return new TypewriterAnimatedTextKit(
            //onTap: () {
            //  print("Tap Event");
            // },
              totalRepeatCount: 4000,
              speed: Duration(milliseconds: 100),
              text: [
                parse_requests(snapshot.data),
              ],
              textStyle: TextStyle(
                fontSize: 30.0,
                fontFamily: "General",
                color: Colors.lightBlueAccent,
              ),
              textAlign: TextAlign.start,
              alignment: AlignmentDirectional.bottomCenter,
          );
        }}
    );
  }
  @override
  Widget build(BuildContext context) {

    //print("Android Device Info HomePage $deviceid");
    return Scaffold(
      appBar: GradientAppBar(
        title: Text('CoronaVirus Tracker'),
        backgroundColorStart: Colors.cyan,
        backgroundColorEnd: Colors.indigo,
      ),

        body:
        Center(

            child:
            Container(

              decoration: BoxDecoration(
              gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blue, Colors.red])),
              child: Stack(
                  children: <Widget>[
              Align(

              alignment: Alignment.lerp(Alignment.bottomCenter, Alignment.center, 0.8),

                  child :
                     SizedBox(
                      width: 200.0,
                      child: futureWidget2(),
                  ),


              ),
                    Align(
              alignment: Alignment.lerp(Alignment.topCenter, Alignment.center, 0.2),
                    child: Text(
                      'Tracks individuals’ \nproximity to each other\n '
                          'throughout the day',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 25,

                      ),
                    ),
                    ),
                    Align(
                      alignment: Alignment.lerp(Alignment.topCenter, Alignment.center, 0.55),
                      child: Text(
                        '(please allow the app to run in the background)', //\n(please allow the app to run in the background)
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.lightGreen,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                    ),
                    Align(
              alignment: Alignment.lerp(Alignment.bottomCenter, Alignment.center, 0.3),
                  child: FlatButton(

                    color: Colors.lightBlue,
                    textColor: Colors.lightGreenAccent,
                    padding: EdgeInsets.all(8.0),
                    splashColor: Colors.blueAccent,
                    onPressed: () {
                      _makeGetRequest_2("user_hasVirus", deviceid);
                    },
                    child: Text(
                      "I am Infected with CoronaVirus",
                      style: TextStyle(fontSize: 21.0),
                    ),

                  )

               ),
                  ]),
            )
    ));
  }
}

