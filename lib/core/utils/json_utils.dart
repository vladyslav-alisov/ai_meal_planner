import 'dart:convert';

class JsonUtils {
  static Map<String, dynamic> decodeJsonObject(String source) {
    try {
      final cleaned = source
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }

      throw const FormatException('Expected JSON object.');
    } catch (_) {
      throw const FormatException('Failed to decode JSON object.');
    }
  }
}
