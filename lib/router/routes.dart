/// Every location in one place — no string typos across the app.
abstract final class Routes {
  static const home = '/';
  static const login = '/login';

  static const products = '/products';
  static String productsSortedBy(String sort) =>
      Uri(path: products, queryParameters: {'sort': sort}).toString();
  static String productDetail(String id) => '$products/$id';

  static const profile = '/profile';
  static const editProfile = '/profile/edit';

  /// Protected route: data goes in the URL (not `extra`) so it survives the login redirect.
  static const checkout = '/checkout';
  static String checkoutFor(String productId) =>
      Uri(path: checkout, queryParameters: {'productId': productId}).toString();

  static const orderComplete = '/order-complete';
  static String orderCompleteFor(String orderId) =>
      Uri(path: orderComplete, queryParameters: {'orderId': orderId}).toString();

  static const deviceInfo = '/demos/device-info';
  static const connectivity = '/demos/connectivity';
  static const appSettings = '/demos/app-settings';
  static const signUpForm = '/demos/form';
  static const formFields = '/demos/form-fields';
  static const hiveNotes = '/demos/hive';
  static const driftTodos = '/demos/drift';
  static const images = '/demos/images';
  static const photoViewer = '/demos/images/viewer';
  static const pdf = '/demos/pdf';
  static const permissions = '/demos/permissions';
  static const bluetooth = '/demos/bluetooth';
  static const environment = '/demos/environment';
  static const biometric = '/demos/biometric';
  static const review = '/demos/review';
  static const threeD = '/demos/3d';
  static const otp = '/demos/otp';
  static const onboarding = '/demos/onboarding';
  static const tour = '/demos/tour';
  static const tilt = '/demos/tilt';
  static const textToSpeech = '/demos/text-to-speech';
  static const speechToText = '/demos/speech-to-text';
  static const screenProtector = '/demos/screen-protector';
  static const qrCode = '/demos/qr-code';
  static const chat = '/demos/chat';
  static const stories = '/demos/stories';
  static const storyViewer = '/demos/stories/:groupId';
  static String storyViewerFor(String groupId) => '$stories/$groupId';
  static const imageCrop = '/demos/image-crop';
  static const documentScanner = '/demos/document-scanner';
  static const uniqueIds = '/demos/unique-ids';

  /// Locations that require a signed-in user (prefix match).
  static const protectedPrefixes = [profile, checkout];
}
