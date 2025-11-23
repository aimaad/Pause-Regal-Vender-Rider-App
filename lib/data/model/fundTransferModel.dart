class FundTransferModel {
  String? id;
  String? riderId;
  String? openingBalance;
  String? closingBalance;
  String? amount;
  String? status;
  String? message;
  String? dateCreated;

  FundTransferModel(
      {this.id,
      this.riderId,
      this.openingBalance,
      this.closingBalance,
      this.amount,
      this.status,
      this.message,
      this.dateCreated});

  FundTransferModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    riderId = json['rider_id'];
    openingBalance = json['opening_balance'];
    closingBalance = json['closing_balance'];
    amount = json['amount'];
    status = json['status'];
    message = json['message'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['rider_id'] = this.riderId;
    data['opening_balance'] = this.openingBalance;
    data['closing_balance'] = this.closingBalance;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['message'] = this.message;
    data['date_created'] = this.dateCreated;
    return data;
  }
}
