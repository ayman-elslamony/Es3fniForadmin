class UserData {
  String? docId;
  String? points;
  String? name;
  String? email;
  String? password;
  String? address;
  String? phoneNumber;
  String? nationalId;
  String? birthDate;
  String? gender;
  String? imgUrl;
  String? lat;
  String? lng;
  bool? isActive;
  String? aboutYou;
  String? specialization;
  String? specializationBranch;
  String? rating;
  bool loading;
  String? date;
  String? time;
  String? imgId;

  UserData(
      {this.docId,this.imgId,this.rating,
        this.date,this.time,
      this.specialization,
      this.specializationBranch,
      this.address,
      this.lat,
      this.lng,
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
      this.loading = false,
      this.birthDate});
}
