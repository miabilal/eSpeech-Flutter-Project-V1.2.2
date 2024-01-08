import 'package:flutter/material.dart';

class BottomAppProvider with ChangeNotifier {
  bool isShowBar = true;
  bool isScrollingDown = false;
  late AnimationController _animationController;

   get checkIsScrollingDown => isScrollingDown;

   get getBars => isShowBar;

  AnimationController get animationController => _animationController;

   showBars(bool value) {
    isShowBar = value;
    notifyListeners();
  }

   setBottom(bool value) {
    isScrollingDown = value;
    notifyListeners();
  }

  void setAnimationController(AnimationController animationController) {
    _animationController = animationController;
    notifyListeners();
  }
}
