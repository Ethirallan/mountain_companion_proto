import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mountain_companion/database/travel_db_helper.dart';
import 'package:mountain_companion/helper/confirmation_alert.dart';
import 'package:mountain_companion/helper/constants.dart';
import 'package:mountain_companion/models/travel.dart';

Future<List<Travel>> getTravelInfo() {
  var dbHelper = TravelDBHelper();
  Future<List<Travel>> travels = dbHelper.getTravels();
  return travels;
}

class TravelDetails extends StatefulWidget {
  final int myInt;
  final int travelID;
  TravelDetails({this.myInt, this.travelID});
  @override
  State<StatefulWidget> createState() {
    return TravelDetailsState();
  }
}

class TravelDetailsState extends State<TravelDetails> {
  Travel travel;
  List<File> imgFileList = [];
  File headerImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: FutureBuilder<List<Travel>>(
        future: getTravelInfo(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (snapshot.hasData) {
              travel = snapshot.data[widget.myInt];
              List<String> imgPaths = [travel.photo1, travel.photo2, travel.photo3, travel.photo4, travel.photo5, travel.photo6];
              for(int i = 0; i < imgPaths.length; i++) {
                if (imgPaths[i].length > 8) {
                  imgFileList.add(File(imgPaths[i]));
                }
              }
              headerImage = imgFileList.length == 0 ? null : imgFileList[0]; //add defaultImg
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 250.0,
                    backgroundColor: Colors.green,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        travel.title,
                        style: TextStyle(),
                      ),
                      background: Image.file(headerImage, //add default img!
                        fit: BoxFit.cover,
                      ),
                    ),
                    actions: <Widget>[
                      PopupMenuButton(
                        onSelected: pickAction,
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (BuildContext ctx) {
                          return Constants.details.map((String action) {
                            return PopupMenuItem<String>(
                              value: action,
                              child: Text(action, style: TextStyle(fontSize: 20.0),),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              buildDataCard('Datum:', travel.date),
                              buildDataCard('Lokacija:', travel.location),
                              buildDataCard('Čas hoje:', travel.time),
                              buildDataCard('Višinska razlika:', travel.height),
                              buildDataCard('Zapiski:', travel.notes),
                              gallery(imgFileList),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (snapshot.data.length == 0) {
              return Text('Ni podatkov');
            }
          }
          return Container(
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget buildDataCard(String title, String text) {
    return Card(
      elevation: 4.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 0.0, 0.0),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 4.0, 0.0, 8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.blueGrey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget gallery(List list) {
    return Card(
      elevation: 4.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 0.0, 0.0),
            child: Text(
              'Galerija:',
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            height: 360.0,
            padding: EdgeInsets.all(14.0),
            child: draw(list),
          ),
        ],
      ),
    );
  }

  Widget draw(List list) {
    return PageView.builder(
      itemCount: list.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Image.file(list[index], fit: BoxFit.scaleDown);
      },
    );
  }

  void pickAction(String action) {
    if (action == Constants.edit) {

    } else if (action == Constants.delete) {
      ConfirmationAlert().myAlert(context, 'Opozorilo', 'Ste prepričani, da želite izbrisati izlet?', () {
        Travel travel = new Travel();
        travel.id = widget.travelID;
        var dbHelper = new TravelDBHelper();
        dbHelper.deleteTravel(travel);
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }
}
