import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_frontend/authentication/context/authcontext.dart';
import 'package:pfe_frontend/authentication/models/user.dart';
import 'package:pfe_frontend/authentication/utils/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pfe_frontend/authentication/utils/colors.dart';
import 'package:pfe_frontend/radiologue/utils/radiologue_api.dart';

class CreerRadio extends StatefulWidget {
  final List<User> patientslist;
  final List<User> docteurslist;

  const CreerRadio({
    Key? key,
    required this.patientslist,
    required this.docteurslist,
  }) : super(key: key);

  @override
  State<CreerRadio> createState() => _CreerRadioState();
}

class _CreerRadioState extends State<CreerRadio> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = false;
  int _patient_id = 0;
  int _docteur_id = 0;
  var file;
  bool? disponible;
  String? patient_full_name = "";
  String? doctor_full_name = "";

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nomLaboratoireConroller = TextEditingController();
  TextEditingController patientCtl = TextEditingController();
  TextEditingController docteurCtl = TextEditingController();
  TextEditingController file_name = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
    nomLaboratoireConroller.dispose();
    patientCtl.dispose();
    docteurCtl.dispose();
    file_name.dispose();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void creerRadio() async {
    setStateIfMounted(() {
      _isLoading = true;
    });

    User currentuser = await AuthContext().getUserDetails();
    _setIds();

    String result = await RadioApiMethods().creerRadio(
      File(file.path),
      descriptionController.text,
      nomLaboratoireConroller.text,
      currentuser.id,
      _patient_id,
      _docteur_id,
    );

    setStateIfMounted(() {
      _isLoading = false;
    });

    if (result != "success") {
      showSnackBar("Une erreur est survenue, veuillez réessayer !", context);
    } else {
      showSnackBar("Enregistré avec succès !", context);
    }
  }

  void _setIds() {
    _patient_id = widget.patientslist[widget.patientslist.indexWhere(
        (p) => p.first_name + " " + p.last_name == patient_full_name)].getUserId();
    _docteur_id = widget.docteurslist[widget.docteurslist.indexWhere(
        (d) => d.first_name + " " + d.last_name == doctor_full_name)].getUserId();
  }

  void _pickFile() async {
    // Opens storage to pick files
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // If no file is picked
    if (result == null) return;
    file = result.files.first;
    file_name.text = file.name;

    // Log file details
    print(file.name);
    print(file.size);
    print(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Ajouter une image radio"),
        backgroundColor: AdminColorNine,
      ),
      body: SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh logic if needed
          },
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
                          labelText: 'Centre radio : ',
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
                          labelText: 'Description : ',
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
                        items: widget.patientslist
                            .map((patient) => patient.first_name + " " + patient.last_name)
                            .toList(),
                        dropdownBuilder: (context, selectedItem) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Sélectionner un Patient",
                              contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(selectedItem ?? ''),
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
                        items: widget.docteurslist
                            .map((docteur) => docteur.first_name + " " + docteur.last_name)
                            .toList(),
                        dropdownBuilder: (context, selectedItem) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Sélectionner un Docteur",
                              contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(selectedItem ?? ''),
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
                    MaterialButton(
                      onPressed: () {
                        _pickFile();
                      },
                      child: Text(
                        "Choisir le fichier qui contient les images pdf",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.teal,
                      textColor: Colors.white,
                    ),
                    TextField(
                      controller: file_name,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Aucun fichier sélectionné',
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          creerRadio();
                        }
                      },
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Enregistrer'),
                    ),
                    SizedBox(height: 20),
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
