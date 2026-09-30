import 'dart:convert';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //static String get baseUrl {
  //return 'https://rolsworldbusiness.alwaysdata.net/api';

  static String baseUrl = 'https://kinstore.alwaysdata.net/api';

  // static String get baseUrl {
  //   if (kIsWeb) {
  //     return 'http://localhost:8000/api';
  //   } else if (Platform.isAndroid) {
  //     return 'http://10.0.2.2:8000/api';
  //   } else if (Platform.isIOS) {
  //     return 'http://localhost:8000/api';
  //   }
  //   return 'http://localhost:8000/api';
  // }

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user';

  //Soumission de la logique de connexion
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur de connexion lors de la connexion';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  //Sauvegarde des donnees de l'utilisateur connecter
  static Future<void> sauvegardeDonneesUser(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else {
      await prefs.setString(key, jsonEncode(value));
    }
  }

  //Recuperation des donnees de l'utilisateur connecter
  static Future<dynamic> recupererDonneesUser(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data != null) {
      try {
        return jsonDecode(data);
      } catch (e) {
        // Si ce n'est pas du JSON, retourner la chaîne brute
        return data;
      }
    }
    return null;
  }

  //Récupérer le token d'authentification
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  //Créer les headers avec authentification
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur de connexion lors de la connexion';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  static Future<List<dynamic>> getChaussures() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/liste-chaussures'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['chaussures'] ?? [];
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur lors de la récupération des chaussures';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  static Future<List<dynamic>> getVentes() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/liste-ventes'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ventes'] ?? [];
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur lors de la récupération des ventes';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> enregistrerVente(
    Map<String, dynamic> venteData,
  ) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/enregistrer-vente'),
        headers: headers,
        body: jsonEncode(venteData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur lors de l\'enregistrement de la vente';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  static Future<List<dynamic>> getDepenses() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/liste-depenses'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['depenses'] ?? [];
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur lors de la récupération des dépenses';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        // Supprimer les données locales
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        await prefs.remove(_userKey);
      } else {
        throw Exception('Erreur lors de la déconnexion');
      }
    } catch (e) {
      // En cas d'erreur, supprimer quand même les données locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  // CRUD Dépenses
  static Future<Map<String, dynamic>> createDepense(
    Map<String, dynamic> depenseData,
  ) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/creation-depense'),
        headers: headers,
        body: jsonEncode(depenseData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur lors de la création de la dépense';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> updateDepense(
    String id,
    Map<String, dynamic> depenseData,
  ) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/modifier-depense/$id'),
        headers: headers,
        body: jsonEncode(depenseData),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur lors de la modification de la dépense';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  static Future<void> deleteDepense(String id) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/supprimer-depense/$id'),
        headers: headers,
      );
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur lors de la suppression de la dépense';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getDepenseById(String id) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/depense/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur lors de la récupération de la dépense';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  static Future<List<dynamic>> getDevises() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/liste-devises'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['devises'] ?? [];
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur lors de la récupération des devises';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }
}
