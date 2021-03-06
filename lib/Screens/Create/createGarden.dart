/*
 * // Copyright <2020> <Universitat Politència de València>
 * // Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * // software and associated documentation files (the "Software"), to deal in the Software
 * // without restriction, including without limitation the rights to use, copy, modify, merge,
 * // publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
 * // to whom the Software is furnished to do so, subject to the following conditions:
 * //
 * //The above copyright notice and this permission notice shall be included in all copies or
 * // substantial portions of the Software.
 * // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * // EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
 * // OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * // AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * // THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * //
 * // This version was built by senenpalanca@gmail.com in ${DATE}
 * // Updates available in github/senenpalanca/esgarden
 * //
 * //
 */

import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

import '../../UI/PersonalizedField.dart';

class FormGarden extends StatefulWidget {
  @override
  FormGardenState createState() => FormGardenState();
}

class FormGardenState extends State<FormGarden> {
  final nameContoller = TextEditingController();
  final cityContoller = TextEditingController();
  final imgContoller = TextEditingController();
  var _uploadedFileURL;
  File _image;
  final picker = ImagePicker();

  Future<int> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  final _database = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: createGardenButton(context),
      appBar: AppBar(
        title: Text("Create new Garden"),
        backgroundColor: Colors.green,
      ),
      body: Form(child: formUI()),
    );
  }

  @override
  void dispose() {
    nameContoller.dispose();
    cityContoller.dispose();
    imgContoller.dispose();
    super.dispose();
  }

  Future uploadImage() async {
    if (_image != null) {
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('${nameContoller.text}/${_image.path}');
      //.child('chats/${Path.basename(_image.path)}}');
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;

      storageReference.getDownloadURL().then((fileURL) {
        setState(() {
          _uploadedFileURL = fileURL;
          print(_uploadedFileURL);
        });
      });
    }
  }

  Widget formUI() {
    return Container(
      color: Colors.green,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: ListView(
          children: <Widget>[
            Container(
              height: 580, //420,
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Image.asset(
                      'images/icon.png',
                      width: 300.0,
                    ),
                    _image != null
                        ? Image.asset(
                      _image.path,
                      height: 150,
                    )
                        : Container(height: 150),
                    RaisedButton(
                      onPressed: getImage,
                      color: Colors.deepOrange,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.camera_enhance, color: Colors.white,),
                          Text("Select Image", style: TextStyle(
                              fontSize: 20, color: Colors.white),)
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                    ),
                    PersonalizedField(nameContoller, "Name of the Garden",
                        false, Icon(Icons.note_add, color: Colors.white)),
                    PersonalizedField(cityContoller, "City of the Garden",
                        false, Icon(Icons.location_city, color: Colors.white)),
                    //PersonalizedField2(vegetableContoller,"Vegetables to plant",false,Icon(Icons.assignment, color: Colors.white)),
                    /*
                    PersonalizedField(imgContoller, "Image URL Logo", false,
                        Icon(Icons.assignment, color: Colors.white)),
*/
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget createGardenButton(BuildContext context) {
    return new FloatingActionButton.extended(
      onPressed: () async {
        if (!_ValidateFields()) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Error with some Fields"),
                  content: Text("Some fields where empty or with errors"),
                );
              });
        } else {
          await uploadImage();

          createRecord();
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Garden Created"),
                  content: Text("The garden " +
                      nameContoller.text +
                      " has been created!"),
                );
              });
        }
      },
      label: Text(
        'Create Garden',
        style: TextStyle(fontSize: 20.0),
      ),
      icon: Icon(Icons.thumb_up),
      backgroundColor: Colors.deepOrange,
    );
  }

  bool _ValidateFields() {
    String name = nameContoller.text;
    String city = cityContoller.text;
    //String vegetable= vegetableContoller.text;
    String image = imgContoller.text;
    if (name.length > 0 && city.length > 0 && image.length >= 0) {
      print("Fields validated");

      return true;
    } else {
      print("Fields not validated");
      return false;
    }
  }

  Future createRecord() async {
    await Future.delayed(Duration(seconds: 3)).then((_) {
      String img = _uploadedFileURL.toString();

      if (_uploadedFileURL == null) {
        img = "https://i.ibb.co/rwgX7b3/garden2.jpg";
      }
      final databaseReference = _database.child("Gardens");
      databaseReference.child(nameContoller.text).set({
        'City': cityContoller.text,
        //'Vegetable': vegetableContoller.text,
        //'Alerts' : {"C1" : [ "No Notifications" ],"H1" : [ "No notifications"], "T1" : [ "No notifications"]},
        "Latitude": "41.643641",
        "Longitude": "-0.879529",
        "Img": img,
        "sensorData": {
          "General": {
            "Name": "General",
            "Data": {},
            "Valve": {
              "Max": [0],
              "Min": [0],
              "Active": [0],
              "Sensor": 255
            },
            "City": cityContoller.text,
            "Items": ["Temperature", "Air Quality", "Humidity", "Brightness"],
            "Img": "https://i.ibb.co/nPFdzdv/general1.jpg",
            "Parent": nameContoller.text,
            "Vegetable": "General"
          },
          "Nursery": {
            "Name": "Nursery",
            "Data": {},
            "Valve": {
              "Max": [0],
              "Min": [0],
              "Active": [0],
              "Sensor": 255
            },
            "City": cityContoller.text,
            "Items": ["Temperature", "Air Quality", "Humidity"],
            "Img": "https://i.ibb.co/ZYFqJyM/PLANTA-web.jpg",
            "Parent": nameContoller.text,
            "Vegetable": "General"
          },
          "Compost": {
            "Name": "Compost",
            "Data": {},
            "Valve": {
              "Max": [0],
              "Min": [0],
              "Active": [0],
              "Sensor": 255
            },
            "City": cityContoller.text,
            "Items": ["Compost Temperature", "Compost Humidity", "Air Quality"],
            "Img":
            "https://cdn.pixabay.com/photo/2017/06/09/12/51/fresh-2386786_960_720.jpg",
            "Parent": nameContoller.text,
            "Vegetable": "General"
          }
        }
      });
    });
  }
}
