import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MapTutorial {
  final BuildContext context;
  final GlobalKey mapKey;
  final GlobalKey locationKey;
  final GlobalKey bottomSheetKey;

  MapTutorial({
    required this.context,
    required this.mapKey,
    required this.locationKey,
    required this.bottomSheetKey,
  });

  void show() {
    final targets = _createTargets();
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withOpacity(0.6),
      textSkip: "SKIP",
      paddingFocus: 8,
      onFinish: () => print("Tutorial finished"),

      onClickTarget: (target) => debugPrint("Clicked ${target.identify}"),
    ).show(context: context);
  }

  List<TargetFocus> _createTargets() {
    TextStyle tutorialTextStyle() => const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );

    return [
      // TargetFocus(
      //   identify: "zoom_in",
      //   keyTarget: zoomInKey,
      //   contents: [
      //     TargetContent(
      //       align: ContentAlign.top,
      //       child: Text("Tap here to zoom in on the map.", style: tutorialTextStyle()),
      //     ),
      //   ],
      // ),

      TargetFocus(
        identify: "location",
        keyTarget: locationKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text("Use this button to go to your current location.", style: tutorialTextStyle()),
          ),
        ],
      ),
      TargetFocus(
        identify: "map",
        keyTarget: null, // no widget
        targetPosition: TargetPosition(Size(350, 650), Offset(0,20)),
        shape: ShapeLightFocus.RRect, // optional
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: 50,
              left: 20,
              right: 20,
            ),
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "This is the map.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      // TargetFocus(
      //   identify: "logout",
      //   keyTarget: logoutKey,
      //   contents: [
      //     TargetContent(
      //       align: ContentAlign.bottom,
      //       child: Text("Log out of your account here.", style: tutorialTextStyle()),
      //     ),
      //   ],
      // ),
      TargetFocus(
        identify: "bottom_sheet",
        keyTarget: bottomSheetKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text("Swipe up to view your list of connected sticks.", style: tutorialTextStyle()),
          ),
        ],
      ),
    ];
  }
}
