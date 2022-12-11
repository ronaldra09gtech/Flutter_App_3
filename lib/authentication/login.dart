import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plmqueuerv3/authentication/register.dart';
import 'package:plmqueuerv3/mainScreen/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/global.dart';
import '../mainScreen/homescreen.dart';
import '../widgets/error_dialog.dart';

class Login extends StatefulWidget {
  const   Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showpassword = true;
  bool isLoading = false;
  bool isSubmit = false;

  loginNow()async{
    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth){
      currentUser = auth.user!;
    }).catchError((error){
      setState(() {
        isSubmit = false;
        isLoading = false;
      });
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });
    if(currentUser != null)
    {
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async
  {
    await FirebaseFirestore.instance.collection("pilamokoqueuer")
        .doc(currentUser.email)
        .get()
        .then((snapshot) async {
      if(snapshot.exists){

        if(snapshot.data()!['isValidated']){
          await sharedPreferences!.setString("uid", currentUser.uid);
          await sharedPreferences!.setString("email", snapshot.data()!["pilamokoqueuerEmail"]);
          await sharedPreferences!.setString("name", snapshot.data()!["pilamokoqueuerName"]);
          await sharedPreferences!.setString("phone", snapshot.data()!["phone"]);
          if(snapshot.data()!["pilamokoqueuerAvatarUrl"] != null){
            await sharedPreferences!.setString("photoUrl", snapshot.data()!["pilamokoqueuerAvatarUrl"]);
          }
          else {
            await sharedPreferences!.setString("photoUrl", 'https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png');
          }
          await sharedPreferences!.setString("queuerType", snapshot.data()!["queuerType"]);
          zone = snapshot.data()!['zone'];
          previousRiderEarnings = snapshot.data()!['loadWallet'].toString();
          load = snapshot.data()!['loadWallet'].toString();
          Navigator.pop(context);
          if(snapshot.data()!["status"] == "approved")
          {
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const Services()));
          }
          else{
            firebaseAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const Login()));

            showDialog(
                context: context,
                builder: (c)
                {
                  return ErrorDialog(
                    message: "You're account is banned.",
                  );
                }
            );
          }
        }
        else {
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
                        firebaseAuth.signOut();
                        sharedPreferences!.clear();
                        setState(() {
                          isSubmit = false;
                          isLoading = false;
                        });
                        Navigator.pop(context);
                        final url = 'mailto:pilamokoofficial@gmail.com?subject=${Uri.encodeFull("Application Requirements for Queuer")}&body=${Uri.encodeFull("Please attach a copy of driver license vehicle registration and barangay clearance")}';
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
        }


      }
      else{
        firebaseAuth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const Login()));

        setState(() {
          isSubmit = false;
          isLoading = false;
        });
        showDialog(
            context: context,
            builder: (c)
            {
              return ErrorDialog(
                message: "No Record Found.",
              );
            }
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        color: Colors.blue,
        child: Stack(
          children: [
            Positioned(
              top: 2,
              left: 50,
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    "images/Pilamoko Login.png",
                    height: 270,
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 300,
              left: 10,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 75,
                ),
                child: Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                    color: Colors.white
                  ),
                ),
              ),
            ),
            Positioned(
              top: 300,
              left: MediaQuery.of(context).size.width * .03,
              child: Container(
                width: MediaQuery.of(context).size.width * .95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45.withOpacity(0.5),
                      spreadRadius: 1,
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
                            const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (c)=> const Register()));
                              },
                              child: const Text(
                                "SIGN UP",
                                style: TextStyle(
                                  color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .8,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: emailController,
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                            focusColor: Theme.of(context).primaryColor,
                            hintText: "Username",
                          ),
                          validator: (value){
                            if(value!.isEmpty){
                              return "Please input username";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .8,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: showpassword,
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            border: InputBorder.none,
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
                          validator: (value){
                            if(value!.isEmpty){
                              return "Please input password";
                            }
                            return null;
                          },
                        ),
                      ),
                      const Text("Forgot Password?",
                      textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 20,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          elevation: 10,
                          padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * .3,
                              vertical: 15
                          ),
                        ),
                        onPressed: ()
                        {
                          // formValidation();
                          //Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
                          if(!isLoading){
                            if (_formKey.currentState!.validate()) {
                              // formValidation();
                              setState(() {
                                isSubmit = true;
                                isLoading = true;
                              });
                              loginNow();
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
                            "LOGIN",
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
