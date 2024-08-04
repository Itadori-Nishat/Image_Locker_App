// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LockScreen extends StatefulWidget {
//   final bool isSetting;
//
//   LockScreen({required this.isSetting});
//
//   @override
//   _LockScreenState createState() => _LockScreenState();
// }
//
// class _LockScreenState extends State<LockScreen> {
//   final _pinController = TextEditingController();
//   late List<String> _pinDigits;
//
//   @override
//   void initState() {
//     super.initState();
//     _pinDigits = List.generate(4, (index) => '');
//     _pinController.addListener(_onPinChanged);
//   }
//
//   void _onPinChanged() {
//     final text = _pinController.text;
//     setState(() {
//       for (int i = 0; i < _pinDigits.length; i++) {
//         if (i < text.length) {
//           _pinDigits[i] = text[i];
//         } else {
//           _pinDigits[i] = '';
//         }
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.isSetting ? 'Set PIN' : 'Enter PIN')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildPinEntry(),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _onSubmitPin,
//                 child: Text(widget.isSetting ? 'Set PIN' : 'Submit'),
//               ),
//               if (!widget.isSetting)
//                 TextButton(
//                   onPressed: _resetPin,
//                   child: Text('Reset PIN'),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPinEntry() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: List.generate(4, (index) {
//         return _buildPinDigitBox(_pinDigits[index]);
//       }),
//     );
//   }
//
//   Widget _buildPinDigitBox(String digit) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(
//         child: Text(
//           digit,
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _onSubmitPin() async {
//     final pin = _pinDigits.join();
//     final prefs = await SharedPreferences.getInstance();
//
//     if (widget.isSetting) {
//       // Save the PIN and mark it as enabled
//       await prefs.setString('pin', pin);
//       await prefs.setBool('isPinEnabled', true);
//       Navigator.of(context).pop(true); // Return true to indicate PIN was set
//     } else {
//       // Check if entered PIN is correct
//       final savedPin = prefs.getString('pin') ?? '';
//       if (pin == savedPin) {
//         Navigator.of(context).pop(true); // Return true to indicate correct PIN
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Incorrect PIN')),
//         );
//       }
//     }
//   }
//
//   void _resetPin() {
//     Navigator.of(context).push(
//       MaterialPageRoute(builder: (context) => LockScreen(isSetting: true)),
//     );
//   }
// }
