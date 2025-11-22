class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final String? role;
  final String? address;
  final String? adminCode;
  final String? image;
  final String? code;
  final String? contact;
  final String? createdAt;
  final bool? linked; 
  final String? authUid; 
    final String? hospitalId;
  final String? hospitalName;
    final String? doctorId; 


  UserModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.role,
    this.address,
    this.adminCode,
    this.image,
    this.code,
    this.contact,
    this.createdAt,
    this.linked,
    this.authUid,
    this.hospitalId,     
    this.hospitalName, 
     this.doctorId, 
    
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "password": password,
      "role": role,
      "address": address,
      "adminCode": adminCode,
      "image": image,
      "code": code,
      "contact": contact,
      "createdAt": createdAt,
      "linked": linked,
      "authUid": authUid,
      "hospitalId": hospitalId,       
      "hospitalName": hospitalName,
       "doctorId": doctorId,
   
 
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      name: map["name"],
      email: map["email"],
      password: map["password"],
        role: map['role'],
      address: map["address"],
      adminCode: map["adminCode"],
      image: map["image"],
        code: map["code"],
      contact: map["contact"],
      createdAt: map["createdAt"],
      linked: map["linked"],
      authUid: map["authUid"],
        hospitalId: map["hospitalId"],       
      hospitalName: map["hospitalName"], 
        doctorId: map['doctorId'], 

    );
  }

 
}
