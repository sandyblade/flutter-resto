import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int maxRating;
  final int rating;

  const RatingWidget({
    super.key,
    required this.maxRating,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyRatingWidget(maxRating: maxRating, rating: rating),
    );
  }
}

class MyRatingWidget extends StatefulWidget {
  final int maxRating;
  final int rating;

  const MyRatingWidget({
    Key? key,
    required this.maxRating,
    required this.rating,
  }) : super(key: key);

  @override
  _MyRatingWidgetState createState() => _MyRatingWidgetState();
}

class _MyRatingWidgetState extends State<MyRatingWidget> {
  int maxStar = 10;
  int _currentRound = 0;
  int _less = 0;

  @override
  void initState() {
    super.initState();
    final maxRating = widget.maxRating;
    final rating = widget.rating;
    final current = (((rating / maxRating) * 100) / maxStar);
    final currentRound = current.round();
    final less = maxStar - currentRound;
    _currentRound = currentRound;
    _less = less;
  }

  @override
  Widget build(BuildContext context) {
    final ratingRender = List.generate(_currentRound, (index) {
      return Icon(Icons.star, size: 12, color: Colors.amberAccent);
    });
    final ratingRenderLess = List.generate(_less, (index) {
      return Icon(Icons.star, size: 12, color: Colors.grey);
    });
    return Row(children: [...ratingRender, ...ratingRenderLess]);
  }
}
