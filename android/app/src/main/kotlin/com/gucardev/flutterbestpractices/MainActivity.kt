package com.gucardev.flutterbestpractices

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth shows the system BiometricPrompt, which needs a FragmentActivity.
// With FlutterActivity authenticate() throws LocalAuthException(uiUnavailable).
class MainActivity : FlutterFragmentActivity()
