import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? phone;
  String? name;
  String? id;
  String? email;
  String? address;

  UserModel({
   this.phone,
   this.email,
   this.name,
   this.id,
   this.address
});

  UserModel.fromSnapshot(DataSnapshot snap){
    phone = (snap.value as dynamic)["phone"];
    email = (snap.value as dynamic)["email"];
    name = (snap.value as dynamic)["name"];
    id = snap.key;
    address = (snap.value as dynamic)["address"];
  }
}