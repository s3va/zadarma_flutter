import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlaySoundMp extends StatefulWidget {
  final String mp3url;

  PlaySoundMp({Key key, @required this.mp3url}) : super(key: key);

  @override
  _PlaySoundMpState createState() => _PlaySoundMpState();
}

class _PlaySoundMpState extends State<PlaySoundMp> {
  AudioPlayerState playerState = AudioPlayerState.COMPLETED;
  Duration _mp3duration;
  Duration _mp3position;
  AudioPlayer audioPlayer; // = AudioPlayer();
  double _sliderPosition = 0;

  @override
  void initState() {
    super.initState();

    AudioPlayer.logEnabled = true;
    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      if (mounted) setState(() => _mp3duration = d);
    });

    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      print('Current position: $p');
      if (mounted)
        setState(() {
          _mp3position = p;
          _sliderPosition = (_mp3position.inMilliseconds * 100 ~/ _mp3duration.inMilliseconds).toDouble();
        });
    });

    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
      print('Current player state: $s');
      if (mounted) setState(() => playerState = s);
    });

    audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      if (mounted)
        setState(() {
          playerState = AudioPlayerState.STOPPED;
          _mp3duration = Duration(seconds: 0);
          _mp3position = Duration(seconds: 0);
        });
    });

    audioPlayer.play(widget.mp3url, isLocal: false); //.then((value) => setState(() {}), onError: (e) => print("playing error: ${e.toString()}"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.mp3url.length > 30 ? widget.mp3url.substring(widget.mp3url.length - 29, widget.mp3url.length - 4) : 0}\n------------------------dd-hhmmss\n$_mp3duration\n$_mp3position"),
        toolbarHeight: 100,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Slider.adaptive(
                value: _sliderPosition,
                min: 0,
                max: 100,
                label: _sliderPosition.round().toString(),
                divisions: 100,
                onChanged: (v) {
                  setState(() {
                    _sliderPosition = v;
                    audioPlayer.seek(Duration(milliseconds: _mp3duration.inMilliseconds ~/ 100 * v.round()));
                  });
                }),
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          if (playerState == AudioPlayerState.PLAYING) {
                            audioPlayer.pause(); //.then((value) {
                            //setState(() { playerState=false; });
                            //},
                            //onError: (e,s) {
                            //print( "pause error: ${e.toString()}\n$s");
                            //return  audioPlayer.stop() ;
                            //},);//pauseAudio();
                          } else if (playerState == AudioPlayerState.PAUSED) {
                            audioPlayer.resume(); //.then((value) => setState(() {} ),
                            //onError: (e,s) {
                            //print("resume error: ${e.toString()}\n$s");
                            //return  audioPlayer.stop() ;
                            //},
                            //);//resumeAudio();
                          } else if (playerState == AudioPlayerState.STOPPED || playerState == AudioPlayerState.COMPLETED) {
                            audioPlayer.play(widget.mp3url);
                          }
                        },
                        child: Icon(playerState == AudioPlayerState.PLAYING ? Icons.pause : Icons.play_arrow),
                        color: Colors.blue,
                      ),
                      Icon(playerState == AudioPlayerState.STOPPED
                          ? Icons.stop
                          : playerState == AudioPlayerState.PLAYING
                              ? Icons.play_arrow
                              : playerState == AudioPlayerState.PAUSED ? Icons.pause : playerState == AudioPlayerState.COMPLETED ? Icons.close : Icons.radio_button_unchecked),
                      RaisedButton(
                        onPressed: () async {
                          //audioPlayer.stop() .then((value) => setState(() => _isPlaying=false) , onError: () => print( "stop error"));//stopAudio();
                          await audioPlayer.stop();
                          //setState(() => playerState=false); //, onError: () => print( "stop error"));//stopAudio();
                        },
                        child: Icon(Icons.stop),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     RaisedButton(
            //       onPressed: () async {
            //         var path =
            //         await FilePicker.getFilePath(type: FileType.audio);
            //         setState(() {
            //           _isPlaying = true;
            //         });
            //         playAudioFromLocalStorage(path);
            //       },
            //       child: Text(
            //         'Load Audio File',
            //         style: TextStyle(color: Colors.white),
            //       ),
            //       color: Colors.blueAccent,
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.stop();
    if (audioPlayer.state == AudioPlayerState.PLAYING) audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }
}
