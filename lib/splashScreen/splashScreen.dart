import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plmqueuerv3/mainScreen/services/services.dart';

import '../authentication/login.dart';
import '../global/global.dart';
import '../mainScreen/homescreen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}


class _MySplashScreenState extends State<MySplashScreen>
{

  startTimer()
  {
    Timer(const Duration(seconds: 1), () async {
      //if user is login already
      if(firebaseAuth.currentUser != null){
        await FirebaseFirestore.instance.collection("pilamokoqueuer")
            .doc(sharedPreferences!.getString("email")!)
            .get().then((snapshot){
              previousRiderEarnings = snapshot.data()!['loadWallet'].toString();
              zone = snapshot.data()!['zone'].toString();
              load = snapshot.data()!['loadWallet'].toString();
        }).whenComplete((){
          FirebaseFirestore.instance.collection("perDelivery")
              .doc("paki-dala").get().then((snapshot) {
            pakiDalafees = snapshot.data()!['fees'].toString();
          }).whenComplete(() {
            FirebaseFirestore.instance.collection("perDelivery")
                .doc("paki-bili").get().then((snapshot) {
              emallfees = snapshot.data()!['percentage'].toString();
            }).whenComplete(() {
              Navigator.push(context, MaterialPageRoute(builder: (c)=> Services()));
            });
          });
        });
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const Login()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Image.asset("images/QUEUER.jpg", fit: BoxFit.cover,),
    );
  }
}

