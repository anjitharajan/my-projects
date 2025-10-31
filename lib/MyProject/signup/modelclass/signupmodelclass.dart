class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final String? role;
  final String? address;
  final String? adminCode;
  final String? image;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.role,
    this.address,
    this.adminCode,
    this.image,
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
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      name: map["name"],
      email: map["email"],
      password: map["password"],
      role: map["role"],
      address: map["address"],
      adminCode: map["adminCode"],
      image: map["image"],
    );
  }
}
