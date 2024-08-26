import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:pfe_frontend/accueil/models/reservation.dart';
import 'package:pfe_frontend/accueil/utils/api_methods.dart';
import 'package:pfe_frontend/admin/utils/dimensions.dart';
import 'package:pfe_frontend/authentication/context/authcontext.dart';
import 'package:pfe_frontend/authentication/models/user.dart';
import 'package:pfe_frontend/authentication/utils/colors.dart';
import 'package:pfe_frontend/docteur/screens/partie_consultations/patient_selections/select_patient_manually.dart';
import 'package:pfe_frontend/docteur/screens/partie_consultations/patient_selections/select_petient_with_qr.dart';
import 'package:pfe_frontend/docteur/utils/doctor_api_methods.dart';

class SelectionnerPatient extends StatefulWidget {
  final List<Reservation> reservations;
  const SelectionnerPatient({Key? key, required this.reservations})
      : super(key: key);

  @override
  State<SelectionnerPatient> createState() => _SelectionnerPatientState();
}

class _SelectionnerPatientState extends State<SelectionnerPatient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<User> list_patient = [];

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  _setListPatient() async {
    if (widget.reservations.isNotEmpty) {
      for (var i = 0; i < widget.reservations.length; i++) {
        print(widget.reservations[i].patient_id);
        User user1 =
            await ApiMethods().getUserById(widget.reservations[i].patient_id);
        list_patient.add(user1);
      }
      setStateIfMounted(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _setListPatient();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choisir le patient"),
        centerTitle: true,
        backgroundColor: AdminColorSix,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.network(
                "https://media.istockphoto.com/vectors/qr-code-scan-phone-icon-in-comic-style-scanner-in-smartphone-vector-vector-id1166145556"),
            SizedBox(height: 20.0),
            textButton("Choisir avec scan QR CODE",
                Text("Scan Screen not ready for now")),
            SizedBox(height: 20.0),
            textButton("Choisir manuellement",
                SelectionPatientManuelle(patientList: list_patient)),
          ],
        ),
      ),
    );
  }

  Widget textButton(String text, Widget widget) {
    return TextButton(
      onPressed: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => widget));
      },
      child: Text(
        text,
        style: TextStyle(color: AdminColorSix, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(15.0),
        side: BorderSide(color: AdminColorSix, width: 3.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}
