import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio de IA con Gemini o modelo generativo para educación financiera
class GeminiService {
  final String _apiKey = 'YOUR_GEMINI_API_KEY'; // Reemplázalo con tu API Key real
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  /// Envía un prompt y devuelve la respuesta generada
  Future<String> getFinancialAdvice(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Eres un asistente financiero. Responde con consejos simples y útiles. $prompt"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        return "Hubo un error al consultar la IA.";
      }
    } catch (e) {
      return "Error al conectar con el asistente financiero: $e";
    }
  }
}
