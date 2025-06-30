import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  // ---------------------------
  // PRIVATE HELPERS
  // ---------------------------

  static Future<Map<String, String>> _getHeaders(
    bool authenticated,
    bool notIncludeContentType,
  ) async {
    final headers = <String, String>{};

    if (!notIncludeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (authenticated) {
      final token = AuthService.getToken();
      print("token\: $token, authorization: $authenticated");
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _get(
    String path,
    bool authenticated,
  ) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated, false),
    );
    return _handleResponse(res);
  }

  static Future<List<dynamic>> _getList(String path, bool authenticated) async {
    print("path: $path / authenticated: $authenticated");
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated, false),
    );
    return _handleListResponse(res);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    dynamic body,
    bool authenticated,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated, false),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> _put(
    String path,
    dynamic body,
    bool authenticated,
  ) async {
    final res = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated, false),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> _delete(
    String path,
    bool authenticated,
  ) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated, true),
    );
    return _handleResponse(res);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    print(response);

    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      print("{AAAAAAAAAAAAAAAAa: $decoded['message']}");
      throw Exception(
        decoded['message'] ? decoded['message'] : 'Erro inesperado',
      );
    }
  }

  static List<dynamic> _handleListResponse(http.Response response) {
    if (response.body.isEmpty) {
      print("Response body is empty.");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return []; // Retorna lista vazia se sucesso mas sem corpo
      } else {
        throw Exception('Erro inesperado. Nenhum corpo na resposta.');
      }
    }

    final decoded = jsonDecode(response.body);
    print("decoded: $decoded / responsebody: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is List<dynamic>) {
        return decoded;
      } else {
        // Em caso do backend retornar objeto em vez de lista
        return [decoded];
      }
    } else {
      print("{BBBBBBBBBBBBBBBBBBB: ${decoded['message']}}");
      throw Exception(decoded['message'] ?? 'Erro inesperado');
    }
  }

  // ---------------------------
  // USERS
  // ---------------------------
  static Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
  ) async {
    print("name $name - , email - $email, pass - $password");

    return await _post('/users/register', {
      'name': name,
      'email': email,
      'password': password,
    }, false);
  }

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    return await _post('/users/login', {
      'email': email,
      'password': password,
    }, false);
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await _get('/users/me', true);
  }

  static Future<Map<String, dynamic>> deleteUser() async {
    print('/users/${AuthService.user?['id']}');
    return await _delete('/users/${AuthService.user?['id']}', true);
  }

  static Future<Map<String, dynamic>> updateCurrentUser(
    Map<String, dynamic> body,
  ) async {
    final userId = AuthService.user?['id'];

    final res = await http.patch(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: await _getHeaders(true, false),
      body: jsonEncode(body),
    );

    return _handleResponse(res);
  }
  // ---------------------------
  // COURSES
  // ---------------------------

  static Future<List<dynamic>> getAllCourses() async {
    return await _getList('/courses', true);
  }

  static Future<Map<String, dynamic>> getCourseById(String courseId) async {
    return await _get('/courses/$courseId', true);
  }

  static Future<Map<String, dynamic>> createCourse(
    String title,
    String description,
    String authorId,
    String imageUrl,
  ) async {
    print(
      "title $title,      description $description,      authorId $authorId,      imageUrl $imageUrl    ",
    );
    return await _post('/courses', {
      'title': title,
      'description': description,
      'authorId': authorId,
    }, true);
  }

  static Future<Map<String, dynamic>> updateCourse(
    String courseId, {
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    return await _put('/courses/$courseId', {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    }, true);
  }

  static Future<Map<String, dynamic>> deleteCourse(String courseId) async {
    return await _delete('/courses/$courseId', true);
  }

  static Future<List<dynamic>> getMyCourses() async {
    // Busca todos os cursos
    final allCourses = await getAllCourses();

    // Filtra pelo autor logado
    final userId = AuthService.user?['id'];
    if (userId == null) {
      return [];
    }

    final myCourses =
        allCourses.where((course) {
          final authorId = course['author']?['id'];
          return authorId == userId;
        }).toList();

    return myCourses;
  }

  // ---------------------------
  // MODULES
  // ---------------------------

  static Future<Map<String, dynamic>> createModule(
    String title,
    String courseId,
  ) async {
    return await _post('/modules', {
      'title': title,
      'courseId': courseId,
      'order': Random().nextInt(100),
    }, true);
  }

  static Future<Map<String, dynamic>> getModuleById(String moduleId) async {
    return await _get('/modules/$moduleId', AuthService.isLoggedIn);
  }

  static Future<Map<String, dynamic>> updateModule(
    String moduleId,
    String? title,
  ) async {
    return await _put('/modules/$moduleId', {
      if (title != null) 'title': title,
    }, AuthService.isLoggedIn);
  }

  static Future<Map<String, dynamic>> deleteModule(String moduleId) async {
    return await _delete('/modules/$moduleId', true);
  }

  // ---------------------------
  // LESSONS
  // ---------------------------

  static Future<Map<String, dynamic>> createLesson({
    required String title,
    required String content,
    String? videoUrl,
    required String moduleId, required int order,
  }) async {
    return await _post('/lessons', {
      'title': title,
      'content': content,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'moduleId': moduleId,
    }, true);
  }

  static Future<Map<String, dynamic>> getLessonById(String lessonId) async {
    return await _get('/lessons/$lessonId', true);
  }

  static Future<Map<String, dynamic>> updateLesson(
    String lessonId, {
    String? title,
    String? content,
    String? videoUrl,
  }) async {
    return await _put('/lessons/$lessonId', {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (videoUrl != null) 'videoUrl': videoUrl,
    }, true);
  }

  static Future<Map<String, dynamic>> deleteLesson(String lessonId) async {
    return await _delete('/lessons/$lessonId', true);
  }

  // ---------------------------
  // ENROLLMENTS
  // ---------------------------

  static Future<Map<String, dynamic>> enrollUser(
    String userId,
    String courseId,
  ) async {
    return await _post('/enrollments', {
      'userId': userId,
      'courseId': courseId,
    }, true);
  }

  static Future<List<dynamic>> getUserEnrollments(String userId) async {
    return await _getList('/users/$userId/enrollments', true);
  }

  // ---------------------------
  // PROGRESS
  // ---------------------------

  static Future<Map<String, dynamic>> postProgress(
    Map<String, dynamic> progress,
  ) async {
    return await _post('/progress', progress, true);
  }

  static Future<List<dynamic>> getUserProgress(String userId) async {
    return await _getList('/progress/$userId', true);
  }
}
