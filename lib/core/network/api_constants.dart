class EndPoint {
  static String baseUrl = "https://smartguide.runasp.net/api/";
  static String register = "Auth/register";
  static String login = "Auth/login";
  static String refreshToken = "Auth/refreshtoken";
  static String addRole = "Auth/addRole";
  static String forgotPassword = "Auth/forgot-password";
  static String resendOtp = "Auth/send-reset-otp";
  static String verifyCode = "Auth/verify-reset-otp";
  static String newPassword = "Auth/reset-password";
  static String googleSignIn = "Auth/google-login";
  static String logout = "Auth/logout";
  static String getPlaces = "places";
  static String getPlaceDetails({required String id}) => "places/$id";
  static String ratePlace({required String placeId}) => "Places/$placeId/rate";

  /// ================= SAVED PLACES =================

  static const String savedPlaces = "tourists/me/savedplaces";

  /// ================= TOUR GUIDES =================

  static const String tourGuides = "tour-guides";
  static String tourGuideProfile({required String id}) =>
      "tour-guides/$id/profile";

  /// ================= SAVED GUIDES (Favorites) =================
  static const String savedGuides = "tourists/me/savedguides";
  static String deleteSavedGuide({required String guideId}) =>
      "tourists/me/savedguides/$guideId";

  /// ================= TOURIST PROFILE =================
  static String touristProfile({required String id}) =>
      "tourists/$id/profile";

  /// ================= GUIDE DASHBOARD =================
  static const String guideDashboard = "guide/dashboard";
  static const String guideDashboardStatistics = "guide/dashboard/statistics";
  static const String guideDashboardDocuments = "guide/dashboard/documents";
  static const String guideDashboardEarnings = "guide/dashboard/earnings";
  static const String guideDashboardBookings = "guide/dashboard/bookings";
  static const String guideDashboardToursPerformance =
      "guide/dashboard/tours/performance";
  static const String guideDashboardWallet = "guide/dashboard/wallet";
  static const String guideDashboardWalletTransactions =
      "guide/dashboard/wallet/transactions";
  static const String guideDashboardActivities = "guide/dashboard/activities";
  static const String guideDashboardMyTours = "guide/dashboard/my-tours";
  static String guideDashboardTour({required String id}) =>
      "guide/dashboard/tour/$id";
  static String guideDashboardTourByPlace({required String placeId}) =>
      "guide/dashboard/tour/by-place/$placeId";
  static const String guideDashboardTourCreate =
      "guide/dashboard/tour/create";
  static String guideDashboardTourEdit({required String id}) =>
      "guide/dashboard/tour/edit/$id";

  /// ================= BOOKING & PAYMENT =================
  static const String createTourSlot = "tours/slots";
  static String tourSlots({required String tourId}) => "tours/$tourId/slots";
  static const String createBooking = "Bookings";
  static const String paymentCreateIntent = "payments/create-intent";
  static const String myBookings = "Bookings/my-bookings";
  static String cancelBooking({required String bookingId}) =>
      "Bookings/$bookingId";

  /// ================= GUIDE BOOKINGS FEED =================
  static const String guideBookings = "Bookings/guide-bookings";
  static String confirmBooking({required String bookingId}) =>
      "Bookings/$bookingId/confirm";

  /// ================= SIGNALR HUBS =================
  static const String chatHubUrl = 'https://smartguide.runasp.net/hubs/chat';

  /// ================= CHAT =================
  static String chatConversations({int page = 1, int pageSize = 30}) =>
      "chat/conversations?page=$page&pageSize=$pageSize";
  static const String chatStartConversation = "chat/conversations";
  static String chatGetConversation({required String conversationId}) =>
      "chat/conversations/$conversationId";
  static String chatMessages({
    required String conversationId,
    int pageSize = 30,
    String? beforeSentAtUtc,
  }) {
    var url =
        "chat/conversations/$conversationId/messages?pageSize=$pageSize";
    if (beforeSentAtUtc != null) url += "&beforeSentAtUtc=$beforeSentAtUtc";
    return url;
  }

  static String chatSendMessage({required String conversationId}) =>
      "chat/conversations/$conversationId/messages";
  static String chatEditMessage({required String messageId}) =>
      "chat/messages/$messageId";
  static String chatDeleteMessage({required String messageId}) =>
      "chat/messages/$messageId";
  static String chatMarkAsRead({required String conversationId}) =>
      "chat/conversations/$conversationId/read";
  static String chatBlockConversation({required String conversationId}) =>
      "chat/conversations/$conversationId/block";
  static String chatUnblockConversation({required String conversationId}) =>
      "chat/conversations/$conversationId/unblock";
}

class ApiKey {
  static const String statusCode = "statusCode";
  static const String message = "message";
  static const String firstName = "firstName";
  static const String lastName = "lastName";
  static const String email = "email";
  static const String username = "username";
  static const String phone = "phone";
  static const String password = "password";
  static const String image = "image";
  static const String token = "token";
  static const String refreshToken = "refreshToken";
  static const String id = "id";
  static const String name = "name";
  static const String confirmPassword = "confirmPassword";
  static const String location = "location";
  static const String idToken = "idToken";

  /// Authentication token prefix for Bearer-style authentication
  static const String tokenPrefix = "Bearer";

  /// ================= TOUR GUIDES KEYS =================

  static const String userId = "userId";
  static const String country = "country";
  static const String whatsAppNumber = "whatsAppNumber";
  static const String bio = "bio";
  static const String pricePerDay = "pricePerDay";
  static const String rating = "rating";
  static const String profilePicture = "profilePicture";
  static const String cities = "cities";
  static const String languages = "languages";
  static const String gallery = "gallery";
}
