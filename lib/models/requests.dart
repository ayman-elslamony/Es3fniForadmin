class Requests{
  bool isLoading;
  String docId;
  String patientId;
  String nurseId;
  String patientName;
  String patientPhone;
  String patientLocation;
  String patientAge;
  String patientGender;
  String numOfPatients;
  String serviceType;
  String analysisType;
  String nurseGender;
  String suppliesFromPharmacy;
  String picture;
  String discountCoupon;
  String startVisitDate;
  String endVisitDate;
  String visitDays;
  String visitTime;
  String notes;
  String discountPercentage;
  String priceBeforeDiscount;
  String priceAfterDiscount;
  String servicePrice;
  String date;
  String lat;
  String long;
  String distance;
  String acceptTime;
  String time;
  String specialization;String specializationBranch;
  Requests({this.distance,this.lat,this.long,this.specialization,this.specializationBranch,this.acceptTime,this.nurseId,this.date,this.time,this.servicePrice,this.discountPercentage,this.patientId,this.isLoading=false,this.docId,this.patientName, this.patientPhone, this.patientLocation,
    this.patientAge, this.patientGender, this.numOfPatients, this.serviceType,
    this.analysisType, this.nurseGender, this.suppliesFromPharmacy,
    this.picture, this.discountCoupon, this.startVisitDate, this.endVisitDate,
    this.visitDays, this.visitTime, this.notes, this.priceBeforeDiscount,
    this.priceAfterDiscount});


}