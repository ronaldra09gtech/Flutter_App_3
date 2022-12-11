import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plmqueuerv3/authentication/login.dart';

import '../global/global.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<bool?> showWarning(BuildContext context) async =>  showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Do you want to Log out?"),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (c) => const Login() ));
              },
              child: const Text("Yes")
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")
          ),
        ],
      )
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        final shouldPop = await showWarning(context);
        return shouldPop ?? false;
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 60,
          left: 10,
          right: 10,
        ),        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF262AAA),
                ),
                height: 120,
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Balance",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("pilamokoqueuer")
                          .where("pilamokoqueuerEmail", isEqualTo: sharedPreferences!.getString("email"))
                          .snapshots(),
                      builder:  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                        if (snapshot.hasData) {
                          if(snapshot.data!.size > 0){
                            return Column(
                              children: snapshot.data!.docs.map((document){
                                  previousRiderEarnings = document['loadWallet'].toString();
                                  zone = document['zone'].toString();
                                return Text(
                                  "₱ ${document['loadWallet']}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold
                                  ),
                                );
                              }).toList(),
                            );
                          }
                          else {
                            return const Text(
                              "₱ 0",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                              ),
                            );
                          }
                        }
                        else {
                          return const Text(
                            "₱ 0",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold
                            ),
                          );
                        }

                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Divider(
                  thickness: 2,
                  color: Colors.blueAccent.shade400
              ),
              const SizedBox(height: 15,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Trasnsaction History",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        color: Colors.blueAccent.shade400
                    ),
                  ),
                  Text("See All",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        color: Colors.blueAccent.shade400
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("tlpLoadTransactions")
                    .where("pilamokoqueuerEmail", isEqualTo: sharedPreferences!.getString("email"))
                    .orderBy("loadTransferTime", descending: true)
                    .limit(4)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (snapshot.hasData) {
                    if (snapshot.data!.size > 0) {
                      return Column(
                    children: snapshot.data!.docs.map((document){
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DateFormat("dd MMMM, yyyy")
                                        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['loadTransferTime'])))),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.30),
                                    // ignore: prefer_interpolation_to_compose_strings
                                    Text("₱"+document['amount']),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                    } else {
                      return Text("Theres no record");
                    }
                  } else {
                    return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: Text("Theres no record"),),
                      );
                  }
                },
              ),
              Divider(
                  thickness: 2,
                  color: Colors.blueAccent.shade400
              ),
              const SizedBox(height: 15,),
            ],
          ),
        ),
      ),
    );
  }
}
