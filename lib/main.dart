import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
//import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // root widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    /*required this.title*/
  }) : super(key: key);
  //final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // bg color
  //Color bgColor = const Color(0XFF2A2A2A); //Colors.black;

  //define on audio plugin
  final OnAudioQuery _audioQuery = OnAudioQuery();

  //today
  //player
  final AudioPlayer _player = AudioPlayer();

  //more variables
  List<SongModel> songs = [];
  String currentSongTitle = '';
  int currentIndex = 0;

  bool isPlayerViewVisible = false;

  //define a method to set the player view visibility
  void _changePlayerViewVisibility() {
    setState(() {
      isPlayerViewVisible = !isPlayerViewVisible;
    });
  }

  //duration state stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _player.positionStream,
          _player.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    requestStoragePermission();

    //update the current playing song index listener
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  //dispose the player when done
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Color shadowColor = Color.fromARGB(255, 107, 107, 107);
  Color blackColor = Color.fromARGB(255, 26, 26, 26);
  Color whiteColor = Colors.white;
  Color textColor = Colors.white;
  //late Color currentColor;
  Color currentColor = Colors.black;
  @override
  Widget build(BuildContext context) {
    if (isPlayerViewVisible) {
      return Scaffold(
        backgroundColor: currentColor,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56.0, right: 20.0, left: 20.0),
            decoration: BoxDecoration(),
            child: Column(
              children: <Widget>[
                //exit button and the song title
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap:
                            _changePlayerViewVisibility, //hides the player view
                        child: Container(
                          padding: const EdgeInsets.only(right: 10),
                          // decoration: getDecoration(
                          //     BoxShape.rectangle, const Offset(2, 2), 2.0, 0.0),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: textColor,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        currentSongTitle,
                        style: TextStyle(
                          color: textColor,
                          //fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      flex: 5,
                    ),
                  ],
                ),

                // artwork container
                Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        offset: const Offset(
                          5.0,
                          5.0,
                        ),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ), //BoxShadow
                      BoxShadow(
                        color: shadowColor,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ],
                  ),
                  margin: const EdgeInsets.only(top: 30, bottom: 10),
                  child: QueryArtworkWidget(
                    id: songs[currentIndex].id,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(0.0),
                  ),
                ),

                //slider , position and duration widgets
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          //go to playlist btn
                          // Flexible(
                          //   child: InkWell(
                          //     onTap: () {
                          //       _changePlayerViewVisibility();
                          //     },
                          //     child: Container(
                          //       padding: const EdgeInsets.all(10.0),
                          //       decoration: getDecoration(
                          //           BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                          //       child: const Icon(
                          //         Icons.list_alt,
                          //         color: Colors.white70,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          //shuffle playlist
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                _player.setShuffleModeEnabled(true);
                                toast(context, "Shuffling enabled");
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                // margin: const EdgeInsets.only(right: 30.0),
                                // decoration: getDecoration(BoxShape.circle,
                                //     const Offset(2, 2), 2.0, 0.0),
                                child: Icon(
                                  Icons.shuffle,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),

                          //repeat mode
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                _player.loopMode == LoopMode.one
                                    ? _player.setLoopMode(LoopMode.all)
                                    : _player.setLoopMode(LoopMode.one);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                // decoration: getDecoration(BoxShape.circle,
                                //     const Offset(2, 2), 2.0, 0.0),
                                child: StreamBuilder<LoopMode>(
                                  stream: _player.loopModeStream,
                                  builder: (context, snapshot) {
                                    final loopMode = snapshot.data;
                                    if (LoopMode.one == loopMode) {
                                      return Icon(
                                        Icons.repeat_one,
                                        color: textColor,
                                      );
                                    }
                                    return Icon(
                                      Icons.repeat,
                                      color: textColor,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //slider bar container
                    Container(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(
                          bottom: 4.0, left: 10, right: 10, top: 20),
                      // decoration: getRectDecoration(BorderRadius.circular(0.0),
                      //const Offset(0, 0), 1.0, 0.0),

                      //slider bar duration state stream
                      //progress bar of song
                      child: StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress =
                              durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;

                          return ProgressBar(
                            progress: progress,
                            barCapShape: BarCapShape.square,
                            total: total,
                            barHeight: 4.0,
                            baseBarColor: shadowColor,
                            progressBarColor: textColor,
                            thumbColor: textColor,
                            timeLabelTextStyle: TextStyle(
                              fontSize: 15,
                              color: textColor,
                            ),
                            onSeek: (duration) {
                              _player.seek(duration);
                            },
                          );
                        },
                      ),
                    ),

                    //position /progress and total text
                  ],
                ),

                //prev, play/pause & seek next control buttons
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //skip to previous
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            if (_player.hasPrevious) {
                              _player.seekToPrevious();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            // decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(50),
                            // border:
                            //     Border.all(width: 2, color: shadowColor)),
                            child: Icon(
                              Icons.skip_previous,
                              color: textColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      //play pause
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            if (_player.playing) {
                              _player.pause();
                            } else {
                              if (_player.currentIndex != null) {
                                _player.play();
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            margin: const EdgeInsets.all(0.0),
                            decoration: ShapeDecoration(
                              shape: CircleBorder(),
                              color: Color.fromARGB(161, 96, 96, 96),
                              // other arguments
                            ),
                            child: StreamBuilder<bool>(
                              stream: _player.playingStream,
                              builder: (context, snapshot) {
                                bool? playingState = snapshot.data;
                                if (playingState != null && playingState) {
                                  return const Icon(
                                    Icons.pause,
                                    size: 40,
                                    color: Colors.white,
                                  );
                                }
                                return const Icon(
                                  Icons.play_arrow,
                                  size: 40,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      //skip to next
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            if (_player.hasNext) {
                              _player.seekToNext();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            // decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(50),
                            //     border:
                            //         Border.all(width: 2, color: shadowColor)),
                            child: Icon(
                              Icons.skip_next,
                              color: textColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //go to playlist, shuffle , repeat all and repeat one control buttons
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const GradientText(
          'GINGER',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          gradient: LinearGradient(colors: [
            Color(0xFFFDC630),
            Color(0xFFF37435),
          ]),
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (currentColor == Colors.black) {
                  currentColor = Colors.white;
                  textColor = Colors.black;
                  shadowColor = Color.fromARGB(255, 203, 203, 203);
                } else {
                  currentColor = Colors.black;
                  textColor = Colors.white;
                  shadowColor = Color.fromARGB(255, 91, 91, 91);
                }
              },
              icon: Icon(
                Icons.dark_mode,
                color: textColor,
              ))
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: currentColor,
      body: FutureBuilder<List<SongModel>>(
        //default values
        future: _audioQuery.querySongs(
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          //loading content indicator
          if (item.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          //no songs found
          if (item.data!.isEmpty) {
            return const Center(
              child: Text("No Songs Found"),
            );
          }

          // You can use [item.data!] direct or you can create a list of songs as
          // List<SongModel> songs = item.data!;
          //showing the songs

          //add songs to the song list
          songs.clear();
          songs = item.data!;
          return ListView.builder(
              itemCount: item.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.only(top: 0.0, left: 12.0, right: 16.0),
                  padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                  decoration: BoxDecoration(
                    color: currentColor,
                  ),
                  child: ListTile(
                    textColor: textColor,
                    title: Text(item.data![index].title),
                    subtitle: Text(
                      item.data![index].displayName,
                      style: TextStyle(
                        color: Color.fromARGB(255, 132, 132, 132),
                      ),
                    ),
                    //trailing: const Icon(Icons.more_vert),
                    leading: QueryArtworkWidget(
                      id: item.data![index].id,
                      type: ArtworkType.AUDIO,
                      artworkBorder: BorderRadius.circular(0.0),
                    ),
                    onTap: () async {
                      //show the player view
                      _changePlayerViewVisibility();

                      toast(context, "Playing:  " + item.data![index].title);
                      // Try to load audio from a source and catch any errors.
                      //  String? uri = item.data![index].uri;
                      // await _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
                      await _player.setAudioSource(createPlaylist(item.data!),
                          initialIndex: index);
                      await _player.play();
                    },
                  ),
                );
              });
        },
      ),
    );
  }

  //define a toast method
  void toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
    ));
  }

  void requestStoragePermission() async {
    //only if the platform is not web, coz web have no permissions
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }

      //ensure build method is called
      setState(() {});
    }
  }

  //create playlist
  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  //update playing song details
  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }

  BoxDecoration getDecoration(
      BoxShape shape, Offset offset, double blurRadius, double spreadRadius) {
    return BoxDecoration(
      color: blackColor,
      shape: shape,
      boxShadow: [
        BoxShadow(
          offset: -offset,
          color: Colors.white24,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          offset: offset,
          color: Colors.black,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        )
      ],
    );
  }

  BoxDecoration getRectDecoration(BorderRadius borderRadius, Offset offset,
      double blurRadius, double spreadRadius) {
    return BoxDecoration(
      borderRadius: borderRadius,
      color: blackColor,
      boxShadow: [
        BoxShadow(
          offset: -offset,
          color: Colors.white24,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          offset: offset,
          color: Colors.black,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        )
      ],
    );
  }
}

//duration class
class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}

Color getAverageColor(List<Color> colors) {
  int r = 0, g = 0, b = 0;

  for (int i = 0; i < colors.length; i++) {
    r += colors[i].red;
    g += colors[i].green;
    b += colors[i].blue;
  }

  r = r ~/ colors.length;
  g = g ~/ colors.length;
  b = b ~/ colors.length;

  return Color.fromRGBO(r, g, b, 1);
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, 100, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
