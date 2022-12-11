import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:plmqueuerv3/authentication/login.dart';
import 'package:plmqueuerv3/global/global.dart';
import 'package:plmqueuerv3/mainScreen/change_password.dart';
import 'package:plmqueuerv3/mainScreen/edit_profile.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0,left: 10,right: 10,bottom: 10),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> EditProfile()));
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.10,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(
                          sharedPreferences!.getString('photoUrl')!
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Text(
                      sharedPreferences!.getString("name")! == '' ? "Anonymous" : sharedPreferences!.getString("name")!,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: ListTile(
                leading: const Icon(CommunityMaterialIcons.account_lock, color: Colors.black),
                title: const Text(
                  "Change Password",
                  style: TextStyle(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                tileColor: Colors.grey.withOpacity(0.2),
                trailing: const Icon(Icons.arrow_right, color: Colors.black),
                onTap: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> ChangePassword()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: ListTile(
                leading: const Icon(CommunityMaterialIcons.account_supervisor, color: Colors.black),
                title: const Text(
                  "My TLP",
                  style: TextStyle(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                tileColor: Colors.grey.withOpacity(0.2),
                trailing: const Icon(Icons.arrow_right, color: Colors.black),
                onTap: ()
                {

                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: ListTile(
                leading: const Icon(CommunityMaterialIcons.car_brake_alert, color: Colors.black),
                title: const Text(
                  "Support",
                  style: TextStyle(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                tileColor: Colors.grey.withOpacity(0.2),
                trailing: const Icon(Icons.arrow_right, color: Colors.black),
                onTap: ()
                {

                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: ListTile(
                leading: const Icon(CommunityMaterialIcons.logout, color: Colors.black),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                tileColor: Colors.grey.withOpacity(0.2),
                onTap: ()
                {
                  firebaseAuth.signOut().then((value){
                    sharedPreferences!.clear();
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> const Login()));

                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
