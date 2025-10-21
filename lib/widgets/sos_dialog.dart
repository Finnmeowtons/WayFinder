import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vibration/vibration.dart';

Future<void> showSOSDialog(BuildContext context, String name) async {
  Vibration.vibrate(pattern: [0, 500, 200, 500]);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated alert icon (you can use a Lottie JSON or fallback to Icon)
            SizedBox(
              height: 100,
              child: Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.red.shade700,
              ),
            ),

            const SizedBox(height: 12),
            Text(
              'Emergency Alert!',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$name may need immediate help.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Last known location: JJC-1 Apartment, Dagupan City",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // FilledButton(
                //   style: FilledButton.styleFrom(
                //     backgroundColor: Colors.red.shade700,
                //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(16),
                //     ),
                //   ),
                //   onPressed: () {
                //     Navigator.pop(context);
                //     // Trigger emergency contact / call
                //   },
                //   child: const Row(
                //     children: [
                //       Icon(Icons.call_rounded, color: Colors.white),
                //       SizedBox(width: 6),
                //       Text("Call Now"),
                //     ],
                //   ),
                // ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Dismiss"),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
