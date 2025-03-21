class AppConstants {
  // App Information
  static const String appName = "EduGenius";
  static const String appVersion = "1.0.0";
  static const String appBuildNumber = "1";
  
  // API Endpoints
  static const String baseUrl = "https://api.edugenius.com/v1";
  static const String authEndpoint = "$baseUrl/auth";
  static const String userEndpoint = "$baseUrl/users";
  static const String classroomEndpoint = "$baseUrl/classrooms";
  static const String resourceEndpoint = "$baseUrl/resources";
  static const String assessmentEndpoint = "$baseUrl/assessments";
  static const String aiEndpoint = "$baseUrl/ai";
  
  // OpenAI API Constants
  static const String openAiBaseUrl = "https://api.openai.com/v1";
  static const String openAiChatEndpoint = "/chat/completions";
  
  // Supported Languages
  static const List<String> supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Hindi',
    'Arabic',
    'Portuguese',
    'Russian',
    'Japanese',
  ];
  
  // Shared Preferences Keys
  static const String userTokenKey = "user_token";
  static const String userDataKey = "user_data";
  static const String themeKey = "app_theme";
  static const String languageKey = "app_language";
  static const String onboardingCompletedKey = "onboarding_completed";
  
  // Default Values
  static const int defaultPageSize = 20;
  static const int apiTimeoutSeconds = 30;
  static const int cacheExpiryMinutes = 60;
  
  // File Storage Paths
  static const String userProfileImagePath = "profiles";
  static const String resourceFilesPath = "resources";
  static const String assessmentFilesPath = "assessments";
  
  // Feature Constants
  static const int maxFileUploadSizeMB = 10;
  static const int maxClassroomSize = 100;
  static const int maxQuestionCount = 50;
  
  // Error Messages
  static const String genericErrorMessage = "Something went wrong. Please try again.";
  static const String networkErrorMessage = "Unable to connect to the server. Please check your internet connection.";
  static const String authErrorMessage = "Authentication failed. Please log in again.";
  static const String permissionErrorMessage = "You don't have permission to perform this action.";
  static const String resourceNotFoundMessage = "The requested resource was not found.";
  
  // Success Messages
  static const String loginSuccessMessage = "Login successful!";
  static const String registrationSuccessMessage = "Registration successful!";
  static const String profileUpdateSuccessMessage = "Profile updated successfully!";
  static const String resourceUploadSuccessMessage = "Resource uploaded successfully!";
  static const String assessmentCreatedSuccessMessage = "Assessment created successfully!";
  
  // Validation Constants
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const String emailRegexPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // Animation Durations
  static const int shortAnimationDurationMs = 200;
  static const int mediumAnimationDurationMs = 500;
  static const int longAnimationDurationMs = 800;
}