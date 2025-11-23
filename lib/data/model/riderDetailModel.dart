class RiderDetailModel {
  String? totalEarning;
  String? completeDelivery;
  String? cancelDelivery;
  String? pendingDeivery;

  RiderDetailModel(
      {this.totalEarning,
      this.completeDelivery,
      this.cancelDelivery,
      this.pendingDeivery});

  RiderDetailModel.fromJson(Map<String, dynamic> json) {
    totalEarning = json['total_earning'] ?? "0.0";
    completeDelivery = json['complete_delivery'] ?? "0";
    cancelDelivery = json['cancel_delivery'] ?? "0";
    pendingDeivery = json['pending_deivery'] ?? "0";
  }
}
