import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:lean_coffee_timer/model/task_model.dart';
import 'package:lean_coffee_timer/widgets/wave_animation.dart';

class TimerPage extends StatefulWidget {
  final Task task;

  TimerPage({Key key, @required this.task}) : super(key: key);

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin {
  Timer timer;
  AudioCache audioCache;
  AudioPlayer player;

  Task get task => widget.task;

  /// Store the time
  /// You will pass the minutes.
  String timeText = '';
  String statusText = '';
  String buttonText = 'Iniciar';
  IconData buttonIcon = Icons.play_circle_outline;

  String alarmFile = 'analogwatch.mp3';
  bool finished = false;

  Stopwatch stopwatch = Stopwatch();
  static const delay = Duration(microseconds: 1);
  Duration duration;

  /// for animation
  var begin = 0.0;
  Animation<double> heightSize;
  AnimationController _controller;

  /// Called each time the time is ticking
  void updateClock() {
    duration = Duration(
        hours: task.hours, minutes: task.minutes, seconds: task.seconds);
    // if time is up, stop the timer
    if (stopwatch.elapsed.inMilliseconds >= duration.inMilliseconds) {
      print('--finished Timer Page--');
      stopwatch.stop();
      stopwatch.reset();
      _controller.stop(canceled: false);
      setState(() {
        statusText = 'Terminado';
        buttonText = "Reiniciar";
        buttonIcon = Icons.refresh;
        audioCache.play(alarmFile);
        finished = true;
      });
      return;
    } else {
      statusText = '';
    }

    final millisecondsRemaining =
        duration.inMilliseconds - stopwatch.elapsed.inMilliseconds;
    final hoursRemaining =
        ((millisecondsRemaining / (1000 * 60 * 60)) % 24).toInt();
    final minutesRemaining =
        ((millisecondsRemaining / (1000 * 60)) % 60).toInt();
    final secondsRemaining = ((millisecondsRemaining / 1000) % 60).toInt();

    setState(() {
      timeText = '${hoursRemaining.toString().padLeft(2, '0')}:'
          '${minutesRemaining.toString().padLeft(2, '0')}:'
          '${secondsRemaining.toString().padLeft(2, '0')}';
    });

    if (stopwatch.isRunning) {
      setState(() {
        buttonText = "Contando";
        buttonIcon = Icons.play_circle_filled;
      });
    } else if (stopwatch.elapsed.inMilliseconds == 0 && begin == 0.0) {
      setState(() {
        timeText = '${task.hours.toString().padLeft(2, "0")}:'
            '${task.minutes.toString().padLeft(2, '0')}:'
            '${task.seconds.toString().padLeft(2, '0')}';
        buttonText = "Iniciar";
        buttonIcon = Icons.play_circle_outline;
      });
    } else if(!finished){
      setState(() {
        buttonText = "Pausado";
        buttonIcon = Icons.pause_circle_outline;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    player = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    audioCache = AudioCache(fixedPlayer: player);
    duration = Duration(
        days: 0,
        hours: task.hours,
        minutes: task.minutes,
        seconds: task.seconds);
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    timer = Timer.periodic(delay, (Timer t) => updateClock());
  }

  @override
  void dispose() {
    player.dispose();
    _controller.dispose();
    stopwatch.stop();
    timer.cancel();
    super.dispose();
  }

  void _restartCountDown() {
    begin = 0.0;
    _controller.reset();
    stopwatch.stop();
    stopwatch.reset();
  }

  @override
  Widget build(BuildContext context) {
    heightSize =
        new Tween(begin: begin, end: MediaQuery.of(context).size.height - 65)
            .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Size size = Size(MediaQuery.of(context).size.width, heightSize.value);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return DemoBody(size: size, color: task.color);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 4.0, right: 4.0),
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.navigate_before,
                      size: 40.0,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.sync,
                    size: 32.0,
                    color: Colors.white70,
                  ),
                  onPressed: _restartCountDown,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(bottom: 250),
              child: Center(
                child: Text(
                  task.title,
                  style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(bottom: 100),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      timeText,
                      style: TextStyle(fontSize: 54.0, color: Colors.white),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.white70,
                        child: InkWell(
                            child: SizedBox(
                                width: 150,
                                height: 150,
                                child: Icon(buttonIcon,
                                    size: 60.0, color: Colors.black87)),
                            splashColor: Colors.red,
                            onTap: () {
                              if (stopwatch.isRunning) {
                                print('--Paused--');
                                stopwatch.stop();
                                _controller.stop(canceled: false);
                              } else if (begin != 0.0 && !stopwatch.isRunning) {
                                _restartCountDown();
                              } else {
                                print('--Running--');
                                finished = false;
                                begin = 50.0;
                                stopwatch.start();
                                _controller.forward();
                              }
                              updateClock();
                            }),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Text(buttonText,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18.0,
                          )),
                    ),
                  ]),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Parar Alarme",
        child: (player.state == AudioPlayerState.PLAYING)
            ? Icon(Icons.stop, size: 26, color: Colors.red[300])
            : Icon(Icons.music_note, size: 26, color: Colors.black),
        backgroundColor: Colors.white70,
        onPressed: () => (player.state == AudioPlayerState.PLAYING)
            ? player.stop()
            : audioCache.play(alarmFile),
      ),
    );
  }
}
