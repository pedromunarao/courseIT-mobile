import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  // ---------------------------
  // PRIVATE HELPERS
  // ---------------------------

  static Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    final authenticated = AuthService.isLoggedIn;

    if (authenticated) {
      final token = AuthService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(),
    );
    return _handleResponse(res);
  }

  static Future<List<dynamic>> _getList(String path) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(res);
  }

  static Future<Map<String, dynamic>> _post(String path, dynamic body) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> _put(String path, dynamic body) async {
    final res = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> _delete(String path) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(),
    );
    return _handleResponse(res);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      throw Exception(decoded['message'] ?? 'Erro inesperado');
    }
  }

  static List<dynamic> _handleListResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    print("decoded: $decoded / responsebody: ${response.body}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
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
    return await _post('/users/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    return await _post('/users/login', {'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await _get('/users/me');
  }

  // ---------------------------
  // COURSES
  // ---------------------------

  static Future<List<dynamic>> getAllCourses() async {
    return await _getList('/courses');
  }

  static Future<Map<String, dynamic>> getCourseById(String courseId) async {
    return await _get('/courses/$courseId');
  }

  static Future<Map<String, dynamic>> createCourse(
    String title,
    String description,
    String authorId,
  ) async {
    return await _post('/courses', {
      'title': title,
      'description': description,
      'authorId': authorId,
    });
  }

  static Future<Map<String, dynamic>> updateCourse(
    String courseId, {
    String? title,
    String? description,
  }) async {
    return await _put('/courses/$courseId', {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    });
  }

  static Future<Map<String, dynamic>> deleteCourse(String courseId) async {
    return await _delete('/courses/$courseId');
  }

  // ---------------------------
  // MODULES
  // ---------------------------

  static Future<Map<String, dynamic>> createModule(
    String title,
    String courseId,
  ) async {
    return await _post('/modules', {'title': title, 'courseId': courseId});
  }

  static Future<Map<String, dynamic>> getModuleById(String moduleId) async {
    return await _get('/modules/$moduleId');
  }

  static Future<Map<String, dynamic>> updateModule(
    String moduleId, String text, {
    String? title,
  }) async {
    return await _put('/modules/$moduleId', {
      if (title != null) 'title': title,
    });
  }

  static Future<Map<String, dynamic>> deleteModule(String moduleId) async {
    return await _delete('/modules/$moduleId');
  }

  // ---------------------------
  // LESSONS
  // ---------------------------

  static Future<Map<String, dynamic>> createLesson({
    required String title,
    required String content,
    required String type,
    String? videoUrl,
    required int moduleId,
  }) async {
    return await _post('/lessons', {
      'title': title,
      'content': content,
      'type': type,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'moduleId': moduleId,
    });
  }

  static Future<Map<String, dynamic>> getLessonById(String lessonId) async {
    return await _get('/lessons/$lessonId');
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
    });
  }

  static Future<Map<String, dynamic>> deleteLesson(String lessonId) async {
    return await _delete('/lessons/$lessonId');
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
    });
  }

  static Future<List<dynamic>> getUserEnrollments(String userId) async {
    return await _getList('/users/$userId/enrollments');
  }

  // ---------------------------
  // PROGRESS
  // ---------------------------

  static Future<Map<String, dynamic>> postProgress(
    Map<String, dynamic> progress,
  ) async {
    return await _post('/progress', progress);
  }

  static Future<List<dynamic>> getUserProgress(String userId) async {
    return await _getList('/progress/$userId');
  }
}
