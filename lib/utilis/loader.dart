import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'images/loading.gif',
        width: 70, // Adjust size if needed
        height: 70,
        fit: BoxFit.fill,
      ),
    );

  }

}
