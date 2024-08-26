import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pfe_frontend/admin/utils/dimensions.dart';
import 'package:pfe_frontend/authentication/utils/colors.dart';
import 'package:provider/provider.dart';



class AdminMobileScreenLayout extends StatefulWidget {
  const AdminMobileScreenLayout({ Key? key }) : super(key: key);

  @override
  State<AdminMobileScreenLayout> createState() => _AdminMobileScreenLayoutState();
}

class _AdminMobileScreenLayoutState extends State<AdminMobileScreenLayout> {

  @override
  Widget build(BuildContext context) {
     return DefaultTabController(
         length: 3,
         child: Scaffold(
          appBar:  PreferredSize(
          preferredSize: Size.fromHeight(50.0), // here the desired height
          child: AppBar(
            //  backgroundColor:thirdAdminColor ,
             automaticallyImplyLeading: false,
             bottom: TabBar(
               tabs: [
                 Tab(text: "Accueil",),
                 Tab(text: "Creer",),
                 Tab(text: "Profile",),
               ]
               ),
           ),),
           body: TabBarView(
             children: adminHomeScreenItems,
           ),
         ),
        );
  }
}
