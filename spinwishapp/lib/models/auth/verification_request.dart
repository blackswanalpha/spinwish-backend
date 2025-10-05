class VerificationRequest {
  final String emailAddress;
  final String verificationCode;
  final String verificationType; // "EMAIL" or "PHONE"

  VerificationRequest({
    required this.emailAddress,
    required this.verificationCode,
    required this.verificationType,
  });

  Map<String, dynamic> toJson() => {
        'emailAddress': emailAddress,
        'verificationCode': verificationCode,
        'verificationType': verificationType,
      };

  factory VerificationRequest.fromJson(Map<String, dynamic> json) =>
      VerificationRequest(
        emailAddress: json['emailAddress'],
        verificationCode: json['verificationCode'],
        verificationType: json['verificationType'],
      );
}

class SendVerificationRequest {
  final String emailAddress;
  final String verificationType; // "EMAIL" or "PHONE"

  SendVerificationRequest({
    required this.emailAddress,
    required this.verificationType,
  });

  Map<String, dynamic> toJson() => {
        'emailAddress': emailAddress,
        'verificationType': verificationType,
      };

  factory SendVerificationRequest.fromJson(Map<String, dynamic> json) =>
      SendVerificationRequest(
        emailAddress: json['emailAddress'],
        verificationType: json['verificationType'],
      );
}
