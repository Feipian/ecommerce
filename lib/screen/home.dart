import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../models/movie.dart';
import '../movie/add_movie_page.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {




  final user = FirebaseAuth.instance.currentUser;

  // Fetch movies from Firestore
  Future<List<Movie>> fetchMovies() async {
    final snapshot = await FirebaseFirestore.instance.collection('movies').get();
    return snapshot.docs
        .map((doc) => Movie.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  signOut()async{
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Welcome ${user?.email}",
              style: TextStyle(fontSize: 18),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: fetchMovies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No movies available.'));
                }

                final movies = snapshot.data!;
                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to detail page if needed
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              movie.posterUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            movie.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            movie.releaseDate.toLocal().toString().split(' ')[0],
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "logoutBtn",
              onPressed: signOut,
              child: Icon(Icons.logout),
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'addMovieBtn',
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMoviePage()),
                );
              },
              child: Icon(Icons.add),
            )
            ]
        )
      // FloatingActionButton(
      //   onPressed: signOut,
      //   child: Icon(Icons.logout),
      // ),

    );
  }
}



