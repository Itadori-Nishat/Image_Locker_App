import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
import 'Reset Pin.dart';

class EnterPinScreen extends StatefulWidget {
  @override
  _EnterPinScreenState createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndSetDefaultPin();
    _showWelcomeSnackBar();
  }

  Future<void> _checkAndSetDefaultPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('pin');

    if (savedPin == null) {
      // Set default PIN if no PIN is saved
      await prefs.setString('pin', '12345678');
    }
  }

  Future<void> _showWelcomeSnackBar() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownSnackBar = prefs.getBool('hasShownSnackBar') ?? false;

    if (!hasShownSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your Default PIN is: 12345678'),
          duration: Duration(seconds: 30),
        ),
      );

      // Set flag to indicate that the SnackBar has been shown
      await prefs.setBool('hasShownSnackBar', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'J U H A T',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 5),
        ),
        elevation: 2,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter your PIN:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    labelText: 'Enter PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _onSubmitPin,
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Continue',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmitPin() async {
    final pin = _pinController.text;
    final prefs = await SharedPreferences.getInstance();

    // Get the current number of failed attempts
    final attemptCount = prefs.getInt('attemptCount') ?? 0;

    // Check if entered PIN is correct
    final savedPin = prefs.getString('pin') ?? '';
    if (pin == savedPin) {
      // Reset attempt count on successful login
      await prefs.setInt('attemptCount', 0);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
      // Increment attempt count
      final newAttemptCount = attemptCount + 1;
      await prefs.setInt('attemptCount', newAttemptCount);

      if (newAttemptCount >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Incorrect PIN. You have reached the maximum attempts. Please reset your PIN.'),
            action: SnackBarAction(
              label: 'Reset PIN',
              onPressed: _resetPin,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Incorrect PIN. Attempts left: ${5 - newAttemptCount}')),
        );
      }
    }
  }

  void _resetPin() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ResetPinScreen(isResetting: true)),
    );
  }
}
