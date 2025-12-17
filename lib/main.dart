import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:annas_archive_api/annas_archive_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'blocs/search_bloc.dart';
import 'blocs/search_event.dart';
import 'blocs/search_state.dart';

const String serverUrl = 'http://stacks:7788';
const String apiKey = '';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: MaterialApp(
        title: 'Anna Archive Client',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
            ),
          ),
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchInitial) {
              return _buildSearchView(context);
            } else if (state is SearchLoading) {
              return _buildLoadingView();
            } else if (state is SearchLoaded) {
              return _buildResultsView(context, state.books);
            } else if (state is SearchError) {
              return _buildErrorView(context, state.message);
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildSearchView(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Search for books...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _controller.clear(),
                      )
                    : null,
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  BlocProvider.of<SearchBloc>(
                    context,
                  ).add(SearchBooks(query.trim()));
                }
              },
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final query = _controller.text.trim();
              if (query.isNotEmpty) {
                BlocProvider.of<SearchBloc>(context).add(SearchBooks(query));
              }
            },
            icon: Icon(Icons.search),
            label: Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResultsView(BuildContext context, List<Book> books) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search for books...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () => _controller.clear(),
                          )
                        : null,
                  ),
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      BlocProvider.of<SearchBloc>(
                        context,
                      ).add(SearchBooks(query.trim()));
                    }
                  },
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  final query = _controller.text.trim();
                  if (query.isNotEmpty) {
                    BlocProvider.of<SearchBloc>(
                      context,
                    ).add(SearchBooks(query));
                  }
                },
                child: Text('Search'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookItem(book: book);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<SearchBloc>(
                  context,
                ).add(SearchBooks(_controller.text));
              },
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class BookItem extends StatelessWidget {
  final Book book;

  const BookItem({super.key, required this.book});

  Future<void> _download(BuildContext context, String md5) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/queue/add'),
        headers: {'X-API-Key': apiKey, 'Content-Type': 'application/json'},
        body: jsonEncode({'md5': md5, 'source': 'flutter'}),
      );
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Added to queue',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to add to queue',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              book.imgUrl,
              width: 50,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.book, size: 50),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Author: ${book.author}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  'Genre: ${book.genre} • Year: ${book.year ?? 'Unknown'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.download, color: Colors.blue),
            onPressed: () => _download(context, book.md5),
          ),
        ],
      ),
    );
  }
}
