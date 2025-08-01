import 'package:demo/src/game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Focus(
        onKeyEvent: (node, event) => KeyEventResult.handled,
        child: MyGameWidget(),
      ),
    ),
  );
}

class MyGameWidget extends StatefulWidget {
  const MyGameWidget({super.key});

  @override
  State<MyGameWidget> createState() => _MyGameWidgetState();
}

class _MyGameWidgetState extends State<MyGameWidget> {
  final DemoGame game = DemoGame();

  @override
  void reassemble() {
    super.reassemble();
    game.reload();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}
