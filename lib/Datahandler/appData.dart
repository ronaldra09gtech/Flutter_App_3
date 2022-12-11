import 'package:flutter/cupertino.dart';
import '../models/address.dart';

class AppData extends ChangeNotifier
{
  Addressv2? pickUpLocation, dropOffLocation;

  void updatePickUpLocationAddress(Addressv2 pickUpAddress)
  {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Addressv2 dropOffAddress)
  {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}