import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:pfe_frontend/authentication/context/authcontext.dart';
import 'package:pfe_frontend/authentication/models/user.dart';
import 'package:pfe_frontend/authentication/utils/colors.dart';
import 'package:pfe_frontend/authentication/utils/utils.dart';
import 'package:pfe_frontend/docteur/utils/doctor_api_methods.dart';

class CreerRapportMedicale extends StatefulWidget {
  final List<User> patientslist;
  const CreerRapportMedicale({Key? key, required this.patientslist})
      : super(key: key);

  @override
  State<CreerRapportMedicale> createState() => _CreerRapportMedicaleState();
}

class _CreerRapportMedicaleState extends State<CreerRapportMedicale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = false;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void creerRapportMedicale() async {
    setStateIfMounted(() {
      _isLoading = true;
    });
    User currentuser = await AuthContext().getUserDetails();
    _setIds();
    String result = await DoctorApiMethods().creerRapportMedicale(
      File(file.path),
      descriptionController.text,
      _patient_id,
      currentuser.id,
    );

    setStateIfMounted(() {
      _isLoading = false;
    });

    if (result != "success") {
      showSnackBar("Une erreur est survenue, veuillez réessayer !", context);
    } else {
      showSnackBar("Rapport médical ajouté avec succès !", context);
    }
  }

  void _setIds() {
    _patient_id = widget.patientslist[widget.patientslist.indexWhere(
            (p) => p.first_name + " " + p.last_name == patient_full_name)]
        .getUserId();
  }

  Client client = http.Client();

  TextEditingController descriptionController = TextEditingController();
  TextEditingController patientCtl = TextEditingController();
  TextEditingController file_name = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  DateTime dateRendezvous = DateTime.now();
  int _patient_id = 0;
  var file;
  bool? disponible;
  String? patient_full_name = "";

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
    patientCtl.dispose();
    file_name.dispose();
  }

  // Choisir le fichier pdf qui contient les analyses/bilans :
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
        title: Text("Ajouter un nouveau rapport"),
        backgroundColor: AdminColorSix,
      ),
      body: SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: () async {
            // _setUsers();
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
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description de rapport : ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
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
                            .map((patient) =>
                                patient.first_name + " " + patient.last_name)
                            .toList(),
                        dropdownBuilder: (context, selectedItem) =>
                            Text(selectedItem ?? "-"),
                        popupProps: PopupProps.bottomSheet(
                          searchFieldProps: TextFieldProps(
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
                        onChanged: (String? data) {
                          setState(() {
                            patient_full_name = data;
                          });
                        },
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        _pickFile();
                      },
                      child: Text(
                        "Choisir le rapport pdf",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: AdminColorSix,
                    ),
                    SizedBox(
                      width: 400,
                      height: 100,
                      child: TextFormField(
                        enabled: false,
                        controller: file_name,
                        decoration: InputDecoration(
                          labelText: 'Fichier choisi : ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColorSix),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print(_patient_id);
                            creerRapportMedicale();
                          }
                        },
                        child: Container(
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                )
                              : const Text('Enregistrer'),
                        ),
                      ),
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
