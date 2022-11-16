import 'dart:convert';
import 'package:intl/intl.dart';

import '../Exception/exception.dart';

class Mrz {
  late final String givenName;
  late final String surname;
  late final String gender;
  late final DateTime expireDate;
  late final DateTime birthday;
  late final String nationality;
  late final String? issuer;
  late final String docType;
  late final String docId;
  late final String sizeType;

  Mrz(
      {required this.givenName,
      required this.surname,
      required this.gender,
      required this.expireDate,
      required this.birthday,
      required this.issuer,
      required this.docType,
      required this.docId,
      required this.sizeType,
      required this.nationality});

  factory Mrz.fromJsonString(String jsonString) {
    Map<String, dynamic> json;
    print("mrzfromJson: $jsonString");
    if(jsonString.substring(0,1) == "-1") throw PmExceptionEx(-106,jsonString) ;
    print("before decode");
    try {
      json = jsonDecode(jsonString);
    }catch(e){
      throw PmExceptionEx(-106, jsonString);
    }
    print("after decode");
    return Mrz(
        givenName: json['givenName'] as String,
        surname: json['surname'] as String,
        gender: json['gender'] as String,
        expireDate: DateFormat('MM/dd/yy').parse(json['expireDate'] as String),
        birthday: DateFormat('MM/dd/yy').parse(json['birthday'] as String),
        nationality: json['nationality'] as String,
        issuer: json['issuer'] as String?,
        docType: json['docType'] as String,
        docId: json['docId'] as String,
        sizeType: json['sizeType'] as String);
  }
}
