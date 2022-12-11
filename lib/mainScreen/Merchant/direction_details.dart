import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plmqueuerv3/mainScreen/homescreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import '../../assistantMethods/assistant_methods.dart';
import '../../global/global.dart';
import '../../models/direction_details.dart';
import '../../widgets/loading_dialog.dart';

class EmallDirectionDetails extends StatefulWidget {
  double? purchaserlat;
  double? purchaserlng;
  String? clientnumber;
  String? orderID, sellerphonenum;
  String? sellerID, cliendID;
  double? sellerLat, sellerLng;

  EmallDirectionDetails({
    this.purchaserlat,
    this.purchaserlng,
    this.orderID,
    this.sellerID,
    this.sellerLng,
    this.sellerLat,
    this.sellerphonenum,
    this.clientnumber,
    this.cliendID
  });
  @override
  State<EmallDirectionDetails> createState() => _EmallDirectionDetailsState();
}

class _EmallDirectionDetailsState extends State<EmallDirectionDetails> with TickerProviderStateMixin {

  Completer<GoogleMapController> _controllerGMap = Completer();
  GoogleMapController? newGoogleMapController;
  Set<Marker> markers = {};
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  PolylinePoints polylinePoints = PolylinePoints();
  DirectionDetails? tripDirectionDetails;

  String placeID="";
  Position? currentPosition;

  double rideDetailsContainerHeight = 0;
  double dropOffContainerHeight = 0;
  double searchContainerHeight = 0;
  double signatureContainerHeight = 0;
  double bottomPaddingOfMap = 100;

  String signature="";
  String? serviceType;

  String? uniqueIDName;
  String orderTotalAmount = "0";
  String shippingfee = "0";

