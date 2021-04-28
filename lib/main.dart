import 'package:esense/accelerometerListener.dart';
import 'package:esense/clickyButton.dart';
import 'package:esense/gameController.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:esense_flutter/esense.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

void main() => runApp(MyApp());
_MainMenuState mainMenuState;

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}
TextEditingController text = new TextEditingController();

class _MainMenuState extends State<MainMenu> {
  final RoundedLoadingButtonController connectDeviceController = new RoundedLoadingButtonController();
  final RoundedLoadingButtonController reinitializeAccelController = new RoundedLoadingButtonController();

  String _deviceStatus = '';
  bool sampling = false;
  bool connected = false;
  bool foundDevice = false;
  AccelerometerChangeListener accel;
  StreamSubscription subscription;
  StreamSubscription subscription2;
  StreamSubscription subscription3;
  double playerAngle = 0;
  int bestRound;

  // the name of the eSense device to connect to -- change this to your own device.
  String eSenseName = 'eSense-0264'; //links: 0264, rechts: 1769
  

  @override
  void initState() {
    super.initState();
    mainMenuState = this;
    Flame.images.loadAll(<String>[
      'zombie.png',
      'player.png',
      'background.png',
      'background2.png',
    ]);


    // to be able to change the eSenseName via popup
    text.text = eSenseName;
    text.addListener(() {
      setState(() {
        // only stop search if the new devicename is different
        if (eSenseName != text.text) {
          ESenseManager.disconnect();
          this.connectDeviceController.reset();
        }
        eSenseName = text.text;
      });
    });
  }

  Future<void> _connectToESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    subscription2 = ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');
      
      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            this.connected = true;
            subscription2.cancel();
            _startListenToSensorEvents();
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            this.foundDevice = true;
            this.connectDeviceController.success();
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });

    con = await ESenseManager.connect(eSenseName);


    setState(() {
      _deviceStatus = con ? 'connecting' : 'connection failed';
    });
  }

  

  void _startListenToSensorEvents() async {
    this.accel= null;
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      //print('SENSOR event: $event');
      setState(() {
        if (this.accel == null) {
          this.accel = new AccelerometerChangeListener(event.accel);
          reinitializeAccelController.success();
          Timer(Duration(seconds: 1), () => reinitializeAccelController.reset());
        }else {
          this.accel.setAccl(event.accel);
          this.playerAngle = atan2(this.accel.z, -this.accel.y);
        }
      });
    });
    setState(() {
      sampling = true;
    });
  }

  Future<void> _pauseListenToSensorEvents() async {
    setState(() {
      sampling = false;
    });
    if (subscription == null) return;
    if (subscription2 != null)
      await subscription2.cancel();
    if (subscription3 != null)
      await subscription3.cancel();
    return subscription.cancel();
  }

  Future<void> dispose() async {
    _pauseListenToSensorEvents();
    super.dispose();
    return ESenseManager.disconnect();
  }

  void loadGame() {
    print('loadGame');
    this.startGame();
    //this._pauseListenToSensorEvents().then((e) => this.startGame());
  }

  void startGame() {
    GameController gameController = GameController(this.accel);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameController.widget),
    );
    //runApp(gameController.widget);
  }

  void setBestRound(int round) {
    setState(() {
      if (this.bestRound == null) {
        this.bestRound = round;
        return;
      }
      this.bestRound = round > this.bestRound ? round : this.bestRound;
    });
  }

  void reinitializeAccel() {
    this.accel = null;
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            height: 200,
          decoration: 
            BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/menuBackground.png"),
                fit: BoxFit.fill,
              ),
            ),
          ),
        //elevation: 0.0,
        backgroundColor: Colors.transparent,
          title: const Text('ZombieSense 🧟'),
        ),
        body: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [

            if (bestRound != null && this.connected)
              Container(
                child: Text(
                  "Highest Round: " + bestRound.toString(),
                  textScaleFactor: 2,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black, spreadRadius: 3),
                  ],
                ),
                height: 50,
              ),
              


              SizedBox(height: 100),


              if (!this.connected) 
                RoundedLoadingButton(
                    child: Text("Connect with '" + eSenseName + "'", style: TextStyle(color: Colors.white)),
                    controller: connectDeviceController,
                    onPressed: () => _connectToESense()
                ),

              SizedBox(height: 10),

              if (!this.connected) 
                Center(child: 
                  PopUp(),
                ),

              if (this.connected)
                Center(child: 
                  ClickyButton(
                    child:Row(children: [ Icon(Icons.play_arrow, color: Colors.white, size: 30), 
                                          Text(
                                            'Start Game',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22),
                                          )]),
                    color: Colors.green,
                    onPressed: () => this.loadGame(),
                    ),
                ),

          SizedBox(height: 100),

          if (this.connected)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (this.accel != null)
              Column(children: [ 
                Transform.rotate(
                  alignment: Alignment.center,              
                  angle: playerAngle,
                  child: Image.asset('assets/images/arrow.png', height: 40, fit: BoxFit.contain)
                ),
                Text('up by: \t${this.accel.y * 100}%'),
                Text('left by: \t${this.accel.z * 100}%')]),

              RoundedLoadingButton(
                  child: Text("Reinitialize Sensors", style: TextStyle(color: Colors.white)),
                  controller: reinitializeAccelController,
                  onPressed: () => reinitializeAccel()
              )]),
            ]
          ),
        )
      ),
    );
  }
  }







class PopUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  RaisedButton(
        child: Text('change eSense-Name'),
        onPressed: () {
          showAlertDialog(context);
        },
    );
  }
}

showAlertDialog(BuildContext context) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
          title: Text('Enter the devicename of your eSense'),
          content: TextField(
            controller: text,
            decoration: InputDecoration(hintText: "Set eSense Name"),
          ),
          actions: <Widget>[
             FlatButton(
               color: Colors.green,
               textColor: Colors.white,
               child: Text('Save'),
               onPressed: () { Navigator.of(context, rootNavigator: true).pop('dialog');  },
               ),
          ]
        );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainMenu()
    );
  }
}