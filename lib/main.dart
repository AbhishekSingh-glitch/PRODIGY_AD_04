import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return TicTacToe();
  }
}

class TicTacToe extends State<MyApp> {
  List icon = List.filled(9, Icons.question_mark);
  List blockColor = List.filled(9, Colors.grey);
  String who = 'x';
  // int userLastPosition = 0;
  // int userCurrentPosition = 0;

  var color = Colors.red.shade300;
  int x = 0, o = 0;
  String opponent='Vs Computer';
  bool gameOver = false;
  final size = 150.0;
  Color bgColor= Colors.white;

  checkLoop(start, end, int steps, color) {
    int cnt = 0;
    for (int i = start; i < end; i += steps) {
      if (blockColor[i] == color) {
        cnt++;
      }
    }

    if (cnt == 3) {
      if (color == Colors.red.shade300) {
        x++;
      } else {
        o++;
      }
    }
    return (cnt == 3);
  }

  showMessage(BuildContext context,String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(message,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
        ),
        backgroundColor: (message.contains('O'))? Colors.blue :Colors.red ,
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: Duration(seconds: 5),
      )
    );
  }

  isPlaying() {
    for (int i = 0; i < 9; i++) {
      if (blockColor[i] != Colors.grey) {
        return true;
      }
    }
    return false;
  }

  int smartAIMove() {
    List<String> board = icon.map((i) {
      if (i == Icons.clear_outlined) return 'x';
      if (i == Icons.circle_outlined) return 'o';
      return '';
    }).toList();

    // Step 1: Win if possible
    int? move = findBestSpot(board, 'o');
    // Step 2: Block opponent if they can win
    move ??= findBestSpot(board, 'x');
    // Step 3: Take center
    move ??= board[4] == '' ? 4 : null;
    // Step 4: Take a corner
    move ??= pickFrom([0, 2, 6, 8], board);
    // Step 5: Take any side
    move ??= pickFrom([1, 3, 5, 7], board);

    return move ?? -1; // Return -1 if board full
  }

// Find a move to win or block
  int? findBestSpot(List<String> board, String symbol) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    for (var pattern in winPatterns) {
      var values = pattern.map((i) => board[i]).toList();
      int count = values.where((v) => v == symbol).length;
      int empty = values.where((v) => v == '').length;
      if (count == 2 && empty == 1) {
        return pattern.firstWhere((i) => board[i] == '');
      }
    }
    return null;
  }

