import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plmqueuerv3/global/global.dart';
import 'package:plmqueuerv3/mainScreen/paki_dala/homescreen.dart';
import 'package:plmqueuerv3/mainScreen/paki_dala/new_booking.dart';
import 'package:plmqueuerv3/mainScreen/paki_dala/paki_dala_directions_details.dart';
import 'package:plmqueuerv3/widgets/error_dialog.dart';

import '../../models/booking_details.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingDetails? bookingDetails;

  BookingDetailScreen({this.bookingDetails});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {

  Future<bool?> showWarning(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (c)=> PakiDalaHomeScreen()));
  }

  acceptbooking()async{

    await FirebaseFirestore.instance.collection("booking")
        .doc(widget.bookingDetails!.bookID).get().then((snapshot) async {
          if(snapshot.data()!['riderUID'] == '' ){
            await FirebaseFirestore.instance.collection("booking")
                .doc(widget.bookingDetails!.bookID).update({
              "riderUID": sharedPreferences!.getString("email"),
              "status": "accepted"
            }).whenComplete((){
              Navigator.push(context, MaterialPageRoute(builder: (c)=> PakiDalaDirectionScreen(bookingDetails: widget.bookingDetails,)));
            });
          }
          else {
            if(snapshot.data()!['riderUID'] == sharedPreferences!.getString("email")) {
              Navigator.push(context, MaterialPageRoute(builder: (c)=> PakiDalaDirectionScreen(bookingDetails: widget.bookingDetails,)));
            }
            else {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c){
                    return AlertDialog(
                      content: Text("This booking is already accepted by another queuer."),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: ()
                          {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Center(
                            child: Text("OK"),
                          ),
                        ),
                      ],
                    );
                  }
              );
            }
          }

    });
    // Navigator.push(context, MaterialPageRoute(builder: (c)=> PakiDalaDirectionScreen(bookingDetails: widget.bookingDetails,)));

  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        final shouldPop = await showWarning(context);
        return shouldPop ?? false;
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.only(top: 20, right: 8, left: 8, bottom: 8,),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Transaction ID"),
                        const SizedBox(width: 54,),
                        Expanded(child: Text("${widget.bookingDetails!.bookID}"))
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey,),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("What Item"),
                        const SizedBox(width: 75,),
                        Expanded(child: Text("${widget.bookingDetails!.notes}"))
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey,),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Pick up Address"),
                        const SizedBox(width: 45,),
                        Expanded(child: Text("${widget.bookingDetails!.pickupaddress}"))
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey,),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Drop Off Address"),
                        const SizedBox(width: 40,),
                        Expanded(child: Text("${widget.bookingDetails!.dropoffaddress}"))
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey,),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Payment Type "),
                        const SizedBox(width: 53,),
                        Expanded(child: Text("${widget.bookingDetails!.paymentmethod}"))
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey,),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Booking Created "),
                        const SizedBox(width: 40,),
                        Expanded(child: Text(DateFormat("dd MMMM, yyyy - hh:mm aa")
                            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.bookingDetails!.orderTime.toString())))))
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey,),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Phone Number "),
                        const SizedBox(width: 49,),
                        Expanded(child: Text("${widget.bookingDetails!.phoneNum}"))
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey,),
                    const SizedBox(height: 10),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.blueAccent.shade400
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * .4,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text("Go Back",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blueAccent.shade400,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            acceptbooking();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.blueAccent.shade400
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * .4,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text("Accept",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blueAccent.shade400,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }
}
