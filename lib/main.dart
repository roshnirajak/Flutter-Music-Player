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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterPlay Songs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'FlutterPlay Songs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
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

  Color allColor = Color.fromARGB(255, 26, 26, 26);
  @override
  Widget build(BuildContext context) {
    if (isPlayerViewVisible) {
      return Scaffold(
        backgroundColor: allColor,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56.0, right: 20.0, left: 20.0),
            decoration: BoxDecoration(),
            child: Column(
              children: <Widget>[
                //exit button and the song title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap:
                            _changePlayerViewVisibility, //hides the player view
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: getDecoration(
                              BoxShape.rectangle, const Offset(2, 2), 2.0, 0.0),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        currentSongTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      flex: 5,
                    ),
                  ],
                ),

                // artwork container
                Container(
                  width: 300,
                  height: 300,
                  // decoration: getDecoration(
                  //     BoxShape.rectangle, const Offset(0, 0), 0, 0),
                  margin: const EdgeInsets.only(top: 30, bottom: 30),
                  child: QueryArtworkWidget(
                    id: songs[currentIndex].id,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(0.0),
                  ),
                ),

                //slider , position and duration widgets
                Column(
                  children: [
                    //slider bar container
                    Container(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(
                          bottom: 4.0, left: 10, right: 10),
                      // decoration: getRectDecoration(BorderRadius.circular(0.0),
                      //     const Offset(0, 0), 1.0, 0.0),

                      //slider bar duration state stream
                      child: StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress =
                              durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;

                          return ProgressBar(
                            progress: progress,
                            total: total,
                            barHeight: 4.0,
                            baseBarColor: Color.fromARGB(68, 255, 255, 255),
                            progressBarColor:
                                Color.fromARGB(255, 255, 255, 255),
                            thumbColor: Color.fromARGB(255, 255, 255, 255),
                            timeLabelTextStyle: const TextStyle(
                              fontSize: 0,
                            ),
                            onSeek: (duration) {
                              _player.seek(duration);
                            },
                          );
                        },
                      ),
                    ),

                    //position /progress and total text
                    StreamBuilder<DurationState>(
                      stream: _durationStateStream,
                      builder: (context, snapshot) {
                        final durationState = snapshot.data;
                        final progress =
                            durationState?.position ?? Duration.zero;
                        final total = durationState?.total ?? Duration.zero;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: Text(
                                progress.toString().split(".")[0],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                total.toString().split(".")[0],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                //prev, play/pause & seek next control buttons
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
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
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    width: 2,
                                    color: Color.fromARGB(38, 255, 255, 255))),
                            child: const Icon(
                              Icons.skip_previous,
                              color: Color.fromARGB(255, 255, 255, 255),
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
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    width: 2,
                                    color: Color.fromARGB(38, 255, 255, 255))),
                            child: const Icon(
                              Icons.skip_next,
                              color: Color.fromARGB(255, 255, 255, 255),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //go to playlist, shuffle , repeat all and repeat one control buttons
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //go to playlist btn
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            _changePlayerViewVisibility();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: getDecoration(
                                BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: const Icon(
                              Icons.list_alt,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      //shuffle playlist
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            _player.setShuffleModeEnabled(true);
                            toast(context, "Shuffling enabled");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin:
                                const EdgeInsets.only(right: 30.0, left: 30.0),
                            decoration: getDecoration(
                                BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: const Icon(
                              Icons.shuffle,
                              color: Colors.white70,
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
                            decoration: getDecoration(
                                BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: StreamBuilder<LoopMode>(
                              stream: _player.loopModeStream,
                              builder: (context, snapshot) {
                                final loopMode = snapshot.data;
                                if (LoopMode.one == loopMode) {
                                  return const Icon(
                                    Icons.repeat_one,
                                    color: Colors.white70,
                                  );
                                }
                                return const Icon(
                                  Icons.repeat,
                                  color: Colors.white70,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        //backgroundColor: bgColor,
        elevation: 20,
        backgroundColor: allColor,
      ),
      backgroundColor: allColor,
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
                      const EdgeInsets.only(top: 15.0, left: 12.0, right: 16.0),
                  padding: const EdgeInsets.only(top: 30.0, bottom: 30),
                  decoration: BoxDecoration(
                    color: allColor,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4.0,
                        offset: Offset(-4, -4),
                        color: Colors.white24,
                      ),
                      BoxShadow(
                        blurRadius: 4.0,
                        offset: Offset(4, 4),
                        color: Colors.black,
                      ),
                    ],
                  ),
                  child: ListTile(
                    textColor: Colors.white,
                    title: Text(item.data![index].title),
                    subtitle: Text(
                      item.data![index].displayName,
                      style: const TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                    trailing: const Icon(Icons.more_vert),
                    leading: QueryArtworkWidget(
                      id: item.data![index].id,
                      type: ArtworkType.AUDIO,
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
      color: allColor,
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
      color: allColor,
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


























// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:on_audio_query/on_audio_query.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FlutterPlay Songs',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'FlutterPlay Songs'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   // bg color
//   Color bgColor = Colors.brown;

//   //define on audio plugin
//   final OnAudioQuery _audioQuery = OnAudioQuery();

//   //request permission from initStateMethod
//   @override
//   void initState() {
//     super.initState();
//     requestStoragePermission();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//         //backgroundColor: bgColor,
//         elevation: 20,
//         backgroundColor: bgColor,
//       ),
//       backgroundColor: bgColor,
//       body: FutureBuilder<List<SongModel>>(
//         //default values
//         future: _audioQuery.querySongs(
//           orderType: OrderType.ASC_OR_SMALLER,
//           uriType: UriType.EXTERNAL,
//           ignoreCase: true,
//         ),
//         builder: (context, item) {
//           //loading content indicator
//           if (item.data == null) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           //no songs found
//           if (item.data!.isEmpty) {
//             return const Center(
//               child: Text("No Songs Found"),
//             );
//           }

//           // You can use [item.data!] direct or you can create a list of songs as
//           // List<SongModel> songs = item.data!;
//           //showing the songs
//           return ListView.builder(
//               itemCount: item.data!.length,
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin:
//                       const EdgeInsets.only(top: 15.0, left: 12.0, right: 16.0),
//                   padding: const EdgeInsets.only(top: 30.0, bottom: 30),
//                   decoration: BoxDecoration(
//                     color: bgColor,
//                     borderRadius: BorderRadius.circular(20.0),
//                     boxShadow: const [
//                       BoxShadow(
//                         blurRadius: 4.0,
//                         offset: Offset(-4, -4),
//                         color: Colors.white24,
//                       ),
//                       BoxShadow(
//                         blurRadius: 4.0,
//                         offset: Offset(4, 4),
//                         color: Colors.black,
//                       ),
//                     ],
//                   ),
//                   child: ListTile(
//                     textColor: Colors.white,
//                     title: Text(item.data![index].title),
//                     subtitle: Text(
//                       item.data![index].displayName,
//                       style: const TextStyle(
//                         color: Colors.white60,
//                       ),
//                     ),
//                     trailing: const Icon(Icons.more_vert),
//                     leading: QueryArtworkWidget(
//                       id: item.data![index].id,
//                       type: ArtworkType.AUDIO,
//                     ),
//                     onTap: () {
//                       //toast message showing he selected song title
//                       toast(context,
//                           "You Selected:   " + item.data![index].title);
//                     },
//                   ),
//                 );
//               });
//         },
//       ),
//     );
//   }

//   //define a toast method
//   void toast(BuildContext context, String text) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(text),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
//     ));
//   }

//   void requestStoragePermission() async {
//     //only if the platform is not web, coz web have no permissions
//     if (!kIsWeb) {
//       bool permissionStatus = await _audioQuery.permissionsStatus();
//       if (!permissionStatus) {
//         await _audioQuery.permissionsRequest();
//       }

//       //ensure build method is called
//       setState(() {});
//     }
//   }
// }


































// import 'package:flutter/material.dart';
// import 'dart:ui';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         debugShowCheckedModeBanner: false,
//         home: MyHomePage());
//   }
// }

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Color.fromARGB(255, 58, 57, 99),
//                 Color.fromARGB(255, 0, 0, 0)
//               ]),
//         ),
//         child: Column(children: [
//           //--Heading: Vanilla and Menu--//
//           Container(
//               padding: EdgeInsets.only(top: 40, left: 20, right: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Vanilla",
//                     style: TextStyle(
//                         fontSize: 32,
//                         fontFamily: 'Vanilla',
//                         color: Colors.white),
//                   ),
//                   IconButton(
//                       onPressed: () {},
//                       icon: Icon(
//                         Icons.more_vert,
//                         color: Colors.white,
//                         size: 32,
//                       ))
//                 ],
//               )),

//           Divider(
//             color: Color.fromARGB(100, 255, 255, 255),
//           ),

//           //--Scrollable Track list--//
//           SingleChildScrollView(child: Stack(children:[Row(children: [],)])),

//           ClipRect(
//               child: Align(
//             alignment: Alignment.bottomCenter,
//             child: new BackdropFilter(
//                 filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                 child: new Container(
//                     width: double.infinity,
//                     height: 60.0,
//                     decoration: new BoxDecoration(
//                         color: Color.fromARGB(0, 0, 0, 0).withOpacity(0.1)),
//                     child: new Center(
//                       child: new Text(
//                         'Frosted',
//                       ),
//                     ))),
//           ))
//         ]),
//       ),
//     );
//   }
// }
