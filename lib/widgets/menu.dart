import 'package:flutter/material.dart';

typedef IndexCallback = void Function(int index);

class Menu extends StatefulWidget {

  final List<Icon> icons;
  final List<String> options;
  final ValueNotifier<bool> isOpen;
  final IndexCallback? onSelected;

  const Menu({super.key, required this.options, required this.icons, required this.isOpen, this.onSelected});

  @override
  State<Menu> createState() => _MenuState();

}

class _MenuState extends State<Menu> with TickerProviderStateMixin {

  
  late List<AnimationController> _openControllers;
  late List<Animation<double>> _openAnimations;

  late List<AnimationController> _closeControllers;
  late List<Animation<double>> _closeAnimations;

  late bool start;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    start = true;
    _openControllers = [];
    _openAnimations = [];
    _closeControllers = [];
    _closeAnimations = [];
    for (var i = 0; i < widget.options.length; i++) {
      final openController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
      _openControllers.add(openController);
      final openAnimation = Tween<double>(begin: 1000.0, end: 10.0).animate(CurvedAnimation(parent: openController, curve: Curves.easeIn));
      openAnimation.addListener(() => setState(() {}));
      _openAnimations.add(openAnimation);
      
      final closeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
      _closeControllers.add(closeController);
      final closeAnimation = Tween<double>(begin: 10.0, end: 1000.0).animate(CurvedAnimation(parent: closeController, curve: Curves.easeOut));
      closeAnimation.addListener(() => setState(() {}));
      _closeAnimations.add(closeAnimation);
    }

    widget.isOpen.value = false;
    widget.isOpen.addListener(() {
      if (widget.isOpen.value) {
        open();
      } else {
        close();
      }
    });
  }

  @override
  void dispose() {
    for (var i = 0; i < widget.options.length; i++) {
      _openControllers[i].dispose();
      _closeControllers[i].dispose();
    }
    super.dispose();
  }

  open() async {
    isOpen = true;
    start = false;
    for (final controller in _closeControllers) {
      controller.reset();
    }
    for (final controller in _openControllers) {
      controller.forward();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  close() async {
    isOpen = false;
    start = false;
    for (final controller in _openControllers) {
      controller.reset();
    }
    for (final controller in _closeControllers) {
      controller.forward();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end,children: (() {
      var items = <Widget>[];
      for (var i = 0; i < widget.options.length; i++) {
        items.add(Padding(
          padding: EdgeInsets.only(right: start ? 1000.0 : (isOpen ? _openAnimations[i].value : _closeAnimations[i].value)),
          child: ElevatedButton.icon(
            key: Key('${widget.options[i]} menu button'),
            onPressed: () {
              if (widget.onSelected != null) {
                widget.onSelected!(i);
              }
            },
            style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(10.0)
            ),
            icon: widget.icons[i],
            label: Text(widget.options[i], style: Theme.of(context).textTheme.displaySmall!)
          )
        ));
        items.add(const SizedBox(height: 10.0));
      }
      return items;
    })());
  }

}