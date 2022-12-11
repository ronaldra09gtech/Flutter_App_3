import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:plmqueuerv3/mainScreen/Merchant/order_dertails_screen.dart';
import 'package:plmqueuerv3/mainScreen/paki_dala/booking_detail_screen.dart';
import 'package:plmqueuerv3/mainScreen/paki_dala/paki_dala_directions_details.dart';

import '../../global/global.dart';
import '../../models/booking_details.dart';

class NewBooking extends StatefulWidget {
  const NewBooking({Key? key}) : super(key: key);

  @override
  State<NewBooking> createState() => _NewBookingState();
}

class _NewBookingState extends State<NewBooking> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot> (
      stream: FirebaseFirestore.instance
          .collection("booking")
          .where("serviceType", isEqualTo: "paki-dala")
          .where("status", isEqualTo: "normal")
          .where("zone", isEqualTo: zone)
          .orderBy("orderTime", descending: true)
          .snapshots(),
      builder: (c, snapshot)
      {
        return snapshot.hasData
            ? snapshot.data!.size > 0
              ? ListView(
          children: snapshot.data!.docs.map((document){
            return InkWell(
              onTap: ()
              {
                BookingDetails bookingDetails =  BookingDetails();
                bookingDetails.bookID = document['bookID'];
                bookingDetails.clientUID = document['clientUID'];
                bookingDetails.dropoffaddress = document['dropoffaddress'];
                bookingDetails.dropoffaddresslat = document['dropoffaddressLat'];
                bookingDetails.dropoffaddresslng = document['dropoffaddressLng'];
                bookingDetails.pickupaddress = document['pickupaddress'];
                bookingDetails.pickupaddresslat = document['pickupaddressLat'];
                bookingDetails.pickupaddresslng = document['pickupaddressLng'];
                bookingDetails.notes = document['notes'];
                bookingDetails.price = document['price'].toString();
                bookingDetails.phoneNum = document['phoneNum'];
                bookingDetails.orderTime = document['orderTime'];
                bookingDetails.serviceType = document['serviceType'];
                bookingDetails.status = document['status'];
                bookingDetails.paymentmethod = document['paymentMethods'];

                Navigator.push(context, MaterialPageRoute(builder: (c)=> BookingDetailScreen(bookingDetails: bookingDetails,)));
              },

              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black12,
                        Colors.black12,
                      ],
                      begin:  FractionalOffset(0.0, 0.0),
                      end:  FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    )
                ),
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(CommunityMaterialIcons.package_variant_closed, size: 50),
                          SizedBox(width: 20,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "${document['notes']}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Text("Transaction ID: ${document['bookID']}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(thickness: 2,),
                      Text("Pick Up Address: "),
                      SizedBox(height: 2,),
                      Text(
                          "${document['pickupaddress']}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text("Drop Off Address: "),
                      SizedBox(height: 2,),
                      Text(
                          "${document['dropoffaddress']}",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )
              : const Center(child: Text("No Bookings yet"),)
            : const Center(child: Text("No Bookings yet"),);
      },
    );
  }
}
