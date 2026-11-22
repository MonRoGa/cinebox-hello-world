
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'movie_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CineBoxApp());
}

class CineBoxApp extends StatelessWidget {
  const CineBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineBox',
      theme: ThemeData.dark(),
      home: const MovieHomePage(),
    );
  }
}

class MovieHomePage extends StatefulWidget {
  const MovieHomePage({super.key});

  @override
  State<MovieHomePage> createState() => _MovieHomePageState();
}

class _MovieHomePageState extends State<MovieHomePage> {
  final MovieService movieService = MovieService();

  late Future<List<dynamic>> popularMovies;

  @override
  void initState() {
    super.initState();
    popularMovies = movieService.getPopularMovies();
  }

  // Guarda una película favorita en Firebase.
  Future<void> saveFavorite(Map<String, dynamic> movie) async {
    try {
      await FirebaseFirestore.instance.collection('favorites').add({
        'movieId': movie['id'],
        'title': movie['title'] ?? 'Sin título',
        'overview': movie['overview'] ?? '',
        'posterPath': movie['poster_path'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${movie['title']} se agregó a tus favoritos',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171329),
      appBar: AppBar(
        title: const Text(
          'CINEBOX',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        backgroundColor: const Color(0xFF271D46),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: popularMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final movies = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Películas populares',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              ...movies.map((movie) {
                final posterPath = movie['poster_path'];

                return Card(
                  color: const Color(0xFF29213F),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),

                    leading: posterPath != null
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w200$posterPath',
                            width: 65,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.movie),

                    title: Text(
                      movie['title'] ?? 'Sin título',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      movie['overview'] ?? 'Sin descripción disponible',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Botón para guardar la película.
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.pinkAccent,
                      ),
                      onPressed: () => saveFavorite(
                        Map<String, dynamic>.from(movie),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
