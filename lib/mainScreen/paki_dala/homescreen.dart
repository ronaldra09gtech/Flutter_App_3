import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:plmqueuerv3/mainScreen/paki_dala/booking_in_progress.dart';
import 'package:plmqueuerv3/mainScreen/paki_dala/new_booking.dart';

class PakiDalaHomeScreen extends StatefulWidget {
  const PakiDalaHomeScreen({Key? key}) : super(key: key);

  @override
  State<PakiDalaHomeScreen> createState() => _PakiDalaHomeScreenState();
}

class _PakiDalaHomeScreenState extends State<PakiDalaHomeScreen> {
  int currentIndex = 0;
  final screens = [
    NewBooking(),
    BookingInProgress(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              label: 'New Booking',
              backgroundColor: Color(0xFF262AAA)
          ),
          BottomNavigationBarItem(
              icon: Icon(CommunityMaterialIcons.bike_fast),
              label: 'Booking in Progress',
              backgroundColor: Color(0xFF262AAA)
          ),
        ],
      ),
    );
  }
}