// Pick available random position from a list
  int? pickFrom(List<int> positions, List<String> board) {
    var available = positions.where((i) => board[i] == '').toList();
    if (available.isEmpty) return null;
    return available[Random().nextInt(available.length)];
  }

  changeDate(text,clr){
    icon = List.filled(9, Icons.question_mark);
    blockColor = List.filled(9, Colors.grey);
    who = text;
    color = clr;
    gameOver = false;
  }

  playerButton(whoT,clr){
    return Builder(
      builder: (BuildContext context) {
        return ElevatedButton(
          onPressed: () {
            if (gameOver) {
              changeDate(whoT,clr);
            }
            else if (isPlaying()) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text('Can\'t change in between'),
                  ),
                  action: SnackBarAction(
                    label: 'Reload',
                    onPressed: () {
                      changeDate(whoT,clr);
                      setState(() {});
                    },
                  ),

                  backgroundColor: Color(0xFF1C3575),
                  behavior: SnackBarBehavior.floating,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  duration: Duration(seconds: 5),
                ),
              );
            }
            else {
              who = whoT;
              color = clr;
            }

            setState(() {});
          },
          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(clr,),),
          child: SizedBox(
            child: Text(
              (whoT == 'x') ? ' X      $x ' : ' O      $o ',
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> buttons =[

      playerButton('x',Colors.red.shade300),
      playerButton('o',Colors.blue.shade300),

      Card(
        color: Colors.green.shade300,
        child: TextButton(onPressed: (){
          opponent=(opponent=='Vs Player')?'Vs Computer':'Vs Player';
          icon = List.filled(9, Icons.question_mark);
          blockColor = List.filled(9, Colors.grey);
          gameOver = false;
          setState(() {});
        }, child: SizedBox(height: 20,width: 100, child: Text(opponent,textAlign:TextAlign.center, style: TextStyle(color: Colors.black),))),
      ),

      ElevatedButton(
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green.shade300)),
        onPressed: () {
          icon = List.filled(9, Icons.question_mark);
          blockColor = List.filled(9, Colors.grey);
          gameOver = false;
          setState(() {});
        },
        child: Icon(Icons.refresh,color: Colors.white,),
      )
    ];

    var deviceOrientation= MediaQuery.of(context).orientation;
    var isPortrait =(deviceOrientation == Orientation.portrait);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red,Colors.blue],begin: Alignment(-1, -1),end: Alignment(1, 1))
          ),
          child: Center(
            child: Stack(
              children: [
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double size =
                      constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight;
                      return SizedBox(
                        width: size * 0.9,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 9,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                          ),
                          itemBuilder: (context, index) {
                            return Center(
                              child: GestureDetector(
                                onTap: () async{
                                  if (gameOver) {return;}

                                  int row = ((index ~/ 3) * 3);
                                  int col = (index % 3);

                                  if (who == 'x' && blockColor[index] == Colors.grey) {
                                    icon[index] = (Icons.clear_outlined);
                                    blockColor[index] = color;
                                  }
                                  else if (blockColor[index] == Colors.grey) {
                                    icon[index] = (Icons.circle_outlined);
                                    blockColor[index] = color;
                                  }
                                  else {
                                    showMessage(context, 'Place Taken');
                                    return;
                                  }

                                  setState(() {});

                                  if (index % 2 == 0 || index % 4 == 0) {
                                    if (checkLoop(0, 9, 4, color)) {
                                      showMessage(context, '${who.toUpperCase()} Won',);
                                      gameOver = true;
                                      return;
                                    }

                                    if (checkLoop(2, 7, 2, color)) {
                                      showMessage(context, '${who.toUpperCase()} Won',);
                                      gameOver = true;
                                      return;
                                    }
                                  }

                                  if (checkLoop(row, (row + 3), 1, color)) {
                                    showMessage(context, '${who.toUpperCase()} Won',);
                                    gameOver = true;
                                    return;
                                  }
                                  if (checkLoop(col, (col + 7), 3, color)) {
                                    showMessage(context, '${who.toUpperCase()} Won',);
                                    gameOver = true;
                                    return;
                                  }

                                  if (who == 'x') {
                                    who = 'o';
                                    color = Colors.blue.shade300;
                                  }
                                  else {
                                    who = 'x';
                                    color = Colors.red.shade300;
                                  }

                                  await Future.delayed(Duration(milliseconds: 100));

                                  if(opponent =='Vs Computer'){

                                    int randomIndex = smartAIMove();

                                    row = ((randomIndex ~/ 3) * 3);
                                    col = (randomIndex % 3);

                                    if (who == 'x' && blockColor[randomIndex] == Colors.grey) {
                                      icon[randomIndex] = (Icons.clear_outlined);
                                      blockColor[randomIndex] = color;
                                    }
                                    else if (blockColor[randomIndex] == Colors.grey) {
                                      icon[randomIndex] = (Icons.circle_outlined);
                                      blockColor[randomIndex] = color;
                                    }
                                    else {
                                      showMessage(context, 'Place Taken');
                                      return;
                                    }

                                    setState(() {});

                                    if (randomIndex % 2 == 0 || randomIndex % 4 == 0) {
                                      if (checkLoop(0, 9, 4, color)) {
                                        showMessage(context, '${who.toUpperCase()} Won',);
                                        gameOver = true;
                                        return;
                                      }

                                      if (checkLoop(2, 7, 2, color)) {
                                        showMessage(context, '${who.toUpperCase()} Won',);
                                        gameOver = true;
                                        return;
                                      }
                                    }

                                    if (checkLoop(row, (row + 3), 1, color)) {
                                      showMessage(context, '${who.toUpperCase()} Won',);
                                      gameOver = true;
                                      return;
                                    }
                                    if (checkLoop(col, (col + 7), 3, color)) {
                                      showMessage(context, '${who.toUpperCase()} Won',);
                                      gameOver = true;
                                      return;
                                    }

                                    if (who == 'x') {
                                      who = 'o';
                                      color = Colors.blue.shade300;
                                    }
                                    else {
                                      who = 'x';
                                      color = Colors.red.shade300;
                                    }

                                  }

                                  setState(() {});
                                },
                                child: Card(
                                  color: Colors.transparent,
                                  shadowColor: (blockColor[index] != Colors.grey ) ? blockColor[index] : Color.fromRGBO(0, 0, 0, 0.2),
                                  child: SizedBox(
                                    width: size,
                                    height: size,
                                    child: Center(
                                      child: (icon[index] == Icons.question_mark) ?
                                      SizedBox() : Icon(icon[index], size: 100,
                                        color: blockColor[index],
                                    ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                (isPortrait)?
                Align(
                  alignment: Alignment(0, -0.7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: buttons,
                  ),
                )
                :Align(
                  alignment: Alignment(-0.8, -0.9),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: buttons
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
