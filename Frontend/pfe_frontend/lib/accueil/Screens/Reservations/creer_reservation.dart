import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pfe_frontend/accueil/models/reservation.dart';
import 'package:pfe_frontend/accueil/utils/api_methods.dart';
import 'dart:io' show Platform;
import 'package:pfe_frontend/admin/utils/dimensions.dart';
import 'package:pfe_frontend/authentication/models/user.dart';
import 'package:pfe_frontend/authentication/utils/colors.dart';
import 'package:pfe_frontend/authentication/utils/utils.dart';

class CreateReservation extends StatefulWidget {
  final List<User> patientslist;
  final List<User> docteurslist;

  const CreateReservation({
    Key? key,
    required this.docteurslist,
    required this.patientslist,
  }) : super(key: key);

  @override
  State<CreateReservation> createState() => _CreateReservationState();
}

class _CreateReservationState extends State<CreateReservation> {
  bool _isLoading = false;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void creerReservations() async {
    setStateIfMounted(() {
      _isLoading = true;
    });
    _setIds();
    String result = await ApiMethods().createReservation(
      dateRendezvous: dateRendezvous,
      starttime: starttimeCtl.text,
      endtime: endtimeCtl.text,
      patient_id: _patient_id,
      docteur_id: _docteur_id,
    );
    setStateIfMounted(() {
      _isLoading = false;
    });
    if (result != "success") {
      showSnackBar("Une erreur est survenue, veuillez réessayer !", context);
    } else {
      showSnackBar("Réservation créée avec succès !", context);
    }
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); // "6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  _setIds() {
    _patient_id = widget.patientslist[widget.patientslist.indexWhere(
            (p) => p.first_name + " " + p.last_name == patient_full_name)]
        .getUserId();
    _docteur_id = widget.docteurslist[widget.docteurslist.indexWhere(
            (d) => d.first_name + " " + d.last_name == doctor_full_name)]
        .getUserId();
  }

  TextEditingController dateCtl = TextEditingController();
  TextEditingController starttimeCtl = TextEditingController();
  TextEditingController endtimeCtl = TextEditingController();
  TextEditingController patientCtl = TextEditingController();
  TextEditingController docteurCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime dateRendezvous = DateTime.now();
  TimeOfDay startTime = TimeOfDay(hour: 15, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 15, minute: 0);
  int _patient_id = 0;
  int _docteur_id = 0;
  bool? disponible;
  String? patient_full_name = "";
  String? doctor_full_name = "";

  @override
  void dispose() {
    super.dispose();
    dateCtl.dispose();
    starttimeCtl.dispose();
    endtimeCtl.dispose();
    patientCtl.dispose();
    docteurCtl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _formattedate;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Créer Réservation"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          //  _setUsers();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "Créer une nouvelle réservation : ",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: dateCtl,
                      decoration:
                          InputDecoration(labelText: 'Date Rendez-vous : '),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        _formattedate = DateFormat.yMMMMEEEEd()
                            .format(picked ?? DateTime.now());
                        dateCtl.text = _formattedate.toString();
                        if (picked != null && picked != dateRendezvous) {
                          setState(() {
                            dateRendezvous = picked;
                          });
                        }
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ce champ ne peut pas être vide';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: starttimeCtl,
                      decoration: InputDecoration(
                        labelText: 'Heure de début :',
                      ),
                      onTap: () async {
                        TimeOfDay time = TimeOfDay.now();
                        FocusScope.of(context).requestFocus(FocusNode());
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? time,
                        );
                        if (picked != null && picked != startTime) {
                          final hours = picked.hour.toString().padLeft(2, '0');
                          final minutes =
                              picked.minute.toString().padLeft(2, '0');
                          starttimeCtl.text = '$hours:$minutes';
                          setState(() {
                            startTime = picked;
                          });
                        }
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ce champ ne peut pas être vide';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: endtimeCtl,
                      decoration: InputDecoration(
                        labelText: 'Heure de fin :',
                      ),
                      onTap: () async {
                        TimeOfDay time = TimeOfDay.now();
                        FocusScope.of(context).requestFocus(FocusNode());
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? time,
                        );
                        if (picked != null && picked != startTime) {
                          final hours = picked.hour.toString().padLeft(2, '0');
                          final minutes =
                              picked.minute.toString().padLeft(2, '0');
                          endtimeCtl.text = '$hours:$minutes';
                          setState(() {
                            endTime = picked;
                          });
                        }
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ce champ ne peut pas être vide';
                        }
                        return null;
                      },
                    ),
                    Divider(),
                    DropdownSearch<String>(
                      items: widget.patientslist
                          .map((patient) =>
                              patient.first_name + " " + patient.last_name)
                          .toList(),
                      selectedItem: "-",
                      onChanged: (String? data) {
                        setState(() {
                          patient_full_name = data;
                        });
                      },
                      popupProps: PopupProps.bottomSheet(
                        searchFieldProps: TextFieldProps(
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                            labelText: "Rechercher ...",
                          ),
                        ),
                        title: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Sélectionner le patient : ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        bottomSheetProps: BottomSheetProps(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                        ),
                        showSearchBox: true,
                      ),
                    ),
                    Divider(),
                    DropdownSearch<String>(
                      items: widget.docteurslist
                          .map((docteur) =>
                              docteur.first_name + " " + docteur.last_name)
                          .toList(),
                      selectedItem: "-",
                      onChanged: (String? data) {
                        setState(() {
                          doctor_full_name = data;
                        });
                      },
                      popupProps: PopupProps.bottomSheet(
                        searchFieldProps: TextFieldProps(
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                            labelText: "Rechercher ...",
                          ),
                        ),
                        title: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Sélectionner le docteur : ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        bottomSheetProps: BottomSheetProps(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                        ),
                        showSearchBox: true,
                      ),
                    ),
                    Divider(),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          creerReservations();
                        }
                      },
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text('Créer Réservation'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
