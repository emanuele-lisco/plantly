class PerenualConfig {
  const PerenualConfig._();

  static const baseUrl = String.fromEnvironment(
    'PERENUAL_BASE_URL',
    defaultValue: 'https://perenual.com/api/v2',
  );

  static const apiKey = String.fromEnvironment('PERENUAL_API_KEY');

  static bool get hasApiKey => apiKey.trim().isNotEmpty;
}
