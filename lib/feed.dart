import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constant.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'description.dart';
import 'dart:io';
import 'package:samachar/login_page.dart';
import 'package:samachar/sign_in.dart';

class NewsFeedPage extends StatelessWidget {
  static String tag = "NewsFeedPage-tag";
  NewsFeedPage(this.text);
  final int text;


@override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    String title = "TechCrunch";
    return Scaffold(
      appBar: AppBar(
        title: new Text("News Feed for " + name,
            style: new TextStyle(color: Colors.white)),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: () {
              signOutGoogle();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return LoginPage();}), ModalRoute.withName('/'));
            }
    )],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: new SafeArea(
          child: new Column(
            children: [
              new Expanded(
                flex: 1,
                child: new Container(
                    width: width,
                    color: Colors.white,
                    child: new GestureDetector(
                      child: new FutureBuilder<List<News>>(
                        future: fetchNews(
                            http.Client(), text), // a Future<String> or null
                        builder: (context, snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? NewsList(news: snapshot.data)
                              : Center(child: CircularProgressIndicator());
                        },
                      ),
                    )),
              ),
            ],
          )),
    );
  }
}

Future<List<News>> fetchNews(http.Client client, id) async {
  String url;
    url = Constant.base_url +
        "top-headlines?sources=techcrunch&apiKey=" +
        Constant.key;
  final response = await client.get(url);
  return compute(parsenews, response.body);
}

List<News> parsenews(String responsebody) {
  final parsed = json.decode(responsebody);
  return (parsed["articles"] as List)
      .map<News>((json) => new News.fromJson(json))
      .toList();
}

class News {
  String author;
  String title;
  String description;
  String url;

  News({this.author, this.title, this.description, this.url});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      author: json['author'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
    );
  }
}

class NewsList extends StatelessWidget {
  final List<News> news;

  NewsList({Key key, this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: news.length,
      itemBuilder: (context, index) {
        return new Card(
          child: new ListTile(
            leading: CircleAvatar(
              child: Icon(
                Icons.star,
                color: Colors.white,
              ),
              backgroundColor: Colors.lightBlue,
            ),
            title: Text(news[index].title),
            onTap: () {
              var url = news[index].url;
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) => new DescriptionPage(url),
                  ));
            },
          ),
        );
      },
    );
  }
}