import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_frontend/analyste/utils/analyste_api_methods.dart';
import 'package:pfe_frontend/authentication/context/authcontext.dart';
import 'package:pfe_frontend/authentication/models/user.dart';
import 'package:pfe_frontend/authentication/utils/colors.dart';
import 'package:pfe_frontend/authentication/utils/utils.dart';

class CreerBilan extends StatefulWidget {
  final int typeBilan;
  final List<User> patientslist;
  final List<User> docteurslist;

  const CreerBilan(
      {Key? key, required this.typeBilan, required this.docteurslist, required this.patientslist})
      : super(key: key);

  @override
  State<CreerBilan> createState() => _CreerBilanState();
}

class _CreerBilanState extends State<CreerBilan> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = false;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void creerBilan() async {
    setStateIfMounted(() {
      _isLoading = true;
    });
    User currentuser = await AuthContext().getUserDetails();
    _setIds();
    String result = await AnalysteApiMethods().creerBilan(
        File(file.path),
        descriptionController.text,
        nomLaboratoireConroller.text,
        widget.typeBilan,
        currentuser.id,
        _patient_id,
        _docteur_id);

    setStateIfMounted(() {
      _isLoading = false;
    });
    if (result != "success") {
      showSnackBar("Une erreur est survenue, veuillez réessayer !", context);
    } else {
      showSnackBar("Bilan ajouté avec succès !", context);
    }
  }

  _setIds() {
    _patient_id = widget.patientslist[widget.patientslist.indexWhere((p) => p.first_name + " " + p.last_name == patient_full_name)].getUserId();
    _docteur_id = widget.docteurslist[widget.docteurslist.indexWhere((d) => d.first_name + " " + d.last_name == doctor_full_name)].getUserId();
  }

  Client client = http.Client();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nomLaboratoireConroller = TextEditingController();
  TextEditingController patientCtl = TextEditingController();
  TextEditingController docteurCtl = TextEditingController();
  TextEditingController file_name = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  DateTime dateRendezvous = DateTime.now();
  int _patient_id = 0;
  int _docteur_id = 0;
  var file;
  bool? disponible;
  String? patient_full_name = "";
  String? doctor_full_name = "";

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
    nomLaboratoireConroller.dispose();
    patientCtl.dispose();
    docteurCtl.dispose();
    file_name.dispose();
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    if (result != null) {
      file = result.files.first;
    }
    file_name.text = file.name;
    print(result.files.first.name);
    print(result.files.first.size);
    print(result.files.first.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Ajouter un nouveau bilan"),
        backgroundColor: AdminColorSeven,
      ),
      body: SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 400,
                      height: 80,
                      child: TextFormField(
                        controller: nomLaboratoireConroller,
                        decoration: InputDecoration(
                          labelText: 'Nom de laboratoire : ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        maxLines: 1,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Ce champ ne peut pas être vide';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      height: 80,
                      child: TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description de bilan : ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        maxLines: 1,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Ce champ ne peut pas être vide';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      height: 80,
                      child: DropdownSearch<String>(
                        items: widget.patientslist.map((patient) => patient.first_name + " " + patient.last_name).toList(),
                        dropdownBuilder: (context, selectedItem) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Sélectionner un Patient",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(selectedItem ?? '-'),
                          );
                        },
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
                    ),
                    SizedBox(
                      width: 400,
                      height: 80,
                      child: DropdownSearch<String>(
                        items: widget.docteurslist.map((docteur) => docteur.first_name + " " + docteur.last_name).toList(),
                        dropdownBuilder: (context, selectedItem) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Sélectionner un Docteur",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(selectedItem ?? '-'),
                          );
                        },
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
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 400,
                      height: 80,
                      child: TextFormField(
                        controller: file_name,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Nom du fichier : ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        maxLines: 1,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Ce champ ne peut pas être vide';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _pickFile,
                        child: Text('Choisir un fichier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 400,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            creerBilan();
                          }
                        },
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Ajouter Bilan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