  bool working = true;

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(13.8848117, 122.2601717),
    zoom: 17,
  );

  var geolocator = Geolocator();

  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    Navigator.pop(context);
    // String address = await AssistantMethods.searchCoordinateAddress(position, context);
    // print(address);
  }

  displayRideDetailsContainer()
  {
    setState(() {
      searchContainerHeight=0;
      rideDetailsContainerHeight=240;
      bottomPaddingOfMap = 230;
    });
  }

  displaySignatureContainer()
  {
    setState(() {
      searchContainerHeight=0;
      rideDetailsContainerHeight=0;
      dropOffContainerHeight=0;
      signatureContainerHeight=150;
      bottomPaddingOfMap = 230;
    });
  }

  displayDropOffContainer()
  {
    setState(() {
      searchContainerHeight=0;
      rideDetailsContainerHeight=0;
      dropOffContainerHeight=240;
      bottomPaddingOfMap = 230;
    });
  }

  confirmParcelHasBeenPicked(getOrderID)
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderID).update({
      "status": "delivering",
      "riderUID": sharedPreferences!.getString("email"),
    });
  }
  bool stop=false;
  int timerr = 0;
  int minute = 0;

  void getLocationLiveUpdates()
  {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if(!stop)
      {
          timerr++;
      }
      if(stop)
      {
        timer.cancel();
      }

      if(timerr>=60)
      {
        minute++;
        timerr=0;
      }
      if(minute >=5){
        Position position2 = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        usersRef!.update({
          "lat": position2.latitude,
          "lng": position2.longitude,
        });
        LatLng latLatPosition = LatLng(position2.latitude, position2.longitude);
        CameraPosition cameraPosition = CameraPosition(target: latLatPosition, zoom: 14);
        newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        minute =0;
      }
    });
  }

  captureImageWithCamera() async {
    imageXFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 720,
      maxWidth: 1280,
    );
    setState(() {
      imageXFile;
    });

  }

  getOrderTotalAmount()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID)
        .get()
        .then((snap){
      orderTotalAmount = snap.data()!["totalAmount"].toString();
      shippingfee = snap.data()!["shippingFee"].toString();
      serviceType = snap.data()!["serviceType"].toString();
    }).then((value){
      if(serviceType == "eresto"){
        getSellerData();
      }
      else if(serviceType == "emall") {
        getEmallData();
      }
      else if(serviceType == "emarket") {
        getEmarketData();
      }
    });
  }

  getSellerData()
  {
    FirebaseFirestore.instance
        .collection("pilamokoseller")
        .doc(widget.sellerID)
        .get().then((snap){
      previousEarnings = snap.data()!["earning"].toString();
    });
  }

  getEmallData()
  {
    FirebaseFirestore.instance
        .collection("pilamokoemall")
        .doc(widget.sellerID)
        .get().then((snap){
      previousEarnings = snap.data()!["earning"].toString();
    });
  }

  getEmarketData()
  {
    FirebaseFirestore.instance
        .collection("pilamokoemarket")
        .doc(widget.sellerID)
        .get().then((snap){
      previousEarnings = snap.data()!["earning"].toString();
    });
  }


  @override
  void initState() {
    super.initState();
    getOrderTotalAmount();
  }

  @override
  void dispose() {
    homeTabPageStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(bottom: 100,top: 30),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            markers: markers,
            onMapCreated: (GoogleMapController controller) async{
              _controllerGMap.complete(controller);
              newGoogleMapController = controller;
              showDialog(
                barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => LoadingDialog(message: "Please Wait...",)
              );
              locatePosition();
            },
            buildingsEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: false,
            rotateGesturesEnabled: true,

          ),
          Positioned(
            left: 0.0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6,),
                      GestureDetector(
                        onTap: () async
                        {
                          getPlaceDirection();
                          displayRideDetailsContainer();
                          getLocationLiveUpdates();

                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6,
                                spreadRadius: 0.5,
                                offset: Offset(0.7,0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: const [
                                SizedBox(width: 10,),
                                Text("Show Pickup Location")
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7,0.7),
                      )
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.lightBlueAccent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16,),
                          child: Row(
                            children: [
                              Image.asset("images/signup.png",height: 70, width: 80,),
                              const SizedBox(width: 16,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Pickup Location", style: TextStyle(fontSize: 18, fontFamily: "Brand"),),
                                  Text(((tripDirectionDetails != null) ?tripDirectionDetails!.distanceText.toString() : ''), style: const TextStyle(fontSize: 18, color: Colors.black),),

                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectionDetails != null) ? tripDirectionDetails!.durationText.toString(): ''),
                                style: const TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6,),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            child: GestureDetector(
                              onTap: () async
                              {
                                getDropOffDirection();
                                displayDropOffContainer();
                                confirmParcelHasBeenPicked(widget.orderID!);
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7,0.7),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: const [
                                      Text("Parcel Has Been PickUp")
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            child: GestureDetector(
                              onTap: () async
                              {
                                var number = widget.sellerphonenum.toString();
                                launch('tel://$number');
                                print(number);
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7,0.7),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: const [
                                      Text("Call Seller")
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: dropOffContainerHeight,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7,0.7),
                      )
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.lightBlueAccent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16,),
                          child: Row(
                            children: [
                              Image.asset("images/signup.png",height: 70, width: 80,),
                              const SizedBox(width: 16,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Drop Off Location", style: TextStyle(fontSize: 18, fontFamily: "Brand"),),
                                  Text(((tripDirectionDetails != null) ?tripDirectionDetails!.distanceText.toString() : ''), style: const TextStyle(fontSize: 18, color: Colors.black),),

                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectionDetails != null) ? tripDirectionDetails!.durationText.toString(): ''),
                                style: const TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6,),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            child: GestureDetector(
                              onTap: () async
                              {
                                captureImageWithCamera();
                                displaySignatureContainer();
                                // confirmParcelHasBeenDelivered(widget.bookingDetails!.bookID!);
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7,0.7),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: const [
                                      Text("Parcel Has Been Delivered")
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            child: GestureDetector(
                              onTap: () async
                              {
                                var number = widget.clientnumber.toString();
                                launch('tel://$number');
                                print(number);
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7,0.7),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: const [
                                      Text("Call Client")
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: signatureContainerHeight,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7,0.7),
                      )
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: GestureDetector(
                          onTap: () async
                          {
                            if(imageXFile != null){
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) => LoadingDialog(message: "",)
                              );
                              uploadImage(File(imageXFile!.path));
                              setState(() {
                                stop = true;
                              });
                            }
                            else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) => LoadingDialog(message: "",)
                              );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total item amount: ₱ ${orderTotalAmount}"),
                              Text("Shipping fee: ₱ ${shippingfee}"),
                              Text("Total: ₱ ${double.parse(orderTotalAmount) + double.parse(shippingfee)}"),
                              SizedBox(height: 20,),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7,0.7),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: const [
                                      Text("Order Complete")
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  uploadImage(mImageFile) async{
    uniqueIDName = DateTime.now().millisecondsSinceEpoch.toString();

    storageRef.Reference reference =
    storageRef.FirebaseStorage.instance.ref().child("emallPOD");

    storageRef.UploadTask uploadTask =
    reference.child(uniqueIDName! + ".jpg").putFile(mImageFile);

    storageRef.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID)
        .update({
      "pod": downloadURL,
      "status": "ended"
    }).whenComplete((){
      getRiderInfo();
      confirmParcelHasBeenDelivered(widget.orderID, widget.sellerID, widget.cliendID);
    });
  }

  getRiderInfo() async {
    await FirebaseFirestore.instance.collection("pilamokoqueuer")
        .doc(sharedPreferences!.getString("email")!)
        .get().then((snapshot){
      previousRiderEarnings = snapshot.data()!['loadWallet'].toString();
      load = snapshot.data()!['loadWallet'].toString();
    });
  }

  confirmParcelHasBeenDelivered(getOrderID, sellerID, purchaserID)
  async {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderID)
        .get()
        .then((snapshot) async {
      if(snapshot.data()!['paymentDetails'] == "Cash on Delivery"){
        String sellerEarningAmount = (double.parse(orderTotalAmount) + double.parse(previousEarnings)).toString();

        double subtotal = (double.parse(orderTotalAmount) + double.parse(shippingfee)) * double.parse(emallfees);
        double newtotal = (double.parse(orderTotalAmount) + double.parse(shippingfee)) - subtotal;
        double riderNewTotalEarningAmount = double.parse(previousRiderEarnings) - newtotal;

        await FirebaseFirestore.instance
            .collection("orders")
            .doc(getOrderID)
            .update({
          "status": "ended",
        }).whenComplete(() async {
          await FirebaseFirestore.instance
              .collection("pilamokoqueuer")
              .doc(sharedPreferences!.getString("email"))
              .update({
            "loadWallet": riderNewTotalEarningAmount,
          }).then((value) async {
            await FirebaseFirestore.instance
                .collection("pilamokoemall")
                .doc(widget.sellerID)
                .update({
              "earning":double.parse(sellerEarningAmount), //total earnings amount of seller,
            }).whenComplete(() {
              FirebaseFirestore.instance
                  .collection("incometable")
                  .doc(DateTime.now().millisecondsSinceEpoch.toString())
                  .set({
                "servicetype":"emall",
                "incomepercentage":subtotal,
                "orderID":widget.orderID,
                "logdate":DateTime.now().millisecondsSinceEpoch.toString(),
                "services":widget.orderID,
                "year": DateFormat('yyyy').format(DateTime.now()),
                "month": DateFormat('MMM').format(DateTime.now()),
                "day": DateFormat('d').format(DateTime.now()),
                "date":DateFormat("dd MMMM, yyyy - hh:mm aa")
                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(DateTime.now().millisecondsSinceEpoch.toString()))),
              }).whenComplete(() {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));
              });
            });
          });
        });
      }
      else {
        double subtotal = (double.parse(orderTotalAmount) + double.parse(shippingfee)) * double.parse(emallfees);
        double newtotal = (double.parse(orderTotalAmount) + double.parse(shippingfee)) - subtotal;
        double riderNewTotalEarningAmount = double.parse(previousRiderEarnings) + newtotal;

        double sellerEarningAmount = (double.parse(orderTotalAmount) - subtotal) + double.parse(previousEarnings);

        await FirebaseFirestore.instance
            .collection("orders")
            .doc(getOrderID)
            .update({
          "status": "ended",
        }).then((value) async {
          await FirebaseFirestore.instance
              .collection("pilamokoqueuer")
              .doc(sharedPreferences!.getString("email"))
              .update({
            "loadWallet": riderNewTotalEarningAmount,
          }).then((value) async {
            await FirebaseFirestore.instance
                .collection("pilamokoemall")
                .doc(widget.sellerID)
                .update({
              "earning":sellerEarningAmount, //total earnings amount of seller,
            }).whenComplete(() {
              FirebaseFirestore.instance
                  .collection("incometable")
                  .doc(DateTime.now().millisecondsSinceEpoch.toString())
                  .set({
                "servicetype":"emall",
                "incomepercentage":subtotal,
                "orderID":widget.orderID,
                "logdate":DateTime.now().millisecondsSinceEpoch.toString(),
                "services":widget.orderID,
                "year": DateFormat('yyyy').format(DateTime.now()),
                "month": DateFormat('MMM').format(DateTime.now()),
                "day": DateFormat('d').format(DateTime.now()),
                "date":DateFormat("dd MMMM, yyyy - hh:mm aa")
                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(DateTime.now().millisecondsSinceEpoch.toString()))),
              }).whenComplete(() {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));
              });
            });
          });
        });
      }
    });
  }


  Future<void> getPlaceDirection() async
  {
    var pickUpLatLng = LatLng(currentPosition!.latitude, currentPosition!.longitude);
    var dropOffLatLng = LatLng(widget.sellerLat!, widget.sellerLng!);

    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(message: "Please Wait...",)
    );

    var details = await AssistantMethods.obtainDirectionDetails(pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details as DirectionDetails?;
    });

    Navigator.pop(context);
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult = polylinePoints.decodePolyline(details.encodedPoints.toString());

    pLineCoordinates.clear();
    if(decodedPolylinePointsResult.isNotEmpty)
    {
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });
    LatLngBounds latLngBounds;

    if(pickUpLatLng.latitude > dropOffLatLng.latitude && pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    }
    else if(pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude), northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    }
    else if(pickUpLatLng.latitude > dropOffLatLng.latitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude), northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    }
    else
    {
      latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds,70));

    Marker pickUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "My Location", snippet: "My Location"),
        position: pickUpLatLng,
        markerId: const MarkerId("pickUpId")
    );

    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "DropOff Location", snippet: "DropOff Location"),
        position: dropOffLatLng,
        markerId: const MarkerId("dropOffId")
    );

    setState(() {
      markers.add(pickUpLocMarker);
      markers.add(dropOffLocMarker);
    });
  }

  Future<void> getDropOffDirection() async
  {
    var pickUpLatLng = LatLng(currentPosition!.latitude, currentPosition!.longitude);
    var dropOffLatLng = LatLng(widget.purchaserlat!, widget.purchaserlng!);

    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(message: "Please Wait...",)
    );

    var details = await AssistantMethods.obtainDirectionDetails(pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult = polylinePoints.decodePolyline(details.encodedPoints.toString());

    pLineCoordinates.clear();
    if(decodedPolylinePointsResult.isNotEmpty)
    {
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });
    LatLngBounds latLngBounds;

    if(pickUpLatLng.latitude > dropOffLatLng.latitude && pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    }
    else if(pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude), northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    }
    else if(pickUpLatLng.latitude > dropOffLatLng.latitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude), northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    }
    else
    {
      latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds,70));

    Marker pickUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "My Location", snippet: "My Location"),
        position: pickUpLatLng,
        markerId: const MarkerId("pickUpId")
    );

    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "DropOff Location", snippet: "DropOff Location"),
        position: dropOffLatLng,
        markerId: const MarkerId("dropOffId")
    );

    setState(() {
      markers.add(pickUpLocMarker);
      markers.add(dropOffLocMarker);
    });
  }
}
