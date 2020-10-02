class UserData {
  String docId;
  String points;
  String name;
  String email;
  String password;
  String address;
  String phoneNumber;
  String nationalId;
  String birthDate;
  String gender;
  String imgUrl;
  String lat;
  String lng;
  bool isActive;
  String aboutYou;
bool loading;
  UserData(
      {this.docId,
      this.address,
        this.lat,this.lng,
      this.nationalId,
      this.email,
        this.isActive,
        this.aboutYou,
      this.password,
      this.phoneNumber,
      this.name,
      this.points,
      this.imgUrl,
      this.gender,
        this.loading =false,
      this.birthDate});
}
