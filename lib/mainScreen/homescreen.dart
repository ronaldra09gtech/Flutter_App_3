import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:plmqueuerv3/mainScreen/account_screen.dart';
import 'package:plmqueuerv3/mainScreen/Parcel_In_Progress/parcel_in_progress.dart';
import 'package:plmqueuerv3/mainScreen/services/services.dart';
import '../authentication/login.dart';
import '../global/global.dart';
import 'Merchant/new_order_Screen.dart';
import 'home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final screens = [
    const Home(),
    const NewOrderScreen(),
    ParcelInProgress(),
    const AccountScreen()
  ];

  Future<bool?> showWarning(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (c)=> Services()));
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        final shouldPop = await showWarning(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          type: BottomNavigationBarType.shifting,
          currentIndex: currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: (index) => setState(() => currentIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CommunityMaterialIcons.home_circle_outline),
                label: 'Home',
                backgroundColor: Color(0xFF262AAA)
            ),
            BottomNavigationBarItem(
                icon: Icon(CommunityMaterialIcons.clipboard_text_multiple_outline),
                label: 'New Orders',
                backgroundColor: Color(0xFF262AAA)
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.airport_shuttle),
                label: 'Parcels in Progress',
                backgroundColor: Color(0xFF262AAA)
            ),
            BottomNavigationBarItem(
                icon: Icon(CommunityMaterialIcons.account_settings),
                label: 'Account',
                backgroundColor: Color(0xFF262AAA)
            ),
          ],
        ),
      ),
    );
  }
}
