import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../assistantMethods/assistant_methods.dart';
import '../../global/global.dart';
import '../../widgets/progress_bar.dart';
import 'order_card.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({Key? key}) : super(key: key);

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot> (
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("status", isEqualTo: "ready")
            .where("serviceType", isEqualTo: "emall")
            .where("zone", isEqualTo: zone)
            .orderBy("orderTime", descending: true)
            .snapshots(),
        builder: (c, snapshot)
        {
          if(snapshot.hasData){
            print(snapshot.data!.docs.length);
          }
          return snapshot.hasData
                ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (c, index)
            {
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("items")
                    .where("itemID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>) ["productIDs"]))
                    .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                    .orderBy("publishDate", descending: true)
                    .get(),
                builder: (c, snap)
                {
                  return snap.hasData
                      ? OrderCard(
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
