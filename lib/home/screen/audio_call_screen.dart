import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';
import '../../login/provider/login provider.dart';
import '../../utils/app&token_id.dart';
import '../../utils/app_images.dart';
import '../../utils/get_it.dart';
import 'home_screen.dart';

class AudioCallScreen extends StatefulWidget {
  final String? name;
  final ClientRole? clientRole;
  final String? callType;
  final String? number;
  final String? channelName;

  const AudioCallScreen({
    Key? key,
    this.clientRole,
    this.name,
    this.callType,
    this.number,
    this.channelName
  }) : super(key: key);

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool speaker = false;
  bool hold = false;
  bool camera = false;
  late RtcEngine _engine;
  late Timer _timer;
  int _startSecond = 0;
  int _startMinutes = 0;
  int _startHour = 0;
  int callSeconds = 0;
  final int timerMaxSeconds = 0;
  int userId = 0;
  int streamId = 0;
  int userCount = 0;

  int chanelCount = 0;
  bool toolbarShow = false;
  final loginProvider = getIt<LoginProvider>();

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    debugPrint("client role121212 ${widget.callType}");
    debugPrint("client role ${widget.name}");
    debugPrint("client role111 ${widget.clientRole}");
    debugPrint("client role ${widget.number}");
    debugPrint("client role ${widget.channelName}");
    super.initState();
    widget.callType == "voice" ? null : _handleCameraAndMic(Permission.camera);
    _handleCameraAndMic(Permission.microphone);
    initialize();
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    await permission.request();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers(context);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(Token, widget.channelName.toString(), null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    widget.callType == "voice"
        ? await _engine.enableAudio()
        : await _engine.enableVideo();
    await _engine.enableLocalAudio(true);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.clientRole!);
    widget.callType == "voice" ? _engine.setEnableSpeakerphone(false) : null;
  }
  /// Add agora event handlers
  void _addAgoraEventHandlers(BuildContext context) async {
    if (ClientRole.Broadcaster == ClientRole.Broadcaster) {
      _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        userId = uid;
        final info = 'onJoinChannel: "${widget.channelName}", uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        if (_users.length >= 1) {
          _users.clear();
        }
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        userId = uid;
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
        debugPrint("info user ${_infoStrings}");
        callTimer();
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
        userCount = _users.length;
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
    }
  }

  void callTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_users.length >= 1) {
          if (_startSecond == 59) {
            _startSecond = 0;
            setState(() {});
          } else {
            _startSecond++;
            setState(() {});
          }
        } else {
          _startSecond = 0;
          _startMinutes = 0;
          _startHour = 0;
          // setState(() {});
        }
      },
    );
    const oneMinutes = Duration(minutes: 1);
    _timer = Timer.periodic(
      oneMinutes,
      (Timer timer) {
        if (_startMinutes == 59) {
          _startMinutes = 0;
          setState(() {});
        } else {
          _startMinutes++;
          setState(() {});
        }
      },
    );
    const oneHour = Duration(hours: 1);
    _timer = Timer.periodic(
      oneHour,
      (Timer timer) {
        if (_startHour == 59) {
          _startHour = 0;
        } else {
          _startHour++;
          setState(() {});
        }
      },
    );
  }

  Widget callTimerStart() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        _startHour >= 0
            ? '${((timerMaxSeconds + _startMinutes) ~/ 1).toString().padLeft(2, '0')}:${((timerMaxSeconds + _startSecond) % 60).toString().padLeft(2, '0')}'
            : '${((timerMaxSeconds + _startHour) ~/ 1).toString().padLeft(2, '0')}:${((timerMaxSeconds + _startMinutes) ~/ 1).toString().padLeft(2, '0')}:${((timerMaxSeconds + _startSecond) % 60).toString().padLeft(2, '0')}',
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
      ),
    ]);
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.clientRole == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) {
      list.add(RtcRemoteView.SurfaceView(channelId: "${widget.channelName}", uid: uid));
    });

    setState(() {
      userCount = list.length;
      debugPrint("1111....... ${list}");
    });
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }
  Widget _videoViewList(view) {
    return Container(child: view);
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Row(
      children: wrappedViews,
    );
  }

  @override
  Widget build(BuildContext context) {
    double wid = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    _infoStrings.map((e) => debugPrint("userss... ${e}")).toList();
    debugPrint("User info ${_infoStrings.length}");
    // if (_users.length == 1) {
    //   Future.delayed(const Duration(seconds: 1), () {
    //     if (_users.isEmpty) {
    //       _onReciverEnd(context);
    //     }
    //   });
    // }
    // Future.delayed(const Duration(seconds: 30), () {
    if (_users.length >= 1) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_users.isEmpty) {
          _onReciverEnd(context);
        }
      });
    } else {
      debugPrint("user else ${_users}");
      debugPrint("user else ${_users.length}");
      debugPrint("user else ${_infoStrings.isEmpty}");
      Future.delayed(const Duration(seconds: 30), () {
        if (_users.length >= 1 && _infoStrings.isEmpty) {
          print("call end id part");
          _onNotReciverEnd(context);
        }else if(_users.length == 0){
          _onNotReciverEnd(context);
        }
      });
    }

    return Scaffold(
        body: Stack(
          children: [
            Container(
                height: height,
                width: wid,
                decoration: const BoxDecoration(
                  color: Colors.purpleAccent,
                  image: DecorationImage(
                    image: AssetImage("assets/images/backimage.jpeg"),
                    fit: BoxFit.cover,
                  ),
                )),
            InkWell(
              onTap: () {
                setState(() {
                  toolbarShow = !toolbarShow;
                });
              },
              child: Stack(
                children: <Widget>[
                  // camera ? const Center(child: Text("Camera Off")) : Container(),
                  widget.callType == "voice" ? const Text("") : _viewRows(),
                  // widget.call == "voice" ? const Text("") : _panel(),
                  if (widget.callType == "video") ...{
                    if (!toolbarShow) ...{
                      _toolbar(),
                    }
                  } else ...{
                    _toolbar(),
                  }
                ],
              ),
            ),
          ],
        ));
  }

  Widget _toolbar() {
    double height = MediaQuery.of(context).size.height;
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (widget.clientRole == ClientRole.Broadcaster) {
      debugPrint("if Part");
      return Container(
        alignment: Alignment.bottomCenter,
        // padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !isLandscape ? const SizedBox(height: 50) : Container(),
            widget.callType == "Audience"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Live...  ',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Wrap(
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              color: Colors.black,
                              size: 30,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          /*  Text("${userCount}",
                              style: const TextStyle(
                                  fontSize: 25, color: Colors.white),
                            ),
                            SizedBox(width: 5),*/
                          ],
                        )
                      ])
                : const SizedBox.shrink(),
            widget.callType == "voice"
                ? const Icon(Icons.account_circle, size: 120)
                : widget.callType == "Audience"
                    ? Container()
                    : _users.isEmpty
                        ? const Icon(Icons.account_circle, size: 120)
                        : Container(),
            const SizedBox(height: 5),
            widget.callType == "voice"
                ? Text("${widget.name}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, color: Colors.white))
                : widget.callType == "Audience"
                    ? Container()
                    : _users.isEmpty
                        ? Text("${widget.name}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white))
                        : Container(),
            const SizedBox(height: 2),
            widget.callType == "voice"
                ? _users.length >= 1
                    ? Container(
                        child: callTimerStart(),
                      )
                    : const Text("00:00",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20))
                : Container(),
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    RawMaterialButton(
                      onPressed: _users.length >= 1
                          ? _onToggleMute
                          : widget.callType == "Audience"
                              ? _onToggleMute
                              : null,
                      child: Icon(
                        muted ? Icons.mic_off : Icons.mic,
                        color: _users.length >= 1
                            ? muted
                                ? Colors.white
                                : Colors.blueAccent
                            : widget.callType == "Audience"
                                ? muted
                                    ? Colors.white
                                    : Colors.blueAccent
                                : Colors.blueAccent,
                        size: 20.0,
                      ),
                      shape: const CircleBorder(),
                      elevation: 2.0,
                      fillColor: _users.length >= 1
                          ? muted
                              ? Colors.blueAccent
                              : Colors.white
                          : widget.callType == "Audience"
                              ? muted
                                  ? Colors.blueAccent
                                  : Colors.white
                              : Colors.white,
                      padding: const EdgeInsets.all(12.0),
                    ),
                    const SizedBox(height: 10),
                    _users.isEmpty
                        ? const Text("Mute",
                            style: TextStyle(color: Colors.black45))
                        : muted
                            ? const Text("Muted",
                                style: TextStyle(color: Colors.black45))
                            : const Text("Mute",
                                style: TextStyle(color: Colors.black45)),
                  ],
                ),
                Column(children: [
                  widget.callType == "voice"
                      ? RawMaterialButton(
                          onPressed: _users.length >= 1 ? _onCallHold : null,
                          child: Icon(
                            hold ? Icons.pause : Icons.pause,
                            color: _users.length >= 1
                                ? hold
                                    ? Colors.white
                                    : Colors.blueAccent
                                : Colors.black12,
                            size: 20.0,
                          ),
                          shape: const CircleBorder(),
                          elevation: 2.0,
                          fillColor: _users.length >= 1
                              ? hold
                                  ? Colors.blueAccent
                                  : Colors.white
                              : Colors.white,
                          padding: const EdgeInsets.all(12.0),
                        )
                      : RawMaterialButton(
                          onPressed: () => _onOffCamera(userId),
                          child: Icon(
                            camera
                                ? Icons.camera_alt_outlined
                                : Icons.camera_alt,
                            color: camera ? Colors.white : Colors.blueAccent,
                            size: 20.0,
                          ),
                          shape: const CircleBorder(),
                          elevation: 2.0,
                          fillColor: camera ? Colors.blueAccent : Colors.white,
                          padding: const EdgeInsets.all(12.0),
                        ),
                  const SizedBox(height: 10),
                  _users.isEmpty
                      ? const Text("Hold",
                          style: TextStyle(color: Colors.black45))
                      : hold
                          ? const Text("Hold",
                              style: TextStyle(color: Colors.black45))
                          : const Text("Hold",
                              style: TextStyle(color: Colors.black45)),
                ]),
                Column(children: [
                  widget.callType == "voice"
                      ? RawMaterialButton(
                          onPressed: _onCallSpeaker,
                          child: Icon(
                            speaker ? Icons.volume_up : Icons.volume_up,
                            color: speaker ? Colors.white : Colors.blueAccent,
                            size: 20.0,
                          ),
                          shape: const CircleBorder(),
                          elevation: 2.0,
                          fillColor: speaker ? Colors.blueAccent : Colors.white,
                          padding: const EdgeInsets.all(12.0),
                        )
                      : RawMaterialButton(
                          onPressed: _onSwitchCamera,
                          child: const Icon(
                            Icons.switch_camera,
                            color: Colors.blueAccent,
                            size: 20.0,
                          ),
                          shape: const CircleBorder(),
                          elevation: 2.0,
                          fillColor: Colors.white,
                          padding: const EdgeInsets.all(12.0),
                        ),
                  const SizedBox(height: 10),
                  _users.isEmpty
                      ? const Text("Speaker",
                          style: TextStyle(color: Colors.black45))
                      : widget.callType == "voice"
                          ? const Text("Speaker",
                              style: TextStyle(color: Colors.black45))
                          : const Text("Switch",
                              style: TextStyle(color: Colors.black45)),
                ]),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () => _onCallEnd(context),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.redAccent,
                  padding: const EdgeInsets.all(15.0),
                ),
              ],
            ),
            !isLandscape ? const SizedBox(height: 50) : Container(),
          ],
        ),
      );
    } else {
      debugPrint("Else Part");
      return Column(
        children: [
          !isLandscape ? const SizedBox(height: 30) : Container(),
          widget.clientRole == ClientRole.Audience
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Live...  ',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Wrap(
                        children: [
                          RawMaterialButton(
                            onPressed: _onCallSpeaker,
                            child: Icon(
                              speaker ? Icons.volume_up : Icons.volume_up,
                              color: speaker ? Colors.white : Colors.blueAccent,
                              size: 20.0,
                            ),
                            shape: const CircleBorder(),
                            elevation: 2.0,
                            fillColor:
                                speaker ? Colors.blueAccent : Colors.white,
                            padding: const EdgeInsets.all(12.0),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.remove_red_eye,
                            color: Colors.black,
                            size: 30,
                          ),
                          const SizedBox(width: 5),
                          /*Text(
                            "$userCount",
                            style: const TextStyle(
                                fontSize: 25, color: Colors.white),
                          ),
                          const SizedBox(width: 5),*/
                        ],
                      )
                    ])
              : const SizedBox.shrink(),

          /*widget.callType == "voice"  ? const Icon(Icons.account_circle, size: 120) : widget.callType == "Audience" ? Container() : _users.isEmpty ? const Icon(Icons.account_circle, size: 120) : Container(),
          const SizedBox(height: 5),
          widget.callType == "voice" ? Text("${widget.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.white)) : _users.isEmpty ? Text("${widget.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.white)) : Container(),
          const SizedBox(height: 2),
          widget.callType == "voice"
              ? _users.length >= 1
              ? Container(child: callTimerStart(),
          )
              : const Text("00:00", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20))
              : Container(),
          Expanded(child: SizedBox(height: MediaQuery.of(context).size.height / 3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  RawMaterialButton(
                    onPressed: _onToggleMute,
                    child: Icon(
                      muted ? Icons.mic_off : Icons.mic,
                      color: muted
                          ? Colors.white : Colors.blueAccent,
                      size: 20.0),
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    fillColor: muted
                        ? Colors.blueAccent
                        : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),
                  const SizedBox(height: 10),
                  _users.isEmpty
                      ? const Text("Mute",
                      style: TextStyle(color: Colors.black45))
                      : muted
                      ? const Text("Muted",
                      style: TextStyle(color: Colors.black45))
                      : const Text("Mute",
                      style: TextStyle(color: Colors.black45)),
                ],
              ),
              Column(children: [
                RawMaterialButton(
                  onPressed: _users.length >= 1 ? _onCallHold : null,
                  child: Icon(
                    hold ? Icons.pause : Icons.pause,
                    color: _users.length >= 1 ? hold ? Colors.white : Colors.blueAccent : Colors.black12,
                    size: 20.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: _users.length >= 1 ? hold ? Colors.blueAccent : Colors.white : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
                const SizedBox(height: 10),
                _users.isEmpty
                    ? const Text("Hold",
                    style: TextStyle(color: Colors.black45))
                    : hold
                    ? const Text("Hold",
                    style: TextStyle(color: Colors.black45))
                    : const Text("Hold",
                    style: TextStyle(color: Colors.black45)),
              ]),
              Column(children: [
                RawMaterialButton(
                onPressed: _onCallSpeaker,
                child: Icon(
                  speaker ? Icons.volume_up : Icons.volume_up,
                  color: speaker ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: speaker ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
                const SizedBox(height: 10),
                _users.isEmpty
                    ? const Text("Speaker",
                    style: TextStyle(color: Colors.black45))
                    : speaker
                    ? const Text("Speaker",
                    style: TextStyle(color: Colors.black45))
                    : const Text("Speaker",
                    style: TextStyle(color: Colors.black45)),
              ]),
            ],
          ),*/
          SizedBox(height: height / 1.3),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () => _onCallLiveEnd(context),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      border: Border.all(width: 5, color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(children: [
                    const Text('Leave  ',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Image.asset(
                      AppImage.leave,
                      height: 25,
                      width: 30,
                      color: Colors.white,
                    )
                  ]),
                ),
                elevation: 2.0,
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _viewRows() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.black)),
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
      case 2:
        return Stack(
          // alignment: AlignmentDirectional.topEnd,
          children: <Widget>[
            SizedBox(
                child: _expandedVideoRow([views[1]]),
                height: height,
                width: width),
            Positioned(
              right: 10,
              top: 15,
              child: Container(
                  child: SizedBox(child: _expandedVideoRow([views[0]])),
                  height: height / 3.6,
                  width: width / 2.5,
                  // margin: const EdgeInsets.only(top: 2,bottom: 2,left: 2,right: 2),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                      borderRadius: const BorderRadius.all(Radius.circular(15)))
              ),
            )
          ],
        );
      /*case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: _expandedVideoRow(views.sublist(0, 1)),
              height: height / 1.5,
              width: width,
            ),
            Container(
                child: _expandedVideoRow(views.sublist(1, 3)),
                height: height / 3,
                // margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.black),
                    borderRadius: const BorderRadius.all(Radius.circular(10))))
          ],
        );*/
      default :
        if(widget.callType == "video") {
          return Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: _expandedVideoRow(views.sublist(0, 1)),/*_expandedVideoRow([views[0]]),*/
                    height: height / 1.5,
                    width: width, decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10)))

                  ),
                  Container(
                      height: height / 3,
                      width: width,
                      // padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10))),
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: views.length.clamp(2, views.length-1),
                          itemBuilder: (context, index) {
                            return Container(
                              child: _videoViewList(views[index+1]),
                              height: height / 3,
                              width: width / 2,
                              margin: const EdgeInsets.all(1),
                              // padding: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(width: 2, color: Colors.black),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)))
                            );
                          })),
                  // Container(child: _expandedVideoRowUser(views.sublist(1, 4)),
                  //     height: height/3,
                  //     width: width,
                  //     // margin: const EdgeInsets.only(top: 5),
                  //     padding: const EdgeInsets.all(5),
                  //     decoration: BoxDecoration(
                  //         border: Border.all(width: 2,color: Colors.black),
                  //         borderRadius: BorderRadius.all(const Radius.circular(10))
                  //     )
                  // )
                ],
              ));
        }
    }
    return Container();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    if (muted) {
      _engine.disableAudio();
    } else {
      _engine.enableAudio();
    }
  }

  void _onCallSpeaker() {
    setState(() {
      speaker = !speaker;
    });
    if (speaker) {
      _engine.setEnableSpeakerphone(true);
    } else {
      _engine.setEnableSpeakerphone(false);
    }
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onOffCamera([int? userId]) {
    setState(() {
      camera = !camera;
    });
    if (camera == true) {
      _engine.muteLocalVideoStream(true);
      // _engine.muteRemoteVideoStream(userId!, false);
      // _engine.disableVideo();
    }else{
      _engine.muteLocalVideoStream(false);
      // _engine.muteRemoteVideoStream(userId!, true);
      // _engine.enableVideo();
    }
  }

  void _onCallHold() {
    if (hold) {
      setState(() {
        hold = !hold;
        _engine.muteLocalAudioStream(hold);
      });
    } else {
      setState(() {
        hold = !hold;
        _engine.muteLocalAudioStream(hold);
      });
    }
  }

  void _onCallEnd(BuildContext context) {
    // Navigator.pop(context);
    _users.clear();
    _users.isNotEmpty ? _engine.leaveChannel() : null;
    _users.isNotEmpty ?_engine.destroy() : null;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  void _onCallLiveEnd(BuildContext context) {
    // Navigator.pop(context);
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  void _onReciverEnd(BuildContext context) {
    // Navigator.pop(context);
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  void _onNotReciverEnd(BuildContext context) {
    // Navigator.pop(context);
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}
