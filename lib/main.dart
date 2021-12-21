import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([
    SystemUiOverlay.bottom
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? imageFile;
  bool check = false;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _streamSubscription;


  Future<void> initConnectivity() async{
    late ConnectivityResult result;
    try{
      result = await _connectivity.checkConnectivity();
    }on PlatformException catch(e){
      print(e.toString());
      return;
    }

    if (!mounted){
      return Future.value(null);
    }

    return _updateConnectivityStatus(result);
  }

  Future<void> _updateConnectivityStatus(ConnectivityResult result) async {
    setState((){
      _connectivityResult = result;
      });
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _streamSubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivityStatus);
  }
  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }


  void _imgFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      imageFile = File(pickedFile!.path);
    });
  }

  void _imgFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      imageFile = File(pickedFile!.path);
    });
  }

  // Internet Alert
  void _internetAlert(context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                new Text(
                    "No Internet Found",
                    style: GoogleFonts.oxygen(color: Color(0xff070707), fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 50),
                Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    width: MediaQuery.of(context).size.width - 10,
                    height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                    child: FlatButton(
                      child: Text('Exit', style: GoogleFonts.oxygen(color: Colors.white, fontSize: 25)),
                      color: Colors.cyan,
                      textColor: Colors.black,
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                    ),
                  )
                ])
              )
          );
        }
    );
  }

  _upload(imageValue) async {
    final request = http.MultipartRequest("POST", Uri.parse("https://ecappapi.herokuapp.com/upload"));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(
      http.MultipartFile("image", imageValue.readAsBytes().asStream(), imageValue.lengthSync(), filename: imageValue.path.split("/").last));
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    return resJson;
  }

  // Tile
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Loading
  void _showLoading(context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Container(
              height: 100,
              width: 100,
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF21BFBD)),
              )),
            ),
          );
        });
  }

  // Happy Dialog
  void _happyDialog(context, percent) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/happy.png",
                    width: 70,
                    height: 70,
                    fit: BoxFit.fitHeight,
                  ),
                  SizedBox(height: 10),
                  new Text(
                    "Happy",
                    style: GoogleFonts.oxygen(color: Color(0xff070707), fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  new Text(
                    percent,
                    style: GoogleFonts.oxygen(color: Color(0xff070707), fontSize: 15),
                  ),
                  SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    width: MediaQuery.of(context).size.width - 10,
                    height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                    child: FlatButton(
                      child: Text('Close', style: GoogleFonts.oxygen(color: Colors.white, fontSize: 25)),
                      color: Colors.cyan,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  // Sad
  void _sadDialog(context, percent) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/sad.png",
                    width: 70,
                    height: 70,
                    fit: BoxFit.fitHeight,
                  ),
                  SizedBox(height: 10),
                  new Text(
                    "Sad",
                    style: GoogleFonts.oxygen(color: Color(0xff070707), fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  new Text(
                    percent,
                    style: GoogleFonts.oxygen(color: Color(0xff070707), fontSize: 15),
                  ),
                  SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    width: MediaQuery.of(context).size.width - 10,
                    height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                    child: FlatButton(
                      child: Text('Close', style: GoogleFonts.oxygen(color: Colors.white, fontSize: 25)),
                      color: Colors.cyan,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

   // Surprised
  void _surprisedDialog(context, percent) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/surprised.png",
                    width: 70,
                    height: 70,
                    fit: BoxFit.fitHeight,
                  ),
                  SizedBox(height: 10),
                  new Text(
                    "Surprised",
                    style: GoogleFonts.oxygen(color: Color(0xff070707), fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  new Text(
                    percent,
                    style: GoogleFonts.oxygen(color: Color(0xff070707), fontSize: 15),
                  ),
                  SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    width: MediaQuery.of(context).size.width - 10,
                    height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                    child: FlatButton(
                      child: Text('Close', style: GoogleFonts.oxygen(color: Colors.white, fontSize: 25)),
                      color: Colors.cyan,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  // Angry
  void _angryDialog(context, percent) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/angry.png",
                    width: 70,
                    height: 70,
                    fit: BoxFit.fitHeight,
                  ),
                  SizedBox(height: 10),
                  new Text(
                    "Angry",
                    style: GoogleFonts.oxygen(color: Color(0xff070707), fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  new Text(
                    percent,
                    style: GoogleFonts.oxygen(color: Color(0xff070707), fontSize: 15),
                  ),
                  SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    width: MediaQuery.of(context).size.width - 10,
                    height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                    child: FlatButton(
                      child: Text('Close', style: GoogleFonts.oxygen(color: Colors.white, fontSize: 25)),
                      color: Colors.cyan,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21BFBD),
      body: Column(
        children: [
          Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                     "Emotions Classification",
                    style: GoogleFonts.oxygen(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "By Muhammad Hanan Asghar",
                    style: GoogleFonts.pacifico(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width,
              height: 230),
          Container(
            height: MediaQuery.of(context).size.height - 230,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            imageFile!,
                            width: 250,
                            height: 250,
                            fit: BoxFit.fitHeight,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                          width: 250,
                          height: 250,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                        ),
                ),
                SizedBox(height: 15),
                Column(
                  children: [
                    Center(
                        child: Container(
                      margin: EdgeInsets.only(left: 25, right: 25, top: 10),
                      width: MediaQuery.of(context).size.width - 10,
                      height: 50,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                      child: FlatButton(
                        child: Text('Select an image', style: GoogleFonts.oxygen(color: Colors.white, fontSize: 25)),
                        color: Colors.cyan,
                        textColor: Colors.black,
                        onPressed: () {
                          _showPicker(context);
                        },
                      ),
                    )),
                    SizedBox(height: 10),
                    Center(
                        child: Container(
                      margin: EdgeInsets.only(left: 25, right: 25),
                      width: MediaQuery.of(context).size.width - 10,
                      height: 50,
                      child: FlatButton(
                        child: Text('Predict', style: GoogleFonts.oxygen(color: Colors.white, fontSize: 25)),
                        color: Colors.cyan,
                        textColor: Colors.black,
                        onPressed: () {
                          if(_connectivityResult == null){
                            _internetAlert(context);
                          }else{
                            if(imageFile == null){
                              print("Select Image");
                            }else{
                              readIT() async {
                                _showLoading(context);
                                try{
                                  final _response = await _upload(imageFile!);
                                  if(_response['em'].toString() == "4")
                                  {
                                    Navigator.of(context).pop();
                                    _surprisedDialog(context, _response['per']);
                                  }
                                  if(_response['em'].toString() == "3")
                                  {
                                    Navigator.of(context).pop();
                                    _sadDialog(context, _response['per']);
                                  }
                                  if(_response['em'].toString() == "2")
                                  {
                                    Navigator.of(context).pop();
                                    _happyDialog(context, _response['per']);
                                  }
                                  if(_response['em'].toString() == "1")
                                  {
                                    Navigator.of(context).pop();
                                    _angryDialog(context, _response['per']);
                                  }
                                } catch (error) {
                                  Navigator.of(context).pop();
                                  final snackBar = SnackBar(
                                    content: const Text("Error!, Internet is Slow."),
                                    backgroundColor: (Colors.black12),
                                    action: SnackBarAction(
                                      label: "dismiss",
                                      onPressed: (){

                                        },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              }
                              readIT();
                            }
                            
                          }
                          },
                      ),
                    )),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
