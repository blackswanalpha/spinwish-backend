class RegisterResponse {
  final String emailAddress;
  final String username;

  RegisterResponse({
    required this.emailAddress,
    required this.username,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
    emailAddress: json['emailAddress'],
    username: json['username'],
  );

  Map<String, dynamic> toJson() => {
    'emailAddress': emailAddress,
    'username': username,
  };
}
