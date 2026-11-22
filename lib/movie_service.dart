
import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieService {
  // URL base de TMDB
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // API Key de TMDB
  static const String apiKey = '97afbc653a7f777bcc058c1acacc8be8';

  // Obtener películas populares
  Future<List<dynamic>> getPopularMovies() async {
    final url = Uri.parse(
      '$baseUrl/movie/popular?api_key=$apiKey&language=es-MX&page=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al cargar las películas');
    }
  }
}
