class LoginRequest {
  final String emailAddress;
  final String password;

  LoginRequest({
    required this.emailAddress,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'emailAddress': emailAddress,
    'password': password,
  };

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    emailAddress: json['emailAddress'],
    password: json['password'],
  );
}
