import 'dart:async';
import 'package:annas_archive_api/annas_archive_api.dart';
import 'package:bloc/bloc.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchBooks>(_onSearchBooks);
  }

  Future<void> _onSearchBooks(
    SearchBooks event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) return;

    emit(SearchLoading());

    // Simulate API delay
    await Future.delayed(Duration(seconds: 1));

    // Mock data for testing without connection
    final mockBooks = [
      Book(
        title: 'The Great Gatsby',
        author: 'F. Scott Fitzgerald',
        md5: 'mock_md5_1',
        imgUrl: 'https://via.placeholder.com/100x150/FF6B6B/FFFFFF?text=Gatsby',
        size: '2.5 MB',
        genre: 'Fiction',
        format: Format.epub,
        year: '1925',
      ),
      Book(
        title: 'To Kill a Mockingbird',
        author: 'Harper Lee',
        md5: 'mock_md5_2',
        imgUrl:
            'https://via.placeholder.com/100x150/4ECDC4/FFFFFF?text=Mockingbird',
        size: '3.1 MB',
        genre: 'Fiction',
        format: Format.pdf,
        year: '1960',
      ),
      Book(
        title: '1984',
        author: 'George Orwell',
        md5: 'mock_md5_3',
        imgUrl: 'https://via.placeholder.com/100x150/45B7D1/FFFFFF?text=1984',
        size: '1.8 MB',
        genre: 'Dystopian',
        format: Format.epub,
        year: '1949',
      ),
      Book(
        title: 'Pride and Prejudice',
        author: 'Jane Austen',
        md5: 'mock_md5_4',
        imgUrl: 'https://via.placeholder.com/100x150/F7DC6F/FFFFFF?text=Pride',
        size: '2.2 MB',
        genre: 'Romance',
        format: Format.pdf,
        year: '1813',
      ),
    ];

    // Filter mock books based on query (simple contains check)
    final filteredBooks = mockBooks
        .where(
          (book) =>
              book.title.toLowerCase().contains(event.query.toLowerCase()) ||
              book.author.toLowerCase().contains(event.query.toLowerCase()) ||
              book.genre.toLowerCase().contains(event.query.toLowerCase()),
        )
        .toList();

    // For testing, if no matches, return all books
    final resultBooks = filteredBooks.isNotEmpty ? filteredBooks : mockBooks;

    emit(SearchLoaded(resultBooks));
  }
}
