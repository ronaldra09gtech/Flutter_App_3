import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plmqueuerv3/authentication/login.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/global.dart';
import '../mainScreen/homescreen.dart';
import '../widgets/error_dialog.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool showpassword = true;
  bool showpassword2 = true;
  bool isChecked = false;

  bool isLoading = false;
  bool isSubmit = false;

  void signUp() async {
    User? currentUser;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      setState(() {
        isSubmit = false;
        isLoading = false;
      });
      showDialog(context: context, builder: (c) {
        return ErrorDialog(
          message: error.message.toString(),
        );
      });
    });

    if (currentUser != null) {
      readDataAndSetDataLocally(currentUser!).then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const Login()));
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c){
            return AlertDialog(
              content: Text("Please wait for the admin validate your application and please sent your requirements on this email pilamokoofficial@gmail.com"),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: ()
                  async {
                    final url = 'mailto:pilamokoofficial@gmail.com?subject=${Uri.encodeFull("Application Requirements for Queuer")}&body=${Uri.encodeFull("Please attach driver license vehicle registration and barangay clearance")}';
                      await launch(url);
                    },
                  child: const Center(
                    child: Text("OK"),
                  ),
                ),
              ],
            );
          }
        );
      });
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async
  {
    await FirebaseFirestore.instance.collection("pilamokoqueuer")
        .doc(currentUser.email)
        .get()
        .then((snapshot) async {
      if(snapshot.exists)
      {
        setState(() {
          isSubmit = false;
          isLoading = false;
        });
        firebaseAuth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const Register()));
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "Email Already Used",
              );
            });
      }
      else
      {
        saveDataToFirestore(currentUser);
      }
    });
  }

  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance
        .collection("pilamokoqueuer")
        .doc(currentUser.email)
        .set({
      "pilamokoqueuerUID": currentUser.uid,
      "pilamokoqueuerEmail": currentUser.email,
      "pilamokoqueuerName": "",
      "queuerType": "",
      "pilamokoqueuerAvatarUrl": "https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png",
      "userType": "queuer",
      "phone": phoneController.text.trim(),
      "status": "approved",
      "zone": "",
      "isValidated": false,
      "earning": 0.0,
      "loadWallet": 0.0,
    }).then((value){
      FirebaseFirestore.instance
          .collection("pilamokoQueuerAvailableDrivers")
          .doc(currentUser.email)
          .set({
        "email":currentUser.email,
        "lat": 0,
        "lng": 0,
        "status": "online",
      });
    });

    //save data locally
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("userType", "queuer");
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("name", '');
    await sharedPreferences!.setString("photoUrl", 'https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png');

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        color: Colors.blue,
        child: Stack(
          children: [
            const Positioned(
              top: 50,
              left: 10,
              child: Text(
                "REGISTRATION",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  color: Colors.white
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: MediaQuery.of(context).size.width * .02,
              child: Container(
                width: MediaQuery.of(context).size.width * .96,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(-5, 0)
                      ),
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(5, 0)
                      ),
                    ]
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:  [
                            InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (c)=> const Login()));
                              },
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (c)=> const Register()));
                              },
                              child: const Text(
                                "SIGN UP",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Colors.blue,
                            ),
                            focusColor: Theme.of(context).primaryColor,
                            hintText: "Phone Number",
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value){
                            if(value!.isEmpty){
                              return "This Field in required";
                            }
                            if(value.length < 11){
                              return "Phone Number length should not be less than 11";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.blue,
                            ),
                            focusColor: Theme.of(context).primaryColor,
                            hintText: "Email",
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value){
                            if(value!.isEmpty){
                              return "This Field in required";
                            }
                            if(!value.contains(RegExp('@'), 0)){
                              return 'Please input valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: showpassword,
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.blue,
                            ),
                            suffixIcon: InkWell(
                              onTap: (){
                                setState(() {
                                  showpassword = !showpassword;
                                });
                              },
                              child: Icon(
                                showpassword ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            focusColor: Theme.of(context).primaryColor,
                            hintText: "Password",
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value){
                            if(value!.isEmpty){
                              return "This Field in required";
                            }
                            if(value.length < 6){
                              return "Password length should not be less than 6";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          obscureText: showpassword2,
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.blue,
                            ),
                            suffixIcon: InkWell(
                              onTap: (){
                                setState(() {
                                  showpassword2 = !showpassword2;
                                });
                              },
                              child: Icon(
                                showpassword2 ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            focusColor: Theme.of(context).primaryColor,
                            hintText: "Confirm Password",
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value){
                            if(value!.isEmpty){
                              return "This Field in required";
                            }
                            if(value != passwordController.text){
                              return "Password did not match";
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    activeColor: Colors.blueAccent,
                                    tristate: true,
                                    onChanged: (newBool) {
                                      setState(() {
                                        isChecked = !isChecked;
                                      });
                                    },
                                  ),
                                  const Text("I agree to Pilamoko's",),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: (){
                                      // Navigator.push(context, MaterialPageRoute(builder: (c)=> TermsAndConditions()));
                                    },
                                    child: const Text("Terms & Conditons",
                                      style: TextStyle(
                                        color: Color(0xFF262AAA),
                                        fontWeight: FontWeight.w500,
                                      ),),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("and"),
                                  const SizedBox(width: 5,),
                                  InkWell(
                                    onTap: (){
                                      // Navigator.push(context, MaterialPageRoute(builder: (c) => PrivacyAndPolicy()));
                                    },
                                    child: const Text("Privacy Policy",
                                      style: TextStyle(
                                        color: Color(0xFF262AAA),
                                        fontWeight: FontWeight.w500,
                                      ),),
                                  )
                                ],
                              ),
                            ],
                          ),


                        ],
                      ),

                      const SizedBox(height: 30,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          elevation: 10,
                          padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * .3,
                              vertical: 15
                          ),
                        ),
                        onPressed: () {
                          if (!isLoading) {
                            if (_formKey.currentState!.validate()) {
                              // formValidation();
                              setState(() {
                                isSubmit = true;
                                isLoading = true;
                              });
                              signUp();
                            }
                          }
                        },
                        child: isSubmit
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        )
                            : const Text(
                          "SIGN UP",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white
                          ),
                        ),
                      ),
                      const SizedBox(height: 30,),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
