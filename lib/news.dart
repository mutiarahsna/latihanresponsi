import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spaceflight News',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewsPage(),
    );
  }
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<Article>> futureArticles;

  @override
  void initState() {
    super.initState();
    futureArticles = fetchNewsArticles();
  }

  Future<List<Article>> fetchNewsArticles() async {
    try {
      final response = await http.get(
          Uri.parse('https://api.spaceflightnewsapi.net/v4/articles/?format=json'));

      if (response.statusCode == 200) {
        List<Article> articles = (json.decode(response.body) as List)
            .map((data) => Article.fromJson(data))
            .toList();
        return articles;
      } else {
        throw Exception('Failed to load articles. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching articles: $e');
      throw Exception('Failed to load articles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spaceflight News'),
      ),
      body: FutureBuilder<List<Article>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No articles available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return NewsCard(snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}

class Article {
  final String title;
  final String imageUrl;

  Article({required this.title, required this.imageUrl});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'title',
      imageUrl: json['image_url'] ?? 'image_url',
    );
  }
}

class NewsCard extends StatelessWidget {
  final Article article;

  NewsCard(this.article);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          // Implement action when the card is tapped
          print('${article.title} tapped');
        },
        splashColor: Colors.blue,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.network(
              article.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                article.title,
                style: TextStyle(fontSize: 17.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
