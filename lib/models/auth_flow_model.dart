import 'package:firebase_auth/firebase_auth.dart';

import 'user_model.dart';

class OtpChallenge {
  final MultiFactorResolver resolver;
  final String verificationId;
  final int? resendToken;
  final String? phoneNumber;

  OtpChallenge({
    required this.resolver,
    required this.verificationId,
    this.resendToken,
    this.phoneNumber,
  });
}

class LoginFlowResult {
  final UserModel? user;
  final OtpChallenge? otpChallenge;

  LoginFlowResult._({this.user, this.otpChallenge});

  bool get requiresOtp => otpChallenge != null;

  factory LoginFlowResult.authenticated(UserModel user) =>
      LoginFlowResult._(user: user);

  factory LoginFlowResult.otpRequired(OtpChallenge otpChallenge) =>
      LoginFlowResult._(otpChallenge: otpChallenge);
}
