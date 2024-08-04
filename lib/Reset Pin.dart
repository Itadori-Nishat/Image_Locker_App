import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPinScreen extends StatefulWidget {
  final bool isResetting;

  ResetPinScreen({required this.isResetting});

  @override
  _ResetPinScreenState createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _obscureCurrentPin = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isResetting ? 'Reset PIN' : 'Set PIN')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isResetting) ...[
                TextField(
                  controller: _currentPinController,
                  decoration: InputDecoration(
                    labelText: 'Current PIN',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCurrentPin
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPin = !_obscureCurrentPin;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureCurrentPin,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                "Enter new PIN:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newPinController,
                decoration: InputDecoration(
                  labelText: 'New PIN',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNewPin
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureNewPin = !_obscureNewPin;
                      });
                    },
                  ),
                ),
                obscureText: _obscureNewPin,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmPinController,
                decoration: InputDecoration(
                  labelText: 'Confirm New PIN',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPin
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPin = !_obscureConfirmPin;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPin,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _onResetPin,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      widget.isResetting ? 'Reset PIN' : 'Set PIN',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
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

  Future<void> _onResetPin() async {
    final currentPin = _currentPinController.text;
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    if (widget.isResetting) {
      // Show confirmation dialog before resetting the PIN
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning!'),
            content: const Text(
                'You are changing your PIN Code. If you forget your PIN you will not be able to recover it again. Remember the PIN or write it down.\n\nAre you sure you want to change the PIN?'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog

                  final prefs = await SharedPreferences.getInstance();
                  final storedPin = prefs.getString('pin');

                  if (currentPin != storedPin) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Current PIN is incorrect')),
                    );
                    return;
                  }

                  if (newPin != confirmPin) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PINs do not match')),
                    );
                    return;
                  }

                  await prefs.setString('pin', newPin);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN has been reset successfully')),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('No'),
              ),
            ],
          );
        },
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pin', newPin);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN has been set successfully')),
      );
      Navigator.of(context).pop(); // Return to the previous screen
    }
  }
}
