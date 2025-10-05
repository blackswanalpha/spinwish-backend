class RegisterRequest {
  final String emailAddress;
  final String username;
  final String password;
  final String confirmPassword;
  final String? phoneNumber;
  final String roleName;

  RegisterRequest({
    required this.emailAddress,
    required this.username,
    required this.password,
    required this.confirmPassword,
    this.phoneNumber,
    required this.roleName,
  });

  Map<String, dynamic> toJson() => {
        'emailAddress': emailAddress,
        'username': username,
        'password': password,
        'confirmPassword': confirmPassword,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'roleName': roleName,
      };

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
        emailAddress: json['emailAddress'],
        username: json['username'],
        password: json['password'],
        confirmPassword: json['confirmPassword'],
        phoneNumber: json['phoneNumber'],
        roleName: json['roleName'],
      );
}
