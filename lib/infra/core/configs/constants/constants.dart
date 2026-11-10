/// API server. Override per build without editing code, e.g.
///   flutter run --dart-define=API_BASE_URL=http://localhost:5000/
/// (must end with '/').
const String APIBaseURL = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://budgetcare-apis.mehdibalti.com/',
);

const String usertoken = 'usertoken';
const String kName = 'name';
const String kEmail = 'email';
const String kPhone = 'phone';
const String kId = 'Id';
const String kcreatedAt = 'createdAt';


