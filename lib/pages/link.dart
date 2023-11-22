import 'package:flutter/material.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/notesview.dart';
import 'package:linknotes/widgets/contentcontainer.dart';

class LinkPage extends StatefulWidget {

  final Link link;

  const LinkPage({super.key, required this.link});

  @override
  State<LinkPage> createState() => _LinkState();

}

class _LinkState extends State<LinkPage> {

  late Link _link;

  @override
  void initState() {
    super.initState();
    _link = Link(
      source: widget.link.source.clone(),
      linkType: widget.link.linkType,
      combineNames: false
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context)),
        title: Text('Link', style: Theme.of(context).textTheme.displayMedium!)
      ),
      body: ContentContainer(maxWidth: 300.0, child: Column(
        children: [
          const SizedBox(height: 50.0),
          Text('Source:', style: Theme.of(context).textTheme.displayMedium!),
          const SizedBox(height: 10.0),
          NoteView(note: _link.source, onPressed: (_) {}),
          const SizedBox(height: 10.0),
          Center(child: SizedBox(
            width: 200.0,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Change source', style: Theme.of(context).textTheme.displaySmall!)
            )
          )),
          const SizedBox(height: 50.0),
          Text('Link type:', style: Theme.of(context).textTheme.displayMedium!),
          const SizedBox(height: 10.0),
          Center(child: SizedBox(
            width: 200.0,
            child: ElevatedButton(
              onPressed: () => setState(() {
                for (var i = 0; i < LinkType.values.length; i++) {
                  if (_link.linkType == LinkType.values[i]) {
                    setState(() {
                      _link.linkType = LinkType.values[
                        i == LinkType.values.length - 1 ? 0 : i + 1
                      ]; 
                    });
                    return;
                  }
                }
              }),
              child: Text((() {
                switch (_link.linkType) {
                  case LinkType.combine:
                    return 'Combine';
                  case LinkType.multiply:
                    return 'Multiply';
                  case LinkType.replace:
                    return 'Replace';
                  case LinkType.distribute:
                    return 'Distribute';
                  case LinkType.parallel:
                    return 'Parallel';
                  default:
                    return '';
                }
                
              })(), style: Theme.of(context).textTheme.displaySmall!)
            )
          )),
          const Spacer(),
          Center(child: SizedBox(
            width: 200.0,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.link_off, color: Theme.of(context).primaryColor),
              label: Text('Unlink', style: Theme.of(context).textTheme.displaySmall!),
            )
          )),
          const SizedBox(height: 10.0)
        ],
      ))
    ));
  }

}