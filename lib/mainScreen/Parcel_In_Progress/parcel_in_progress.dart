import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plmqueuerv3/mainScreen/Parcel_In_Progress/parcel_design.dart';

import '../../assistantMethods/assistant_methods.dart';
import '../../global/global.dart';
import '../../widgets/progress_bar.dart';
import '../Merchant/order_card.dart';

class ParcelInProgress extends StatefulWidget {
  const ParcelInProgress({Key? key}) : super(key: key);

  @override
  State<ParcelInProgress> createState() => _ParcelInProgressState();
}

class _ParcelInProgressState extends State<ParcelInProgress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("riderUID", isEqualTo: sharedPreferences!.getString("email"))
            .where("status", whereIn: ["delivering","picking"])
            .orderBy("orderTime", descending: true)
            .snapshots(),
        builder: (c, snapshot)
        {
          return snapshot.hasData
              ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (c, index)
            {
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("items")
                    .where("itemID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>) ["productIDs"]))
                    .orderBy("publishDate", descending: true)
                    .get(),
                builder: (c, snap)
                {
                  return snap.hasData
                      ? ParcelDesign(
                    itemCount: snap.data!.docs.length,
                    data: snap.data!.docs,
                    orderID: snapshot.data!.docs[index].id,
                    seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productIDs"]),
                  )
                      : Center(child: circularProgress());
                },
              );
            },
          )
              : Center(child: circularProgress(),);
        },
      ),
    );
  }
}
