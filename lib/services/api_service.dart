import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  // ---------------------------
  // PRIVATE HELPERS
  // ---------------------------

  static Future<Map<String, String>> _getHeaders({
    bool authenticated = false,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (authenticated) {
      final token = AuthService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _get(
    String path, {
    bool authenticated = false,
  }) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated: authenticated),
    );
    return _handleResponse(res);
  }

  static Future<List<dynamic>> _getList(
    String path, {
    bool authenticated = false,
  }) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated: authenticated),
    );
    return _handleListResponse(res);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    dynamic body, {
    bool authenticated = false,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated: authenticated),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> _put(
    String path,
    dynamic body, {
    bool authenticated = false,
  }) async {
    final res = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated: authenticated),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> _delete(
    String path, {
    bool authenticated = false,
  }) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _getHeaders(authenticated: authenticated),
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
    }, authenticated: false);
  }

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    return await _post('/users/login', {'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await _get('/users/me', authenticated: true);
  }

  // ---------------------------
  // COURSES
  // ---------------------------

  static Future<List<dynamic>> getAllCourses() async {
    return await _getList('/courses');
  }

  static Future<Map<String, dynamic>> getCourseById(int courseId) async {
    return await _get('/courses/$courseId');
  }

  static Future<Map<String, dynamic>> createCourse(
    String title,
    String description,
    int authorId,
  ) async {
    return await _post('/courses', {
      'title': title,
      'description': description,
      'authorId': authorId,
    }, authenticated: true);
  }

  static Future<Map<String, dynamic>> updateCourse(
    int courseId, {
    String? title,
    String? description,
  }) async {
    return await _put('/courses/$courseId', {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    }, authenticated: true);
  }

  static Future<Map<String, dynamic>> deleteCourse(int courseId) async {
    return await _delete('/courses/$courseId', authenticated: true);
  }

  // ---------------------------
  // MODULES
  // ---------------------------

  static Future<Map<String, dynamic>> createModule(
    String title,
    int courseId,
  ) async {
    return await _post('/modules', {
      'title': title,
      'courseId': courseId,
    }, authenticated: true);
  }

  static Future<Map<String, dynamic>> getModuleById(int moduleId) async {
    return await _get('/modules/$moduleId');
  }

  static Future<Map<String, dynamic>> updateModule(
    int moduleId, {
    String? title,
  }) async {
    return await _put('/modules/$moduleId', {
      if (title != null) 'title': title,
    }, authenticated: true);
  }

  static Future<Map<String, dynamic>> deleteModule(int moduleId) async {
    return await _delete('/modules/$moduleId', authenticated: true);
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
    }, authenticated: true);
  }

  static Future<Map<String, dynamic>> getLessonById(int lessonId) async {
    return await _get('/lessons/$lessonId');
  }

  static Future<Map<String, dynamic>> updateLesson(
    int lessonId, {
    String? title,
    String? content,
    String? videoUrl,
  }) async {
    return await _put('/lessons/$lessonId', {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (videoUrl != null) 'videoUrl': videoUrl,
    }, authenticated: true);
  }

  static Future<Map<String, dynamic>> deleteLesson(int lessonId) async {
    return await _delete('/lessons/$lessonId', authenticated: true);
  }

  // ---------------------------
  // ENROLLMENTS
  // ---------------------------

  static Future<Map<String, dynamic>> enrollUser(
    int userId,
    int courseId,
  ) async {
    return await _post('/enrollments', {
      'userId': userId,
      'courseId': courseId,
    }, authenticated: true);
  }

  static Future<List<dynamic>> getUserEnrollments(int userId) async {
    return await _getList('/users/$userId/enrollments', authenticated: true);
  }

  // ---------------------------
  // PROGRESS
  // ---------------------------

  static Future<Map<String, dynamic>> postProgress(
    Map<String, dynamic> progress,
  ) async {
    return await _post('/progress', progress, authenticated: true);
  }

  static Future<List<dynamic>> getUserProgress(int userId) async {
    return await _getList('/progress/$userId', authenticated: true);
  }
}
