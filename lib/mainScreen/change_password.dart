import 'package:flutter/material.dart';
import 'package:plmqueuerv3/mainScreen/account_screen.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40,),
          Container(
            alignment: Alignment.topLeft,
            child: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const AccountScreen()));
                },
                icon: const Icon(Icons.arrow_back, color: Colors.black,)
            ),
          ),
          SizedBox(height: 100,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Change Password',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: TextFormField(
                style: const TextStyle(
                    color: Colors.black
                ),
                obscureText: true,
                decoration: InputDecoration(
                    labelStyle: const TextStyle(
                        color: Colors.black
                    ),
                    labelText: "Old Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: TextFormField(
                style: const TextStyle(
                    color: Colors.black
                ),
                obscureText: true,
                decoration: InputDecoration(
                    labelStyle: const TextStyle(
                        color: Colors.black
                    ),
                    labelText: "New Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: TextFormField(
                style: const TextStyle(
                    color: Colors.black
                ),
                obscureText: true,
                decoration: InputDecoration(
                    labelStyle: const TextStyle(
                        color: Colors.black
                    ),
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          MaterialButton(
            onPressed: (){
            },
            child: Text("Save"),
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}
