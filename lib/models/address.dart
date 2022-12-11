class Address
{
  String? name;
  String? phoneNumber;
  String? address;
  double? lat;
  double? lng;

  Address({
    this.name,
    this.phoneNumber,
    this.address,
    this.lat,
    this.lng,
  });

  Address.fromJson(Map<String, dynamic> json)
  {
    name = json['name'];
    phoneNumber = json['phone'];
    address = json['address'];
    lat = double.parse(json['lat'].toString()) ;
    lng = double.parse(json['lng'].toString()) ;
  }

  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['phone'] = phoneNumber;
    data['address'] = address;
    data['lat'] = lat;
    data['lng'] = lng;

    return data;
  }
}

class Addressv2
{
  String? placeFormattedAddress;
  String? placename;
  String? placeID;
  double? latitude;
  double? longitude;

  Addressv2({
    this.placeFormattedAddress,
    this.latitude,
    this.longitude,
    this.placeID,
    this.placename
  });
}