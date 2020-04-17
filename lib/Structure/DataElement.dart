import 'package:firebase_database/firebase_database.dart';

class DataElement {
  String key;
  dynamic DataSlot;
  Map<dynamic, dynamic> Values = new Map();

  //List Fields;
  List Types;

  /*
  int Field1;
  int Field2;
  int Field3;
  int Field4;

  String FieldType1;
  String FieldType2;
  String FieldType3;
  String FieldType4;

  Field1 = snapshot.value["F1"],
        Field2 = snapshot.value["F2"],
        Field3 = snapshot.value["F3"],
        Field4 = snapshot.value["F"],
        Fields = _createFields(snapshot),
        Types = _createTypes(snapshot),
        FieldType2 = snapshot.value["T2"],
        FieldType3 = snapshot.value["T3"],
        FieldType4 = snapshot.value["T4"],


^*/
  DateTime timestamp;

  DataElement(this.DataSlot, this.timestamp);

  DataElement.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        Types = _getTypes(snapshot),
        Values = _getValues(snapshot),
        timestamp = DateTime.fromMillisecondsSinceEpoch(
            snapshot.value["timestamp"],
            isUtc: true);

  toJson() {
    return {
      "key": key,
      "timestamp": timestamp.toString(),
    };
  }

  static List _createFields(DataSnapshot snapshot) {
    List fields = [];
    for (int i = 1; i < 5; i++) {
      fields.add(snapshot.value["F" + i.toString()]);
    }
    return fields;
  }

  static List _createTypes(DataSnapshot snapshot) {
    List fields = [];
    for (int i = 1; i < 5; i++) {
      fields.add(snapshot.value["T" + i.toString()]);
    }
    return fields;
  }

  static _getTypes(DataSnapshot snapshot) {
    Map<dynamic, dynamic> Dataslot = {};
    List types = [];
    for (int i = 0; i < 5; i++) {
      Dataslot = snapshot.value["DATASLOT_" + i.toString()];
      if (Dataslot != null) {
        types.add(Dataslot["Type"]);
      }
    }
    return types;
  }

  static _getValues(DataSnapshot snapshot) {
    Map<dynamic, dynamic> Dataslot = {};
    Map<dynamic, dynamic> values = {};
    for (int i = 0; i < 5; i++) {
      Dataslot = snapshot.value["DATASLOT_" + i.toString()];
      if (Dataslot != null) {
        values[Dataslot["Type"]] = Dataslot["Value"];
      }
    }
    return values;
  }
}
