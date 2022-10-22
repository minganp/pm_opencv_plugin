
import 'package:flutter/cupertino.dart';
import 'package:pm_opencv_plugin/mrz_parser-master/lib/mrz_parser.dart';

Widget passModal(BuildContext context, MRZResult passMrz){
  return SizedBox(
        child: Column(
          children: [
            Row(
                children:[
                  Text("Name:${passMrz.givenNames}"),
                  Text("Birth.:${passMrz.birthDate}"),
                ]),
            Row(
              children: [
                Text("ID:${passMrz.documentType}"),
                Text("ID No: ${passMrz.documentNumber}"),
                Text("Expire: ${passMrz.expiryDate}")
              ],
            ),
            Row(
              children: [
                Text("Nation:${passMrz.countryCode}"),
                Text("Pol: ${passMrz.sex}"),
                Text("NC:${passMrz.nationalityCountryCode}")
              ],
            )
          ],
        ),
      );
    }
