import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AudioView extends StatefulWidget {
  final List<Reference> rf;
  const AudioView({
    Key key,
    @required this.rf,
  }) : super(key: key);

  @override
  _AudioViewState createState() => _AudioViewState();
}

class _AudioViewState extends State<AudioView> {
  bool isPlaying;
  AudioPlayer audioPlayer;
  int selectedIndex;

  @override
  void initState() {
    super.initState();
    isPlaying = false;
    audioPlayer = AudioPlayer();
    selectedIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.rf.length,
      reverse: true,
      itemBuilder: (BuildContext context, int index) {
        if (widget.rf.elementAt(index).name.contains('.aac')) {
          return ListTile(
            title: Text('Comer Attempt #' + (index + 1).toString()),
            trailing: IconButton(
              icon: selectedIndex == index
                  ? Icon(Icons.pause)
                  : Icon(Icons.play_arrow),
              onPressed: () => _onListTileButtonPressed(index),
            ),
          );
        } else
          return ListTile(
            title: Text(widget.rf.elementAt(index).name),
            trailing: IconButton(
              icon: selectedIndex == index
                  ? Icon(Icons.pause)
                  : Icon(Icons.play_arrow),
              onPressed: () => _onListTileButtonPressed(index),
            ),
          );
      },
    );
  }

  Future<void> _onListTileButtonPressed(int index) async {
    setState(() {
      selectedIndex = index;
    });
    audioPlayer.play(await widget.rf.elementAt(index).getDownloadURL(),
        isLocal: false);

    audioPlayer.onPlayerCompletion.listen((duration) {
      setState(() {
        selectedIndex = -1;
      });
    });
  }
}
