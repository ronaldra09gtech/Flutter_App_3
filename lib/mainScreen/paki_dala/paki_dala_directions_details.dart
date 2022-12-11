import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plmqueuerv3/mainScreen/paki_dala/homescreen.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:intl/intl.dart';
import '../../assistantMethods/assistant_methods.dart';
import '../../global/global.dart';
import '../../models/booking_details.dart';
import '../../models/direction_details.dart';
import '../../widgets/loading_dialog.dart';

class PakiDalaDirectionScreen extends StatefulWidget {

  final BookingDetails? bookingDetails;
  PakiDalaDirectionScreen({this.bookingDetails});

  static final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(13.8848117, 122.2601717),
    zoom: 17,
  );

  @override
  State<PakiDalaDirectionScreen> createState() => _PakiDalaDirectionScreenState();
}

class _PakiDalaDirectionScreenState extends State<PakiDalaDirectionScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGMap = Completer();
  GoogleMapController? newGoogleMapController;
  Set<Marker> markers = {};
  Set<Circle> circles = {};  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  PolylinePoints polylinePoints = PolylinePoints();
  DirectionDetails? tripDirectionDetails;

  Position? currentPosition;

  double rideDetailsContainerHeight = 0;
  double dropOffContainerHeight = 0;
  double searchContainerHeight = 0;
  double signatureContainerHeight = 0;
  double bottomPaddingOfMap = 100;

  String signature="";

  final SignatureController _controller = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.blue
  );

  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    Navigator.pop(context);
  }

  displayRideDetailsContainer()
  {
    setState(() {
      searchContainerHeight=0;
      rideDetailsContainerHeight=240;
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

  displaySignatureContainer()
  {
    setState(() {
      searchContainerHeight=0;
      rideDetailsContainerHeight=0;
      dropOffContainerHeight=0;
      signatureContainerHeight=100;
      bottomPaddingOfMap = 100;
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

  confirmParcelHasBeenPicked(getOrderID)
  {
    FirebaseFirestore.instance
        .collection("booking")
        .doc(getOrderID).update({
      "status": "delivering",
      "riderUID": sharedPreferences!.getString("email"),
    });
  }

  uploadImage(mImageFile) async{
    var uniqueIDName = DateTime.now().millisecondsSinceEpoch.toString();

    fStorage.Reference reference =
    fStorage.FirebaseStorage.instance.ref().child("paki-dala-POD");

    fStorage.UploadTask uploadTask =
    reference.child(uniqueIDName + ".jpg").putFile(mImageFile);

    fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    FirebaseFirestore.instance
        .collection("booking")
        .doc(widget.bookingDetails!.bookID)
        .update({
      "pod": downloadURL,
      "status": "ended"
    }).whenComplete((){
      getRiderInfo();
      confirmParcelHasBeenDelivered(widget.bookingDetails!.bookID);
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

  confirmParcelHasBeenDelivered(getOrderID)
  {
    FirebaseFirestore.instance
        .collection("booking")
        .doc(getOrderID).update({
      "status": "ended",
    }).whenComplete((){
      if(widget.bookingDetails!.paymentmethod == "COD")
      {
        double subtotal = double.parse(widget.bookingDetails!.price.toString()) * double.parse(pakiDalafees);
        double newtotal = double.parse(widget.bookingDetails!.price.toString()) - subtotal;
        double newload = double.parse(load) - newtotal;

        FirebaseFirestore.instance
            .collection("pilamokoqueuer")
            .doc(sharedPreferences!.getString("email"))
            .update({
          "loadWallet":newload.round(),
        }).whenComplete(() {
          FirebaseFirestore.instance
              .collection("incometable")
              .doc(DateTime.now().millisecondsSinceEpoch.toString())
              .set({
            "servicetype":"paki-dala",
            "incomepercentage":subtotal,
            "bookID":widget.bookingDetails!.bookID,
            "logdate":DateTime.now().millisecondsSinceEpoch.toString(),
            "services":widget.bookingDetails!.serviceType,
            "year": DateFormat('yyyy').format(DateTime.now()),
            "month": DateFormat('MMM').format(DateTime.now()),
            "day": DateFormat('d').format(DateTime.now()),
            "date":DateFormat("dd MMMM, yyyy - hh:mm aa")
                .format(DateTime.fromMillisecondsSinceEpoch(int.parse(DateTime.now().millisecondsSinceEpoch.toString()))),
          }).whenComplete(() {
            stop = true;
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c)=> PakiDalaHomeScreen()));
          });
        });
      }
      else
      {
        double? price = double.parse(widget.bookingDetails!.price.toString());
        double subtotal = price *  double.parse(pakiDalafees);
        double total = price - subtotal;
        double newloadbal = double.parse(load) + total;
        FirebaseFirestore.instance
            .collection("pilamokoqueuer")
            .doc(sharedPreferences!.getString("email"))
            .update({
          "loadWallet":newloadbal.round(),
        }).whenComplete((){
          FirebaseFirestore.instance
              .collection("incometable")
              .doc(DateTime.now().millisecondsSinceEpoch.toString())
              .set({
            "incomepercentage":subtotal,
            "servicetype":"paki-dala",
            "logdate":DateTime.now().millisecondsSinceEpoch.toString(),
            "services":widget.bookingDetails!.serviceType,
            "year": DateFormat('yyyy').format(DateTime.now()),
            "month": DateFormat('MMM').format(DateTime.now()),
            "day": DateFormat('d').format(DateTime.now()),
            "date":DateFormat("dd MMMM, yyyy - hh:mm aa")
                .format(DateTime.fromMillisecondsSinceEpoch(int.parse(DateTime.now().millisecondsSinceEpoch.toString()))),
          }).whenComplete(() {
            stop = true;
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c)=> PakiDalaHomeScreen()));
          });
        });
      }
    });
  }

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              padding: const EdgeInsets.only(bottom: 100),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: PakiDalaDirectionScreen._kGooglePlex,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              polylines: polylineSet,
              markers: markers,
              circles: circles,
              onMapCreated: (GoogleMapController controller) async{
                _controllerGMap.complete(controller);
                newGoogleMapController = controller;
                showDialog(
                    context: context,
                    builder: (BuildContext context) => LoadingDialog(message: "Please Wait...",)
                );
                locatePosition();
              },
            ),
            Positioned(
              left: 0.0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                curve: Curves.bounceIn,
                duration: const Duration(milliseconds: 160),
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
                curve: Curves.bounceIn,
                duration: const Duration(milliseconds: 160),
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
                                  confirmParcelHasBeenPicked(widget.bookingDetails!.bookID!);
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
                                  var number = widget.bookingDetails!.phoneNum.toString();
                                  launch('tel://$number');
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
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text("Notes: "),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(widget.bookingDetails!.notes!),
                            ),
                          ],
                        )
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
                curve: Curves.bounceIn,
                duration: const Duration(milliseconds: 160),
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
                                  var number = widget.bookingDetails!.phoneNum.toString();
                                  launch('tel://$number');
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
                curve: Curves.bounceIn,
                duration: const Duration(milliseconds: 160),
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
                                      Text("Order Complete")
                                    ],
                                  ),
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
            ),
          ],
        )
    );
  }

  Future<void> getPlaceDirection() async
  {
    var pickUpLatLng = LatLng(currentPosition!.latitude, currentPosition!.longitude);
    var dropOffLatLng = LatLng(widget.bookingDetails!.pickupaddresslat!, widget.bookingDetails!.pickupaddresslng!);

    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(message: "Please Wait...",)
    );

    var details = await AssistantMethods.obtainDirectionDetails(pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult = polylinePoints.decodePolyline(details!.encodedPoints.toString());

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
    var dropOffLatLng = LatLng(widget.bookingDetails!.dropoffaddresslat!, widget.bookingDetails!.dropoffaddresslng!);

    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(message: "Please Wait...",)
    );

    var details = await AssistantMethods.obtainDirectionDetails(pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult = polylinePoints.decodePolyline(details!.encodedPoints.toString());

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