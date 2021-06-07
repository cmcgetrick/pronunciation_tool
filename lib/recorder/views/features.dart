import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';

class FeaturesView extends StatefulWidget {
  final Function onUploadComplete;
  const FeaturesView({
    Key key,
    @required this.onUploadComplete,
  }) : super(key: key);
  @override
  _FeaturesState createState() => _FeaturesState();
}

class _FeaturesState extends State<FeaturesView> {
  bool _isp;
  bool _isu;
  bool _isrd;
  bool _isrg;

  AudioPlayer _ap;
  String _filePath;

  FlutterAudioRecorder _ar;

  @override
  void initState() {
    super.initState();
    _isp = false;
    _isu = false;
    _isrd = false;
    _isrg = false;
    _ap = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isrd
          ? _isu
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LinearProgressIndicator()),
                    Text('Uploading'),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.replay),
                      onPressed: _onRecordAgainButtonPressed,
                    ),
                    IconButton(
                      icon: Icon(_isp ? Icons.pause : Icons.play_arrow),
                      onPressed: _onPlayButtonPressed,
                    ),
                    IconButton(
                      icon: Icon(Icons.upload_file),
                      onPressed: _onFileUploadButtonPressed,
                    ),
                  ],
                )
          : IconButton(
              icon: _isrg ? Icon(Icons.pause) : Icon(Icons.fiber_manual_record),
              onPressed: _onRecordButtonPressed,
            ),
    );
  }

  Future<void> _onFileUploadButtonPressed() async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    setState(() {
      _isu = true;
    });
    try {
      await firebaseStorage
          .ref('upload-voice-firebase')
          .child(
              _filePath.substring(_filePath.lastIndexOf('/'), _filePath.length))
          .putFile(File(_filePath));
      widget.onUploadComplete();
    } catch (error) {
      print('Error occured while uplaoding to Firebase ${error.toString()}');
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occured while uplaoding'),
        ),
      );
    } finally {
      setState(() {
        _isu = false;
      });
    }
  }

  void _onRecordAgainButtonPressed() {
    setState(() {
      _isrd = false;
    });
  }

  Future<void> _onRecordButtonPressed() async {
    if (_isrg) {
      _ar.stop();
      _isrg = false;
      _isrd = true;
    } else {
      _isrd = false;
      _isrg = true;

      await _startRecording();
    }
    setState(() {});
  }

  void _onPlayButtonPressed() {
    if (!_isp) {
      _isp = true;

      _ap.play(_filePath, isLocal: true);
      _ap.onPlayerCompletion.listen((duration) {
        setState(() {
          _isp = false;
        });
      });
    } else {
      _ap.pause();
      _isp = false;
    }
    setState(() {});
  }

  Future<void> _startRecording() async {
    final bool hasRecordingPermission =
        await FlutterAudioRecorder.hasPermissions;
    if (hasRecordingPermission) {
      Directory directory = await getApplicationDocumentsDirectory();
      String filepath = directory.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.aac';
      _ar = FlutterAudioRecorder(filepath, audioFormat: AudioFormat.AAC);
      await _ar.initialized;
      _ar.start();
      _filePath = filepath;
      setState(() {});
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Center(
          child: Text('Please enable recording permission'),
        ),
      ));
    }
  }
}
