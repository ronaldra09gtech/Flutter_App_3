
class BookingDetails
{
  String? bookID, clientUID, dropoffaddress, pickupaddress, price, phoneNum, status, notes, paymentmethod, orderTime, serviceType;
  double? dropoffaddresslat, dropoffaddresslng, pickupaddresslng, pickupaddresslat;

  BookingDetails({
    this.serviceType,
    this.dropoffaddress,
    this.dropoffaddresslat,
    this.dropoffaddresslng,
    this.orderTime,
    this.notes,
    this.pickupaddress,
    this.pickupaddresslng,
    this.pickupaddresslat,
    this.clientUID,
    this.bookID,
    this.status,
    this.price,
    this.phoneNum,
    this.paymentmethod
  });
}