import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speech/recorder/views/firebase_list.dart';
import 'package:flutter_speech/recorder/views/features.dart';

class BaseView extends StatefulWidget {
  @override
  _BaseViewState createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  List<Reference> rf;

  @override
  void initState() {
    super.initState();
    _onUploadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pronunciation Practice'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: rf == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: LinearProgressIndicator(),
                        ),
                        Text('Retrieving data')
                      ],
                    )
                  : rf.isEmpty
                      ? Center(
                          child: Text('No files found'),
                        )
                      : AudioView(
                          rf: rf,
                        ),
            ),
            Expanded(
              flex: 2,
              child: FeaturesView(
                onUploadComplete: _onUploadComplete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onUploadComplete() async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    ListResult returned =
        await firebaseStorage.ref().child('upload-voice-firebase').list();
    setState(() {
      rf = returned.items;
    });
  }
}
