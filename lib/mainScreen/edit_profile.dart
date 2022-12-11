import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

import '../global/global.dart';
import '../widgets/loading_dialog.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController zoneController = TextEditingController();

  XFile? imageXFile;
  String ImageUrl = "";
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isSubmit = false;
  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  getCurrentLocation() async {
    LocationPermission permission; permission = await Geolocator.requestPermission();
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks![0];

    completeAddress =
    '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    setState(() {
      zoneController.text = '${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea} ${pMark.administrativeArea}';
      zone = '${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea} ${pMark.administrativeArea}';
    });
    setState(() {
      isLoading = false;
      isSubmit = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = sharedPreferences!.getString("name")!;
    phoneController.text = sharedPreferences!.getString("phone")!;
    zoneController.text = zone;

  }

  editprofile() async {
    if(imageXFile != null){
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (c) {
            return LoadingDialog(
              message: "Updating",
            );
          });
      saveWithImage();
    }
    else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (c) {
            return LoadingDialog(
              message: "Updating",
            );
          });
      await FirebaseFirestore.instance
          .collection("pilamokoqueuer")
          .doc(sharedPreferences!.getString("email")!)
          .update({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "zone": zoneController.text.trim(),
      }).whenComplete(() async {
        await sharedPreferences!.setString("name", nameController.text);
        await sharedPreferences!.setString("phone", phoneController.text.trim());
        zone = zoneController.text;
        Fluttertoast.showToast(msg: "Profile Has been Edited");
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c)=> EditProfile()));

      });
    }
  }

  saveWithImage() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    fStorage.Reference reference = fStorage.FirebaseStorage.instance
        .ref()
        .child("pilamokoqueuer")
        .child(fileName);
    fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
    fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((url) {
      ImageUrl = url;
      //save info to firebase
      saveDataToFirestore();
    });
  }

  saveDataToFirestore() async {
    await FirebaseFirestore.instance
        .collection("pilamokoqueuer")
        .doc(sharedPreferences!.getString("email")!)
        .update({
      "name": nameController.text.trim(),
      "photoUrl": ImageUrl,
      "phone": phoneController.text.trim(),
      "zone": zoneController.text.trim(),
    }).whenComplete(() async {
      await sharedPreferences!.setString("photoUrl", ImageUrl);
      await sharedPreferences!.setString("phone", phoneController.text.trim());
      await sharedPreferences!.setString("name", nameController.text);
      zone = zoneController.text;
      Fluttertoast.showToast(msg: "Profile Has been Edited");
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (c)=> EditProfile()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 10,
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 1,
              child: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              ),
            ),
            const Positioned(
              top: 50,
              left: 50,
              child: Text(
                "Edit Profile",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
            Positioned(
              top: 40,
              right: 2,
              child: IconButton(
                onPressed: (){
                  if(_formKey.currentState!.validate()){
                    editprofile();
                  }
                },
                icon: Icon(Icons.check),
              ),
            ),
            Positioned(
              top: 80,
              left: MediaQuery.of(context).size.width* .30,
              child: InkWell(
                  onTap: () {
                    _getImage();
                  },
                  child: imageXFile == null
                      ? CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.20,
                    backgroundColor: Colors.white,
                    backgroundImage: const NetworkImage(
                        'https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png'
                    ),
                  )
                      : CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.20,
                    backgroundColor: Colors.white,
                    backgroundImage: imageXFile == null
                        ? null
                        : FileImage(File(imageXFile!.path)),
                    child: imageXFile == null
                        ? Icon(
                      Icons.add_photo_alternate,
                      size: MediaQuery.of(context).size.width * 0.20,
                      color: Colors.grey,
                    )
                        : null,

                  )
              )
            ),
            Positioned(
              top: 250,
              left: 2,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text("Tap the picture to change profile"),
                    Container(
                      width: MediaQuery.of(context).size.width * .95,
                      decoration:  BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      child: TextFormField(
                        controller: nameController,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusColor: Theme.of(context).primaryColor,
                          label: Text("Full Name"),
                        ),
                        validator: (value){
                          if(value!.isEmpty){
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .95,
                      decoration:  BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      child: TextFormField(
                        controller: phoneController,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusColor: Theme.of(context).primaryColor,
                          label: Text("Phone Number"),
                        ),
                        validator: (value){
                          if(value!.isEmpty){
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .95,
                      decoration:  BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      child: TextFormField(
                        enabled: false,
                        controller: zoneController,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusColor: Theme.of(context).primaryColor,
                          label: Text("Zone"),
                        ),
                        validator: (value){
                          if(value!.isEmpty){
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Need access in location to set your zone\nto get the orders in your area"),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5
                        ),
                      ),
                      onPressed: ()
                      {
                        if(!isLoading){
                          setState(() {
                            isLoading = true;
                            isSubmit = true;
                          });
                          getCurrentLocation();
                        }
                      },
                      child: isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Colors.white,
                        ),
                      )
                          :  const Text(
                        "Get my Current Location",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white
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
    );
  }
}
