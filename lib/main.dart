import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Guppy";
  int happinessLevel = 50;
  int hungerLevel = 50;
  Timer? hungerTimer;
  Timer? winConditionTimer;
  Timer? checkGameOverTimer;
  int winTimerSeconds = 0;
  bool hasWon = false;
  bool gameOver = false;
  Color petColor = Colors.yellow;
  final TextEditingController _controller = TextEditingController();

  void initState() {
    super.initState();
    // Start the hunger timer that increases hunger every 30 seconds
    startHungerTimer();
    startGameStatusTimer();
  }

  void startHungerTimer() {
    hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 10).clamp(0, 100); // Increase hunger
        if (hungerLevel >= 100) {
          hungerLevel = 100;
        }
        _updatePetColor(); // Update pet color after hunger increase
      });
    });
  }

  void startGameStatusTimer() {
    checkGameOverTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (happinessLevel > 80) {
        winTimerSeconds++;
      } else {
        winTimerSeconds = 0; // Reset if happiness drops below 80
      }

      // Check if the user has won
      if (winTimerSeconds >= 180) {
        // 3 minutes = 180 seconds
        setState(() {
          hasWon = true;
          timer.cancel(); // Stop the timer once the game is won
          showWinDialog();
        });
      }

      // Check if the user has lost (hunger 100 and happiness 10 or less)
      if (hungerLevel >= 100 && happinessLevel <= 10) {
        setState(() {
          gameOver = true;
          timer.cancel();
          showGameOverDialog(); // Stop the timer once the game is over
        });
      }
    });
  }

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Congratulations!"),
          content: Text("You win!!! Your pet is happy!"),
        );
      },
    );
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over!"),
          content: Text("Your pet is dead!!!"),
        );
      },
    );
  }

// Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    if (gameOver || hasWon) return;
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      _updatePetColor();
    });
  }

// Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    if (gameOver || hasWon) return;
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      _updatePetColor();
    });
  }

// Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

// Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 10).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  void _updatePetColor() {
    if (happinessLevel > 70) {
      petColor = Colors.green; // Happy
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      petColor = Colors.yellow; // Neutral
    } else {
      petColor = Colors.red; // Unhappy
    }
  }

  String _getPetMood() {
    if (happinessLevel > 70) {
      return "Happy 😊";
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return "Neutral 😐";
    } else {
      return "Unhappy 😞";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    petColor.withOpacity(1), // Use petColor dynamically
                    BlendMode.modulate,
                  ),
                  child: Image.asset(
                    'assets/images/HealthyGuppy.png', // Image of the pet
                    width: 200,
                    height: 200,
                  ),
                ),
                Text(
                  'Mood: ${_getPetMood()}', // Display the pet's mood
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .black, // Optional: Color the text to match pet's tint
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Name: ',
                  style: TextStyle(fontSize: 20.0),
                ),
                Container(
                  width: 100, // Width of the text field inside the button
                  height: 30, // Height of the text field inside the button
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number, // Numeric keyboard
                    decoration: InputDecoration(
                      hintText: 'Set Name',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Happiness Level: $happinessLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Hunger Level: $hungerLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
          ],
        ),
      ),
    );
  }
}
