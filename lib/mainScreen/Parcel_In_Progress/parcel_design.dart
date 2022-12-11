import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/items.dart';
import '../Merchant/direction_details.dart';

class ParcelDesign extends StatelessWidget {
  final int? itemCount;
  final List<DocumentSnapshot>? data;
  final String? orderID;
  final List<String>? seperateQuantitiesList;

  ParcelDesign({
     this.itemCount,
     this.data,
     this.orderID,
     this.seperateQuantitiesList,
   });

  String? sellerID;
  double? sellerLat;
  double? sellerLng;
  String? sellerphone;
  String? client;
  String? clientphone;
  String? clientAddressID;
  double? clientLat;
  double? clientLng;

   getDetails(String orderID, BuildContext context) async {
     await FirebaseFirestore.instance.collection('orders')
         .doc(orderID).get().then((snapshot){
           sellerID = snapshot.data()!['sellerUID'];
           client = snapshot.data()!['orderBy'];
           clientAddressID = snapshot.data()!['addressID'];
         }).whenComplete(() async {
           await FirebaseFirestore.instance.collection('pilamokoemall')
               .doc(sellerID).get().then((doc){
                 sellerLat = doc.data()!['lat'];
                 sellerLng = doc.data()!['lng'];
                 sellerphone = doc.data()!['phone'];
           }).whenComplete(() async {
             await FirebaseFirestore.instance.collection("pilamokoclient")
                 .doc(client).collection("myDeliveryAddresses")
                 .doc(clientAddressID).get().then((snap) {
                  clientLat = snap.data()!['lat'] ;
                  clientLng = snap.data()!['lng'] ;
                  clientphone = snap.data()!['phone'];
             }).whenComplete((){
               Navigator.push(context, MaterialPageRoute(builder: (c)=> EmallDirectionDetails(
                 orderID: orderID,
                 purchaserlat: clientLat,
                 purchaserlng: clientLng,
                 sellerID: sellerID,
                 sellerLat: sellerLat,
                 sellerLng: sellerLng,
                 sellerphonenum: sellerphone,
                 clientnumber: clientphone,
                 cliendID: client,
               )));
             });
           });
     });
   }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        getDetails(orderID!, context);
      },
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black12,
                Colors.white54,
              ],
              begin:  FractionalOffset(0.0, 0.0),
              end:  FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            )
        ),
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        height: itemCount! * 125,
        child: ListView.builder(
          itemCount: itemCount,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index)
          {
            Items model = Items.fromJson(data![index].data()! as Map<String, dynamic>);
            return placedOrderDesignWidget(model, context, seperateQuantitiesList![index]);
          },
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(Items model, BuildContext context, seperateQuantitiesList)
{
  return Padding(
    padding: const EdgeInsets.all(3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.blueAccent)
            ),
            width: MediaQuery.of(context).size.width * 8,
            height: 100,
            child: Column(
              children: [
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: SizedBox(
                            height: 90,
                            width: 80,
                            child: Image.network(model.thumbnailUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(model.title!),
                            const SizedBox(height: 10),
                            Text(model.shopName!),
                            const SizedBox(height: 10),
                            Text("Qty: $seperateQuantitiesList"),
                            const SizedBox(height: 10),
                          ],
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.14),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text("₱ ${model.price!}"),
                            const SizedBox(height: 10),
                            const SizedBox(height: 10),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ],
            )
        ),
      ],
    ),
  );

}