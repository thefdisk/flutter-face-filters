import 'dart:io';

import 'package:face_filters/widgets/alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera_deep_ar/camera_deep_ar.dart';
import 'dart:io' as Platform;
// import 'package:avatar_view/avatar_view.dart';
import 'package:flutter/services.dart';
import '../widgets/error.dart';

DeepArConfig config = const DeepArConfig(
  androidKey:
      'bcb368f087477a1976db628eaf12aac81d8904829e0c60da55b30f1c8974326815d609511e2d0d22',
  ioskey: 'ioskey',
  displayMode: DisplayMode.camera,
);

class CameraMasksFilters extends StatefulWidget {
  const CameraMasksFilters({Key? key}) : super(key: key);

  @override
  _CameraMasksFiltersState createState() => _CameraMasksFiltersState();
}

class _CameraMasksFiltersState extends State<CameraMasksFilters> {
  final deepArController = CameraDeepArController(config);

  String _platformVersion = 'Unknown';
  bool isRecording = false;
  CameraMode cameraMode = config.cameraMode;
  DisplayMode displayMode = config.displayMode;
  int currentEffect = 0;

  List get effectList {
    switch (cameraMode) {
      case CameraMode.mask:
        return masks;
      case CameraMode.effect:
        return effects;
      case CameraMode.filter:
        return filters;
      default:
        return masks;
    }
  }

  List masks = [
    "none",
    "assets/aviators",
    "assets/bigmouth",
  ];

  List effects = [
    "none",
    "assets/fire",
    "assets/heart",
  ];

  List filters = [
    "none",
    "assets/drawingmanga",
    "assets/sepia",
  ];

  @override
  void initState() {
    super.initState();
    CameraDeepArController.checkPermissions();
    deepArController.setEventHandler(DeepArEventHandler(onCameraReady: (v) {
      _platformVersion = "onCameraReady $v";
      setState(() {});
    }, onSnapPhotoCompleted: (v) {
      _platformVersion = "onSnapPhotoCompleted $v";
      setState(() {});
    }, onVideoRecordingComplete: (v) {
      _platformVersion = "onVideoRecordingComplete $v";
      setState(() {});
    }, onSwitchEffect: (v) {
      _platformVersion = "onSwitchEffect $v";
      setState(() {});
    }));
  }

  @override
  void dispose() {
    deepArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('DeepAR Camera Example'),
        ),
        body: Stack(
          children: [
            DeepArPreview(deepArController),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(20),
                //height: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Response >>> : $_platformVersion\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (null == deepArController) return;
                                if (isRecording) return;
                                deepArController.snapPhoto();
                              },
                              child: Icon(Icons.camera_enhance_outlined),
                            ),
                          ),
                          if (displayMode == DisplayMode.image)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  String path = "assets/testImage.png";
                                  final file = await deepArController
                                      .createFileFromAsset(path, "test");

                                  // final file = await ImagePicker()
                                  //     .pickImage(source: ImageSource.gallery);
                                  await Future.delayed(Duration(seconds: 1));

                                  deepArController.changeImage(file.path);
                                  print("DAMON - Calling Change Image Flutter");
                                },
                                child: Icon(Icons.image),
                              ),
                            ),
                          if (isRecording)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (null == deepArController) return;
                                  deepArController.stopVideoRecording();
                                  isRecording = false;
                                  setState(() {});
                                },
                                child: Icon(Icons.videocam_off),
                              ),
                            )
                          else
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (null == deepArController) return;
                                  deepArController.startVideoRecording();
                                  isRecording = true;
                                  setState(() {});
                                },
                                child: Icon(Icons.videocam),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      padding: EdgeInsets.all(15),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(effectList.length, (p) {
                          bool active = currentEffect == p;
                          String imgPath = effectList[p];
                          return GestureDetector(
                            onTap: () async {
                              if (!deepArController.value.isInitialized) return;
                              currentEffect = p;
                              deepArController.switchEffect(
                                  cameraMode, imgPath);
                              setState(() {});
                            },
                            child: Container(
                              margin: EdgeInsets.all(6),
                              width: active ? 70 : 55,
                              height: active ? 70 : 55,
                              alignment: Alignment.center,
                              child: Text(
                                "$p",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: active ? FontWeight.bold : null,
                                    fontSize: active ? 16 : 14,
                                    color:
                                        active ? Colors.white : Colors.black),
                              ),
                              decoration: BoxDecoration(
                                  color: active ? Colors.orange : Colors.white,
                                  border: Border.all(
                                      color:
                                          active ? Colors.orange : Colors.white,
                                      width: active ? 2 : 0),
                                  shape: BoxShape.circle),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: List.generate(CameraMode.values.length, (p) {
                        CameraMode mode = CameraMode.values[p];
                        bool active = cameraMode == mode;

                        return Expanded(
                          child: Container(
                            height: 40,
                            margin: EdgeInsets.all(2),
                            child: TextButton(
                              onPressed: () async {
                                cameraMode = mode;
                                setState(() {});
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                                primary: Colors.black,
                                // shape: CircleBorder(
                                //     side: BorderSide(
                                //         color: Colors.white, width: 3))
                              ),
                              child: Text(
                                describeEnum(mode),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: active ? FontWeight.bold : null,
                                    fontSize: active ? 16 : 14,
                                    color: Colors.white
                                        .withOpacity(active ? 1 : 0.6)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: List.generate(DisplayMode.values.length, (p) {
                        DisplayMode mode = DisplayMode.values[p];
                        bool active = displayMode == mode;

                        return Expanded(
                          child: Container(
                            height: 40,
                            margin: EdgeInsets.all(2),
                            child: TextButton(
                              onPressed: () async {
                                displayMode = mode;
                                await deepArController.setDisplayMode(
                                    mode: mode);
                                setState(() {});
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.purple,
                                primary: Colors.black,
                                // shape: CircleBorder(
                                //     side: BorderSide(
                                //         color: Colors.white, width: 3))
                              ),
                              child: Text(
                                describeEnum(mode),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: active ? FontWeight.bold : null,
                                    fontSize: active ? 16 : 14,
                                    color: Colors.white
                                        .withOpacity(active ? 1 : 0.6)),
                              ),
                            ),
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // static Future<File> _loadFile(String path, String name) async {
  //   final ByteData data = await rootBundle.load(path);
  //   Directory tempDir = await getTemporaryDirectory();
  //   File tempFile = File('${tempDir.path}/$name');
  //   await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
  //   return tempFile;
  // }

  // // camera controller
  // late CameraDeepArController _cameraDeepArController;
  // String platformVersion = "Unknown";
  // String imagePath = "Unknown";
  // int currentPage = 0;
  // final vp = PageController(viewportFraction: 24);

  // // effects, filters and masks
  // Effects currentEffects = Effects.none;
  // Filters currentFilters = Filters.none;
  // Masks currentMasks = Masks.none;

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     home: Scaffold(
  //       backgroundColor: Colors.black,
  //       body: Stack(
  //         children: [
  //           // Deep AR Camera
  //           CameraDeepAr(
  //             androidLicenceKey:
  //                 'bcb368f087477a1976db628eaf12aac81d8904829e0c60da55b30f1c8974326815d609511e2d0d22',
  //             onCameraReady: (isReady) {
  //               platformVersion = "Camera status $isReady";
  //               // print(platformVersion);
  //               setState(() {});
  //             },
  //             onImageCaptured: (path) {
  //               imagePath = "Image saved at $path";
  //               showDialog(
  //                 context: context,
  //                 builder: (ctx) => AlertBoxWidget(path: imagePath),
  //               );
  //               // print(platformVersion);
  //               setState(() {});
  //             },
  //             cameraDeepArCallback: (c) async {
  //               _cameraDeepArController = c;
  //               setState(() {});
  //             },
  //             iosLicenceKey: '',
  //             onVideoRecorded: (String path) {},
  //           ),
  //           // Face Mask filters - IconButtons
  //           Align(
  //             alignment: Alignment.bottomCenter,
  //             child: Container(
  //               padding: const EdgeInsets.all(20),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.only(
  //                       left: 28,
  //                       right: 28,
  //                     ),
  //                     child: Expanded(
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(15.0),
  //                         child: CircleAvatar(
  //                           radius: 40,
  //                           backgroundColor: Colors.deepPurpleAccent,
  //                           child: IconButton(
  //                             splashColor: Colors.blueAccent,
  //                             iconSize: 50,
  //                             onPressed: () {
  //                               if (_cameraDeepArController == null) {
  //                                 return;
  //                               }
  //                               _cameraDeepArController.snapPhoto();
  //                             },
  //                             icon: const Icon(
  //                               Icons.camera_enhance,
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   SingleChildScrollView(
  //                     scrollDirection: Axis.horizontal,
  //                     child: Row(
  //                       children: List.generate(8, (page) {
  //                         bool active = currentPage == page;

  //                         return Platform.Platform.isIOS
  //                             // ios
  //                             ? GestureDetector(
  //                                 child: AvatarView(
  //                                   radius: active ? 65 : 30,
  //                                   borderColor: Colors.yellow,
  //                                   borderWidth: 2,
  //                                   isOnlyText: false,
  //                                   avatarType: AvatarType.CIRCLE,
  //                                   backgroundColor: Colors.red,
  //                                   imagePath:
  //                                       "assets/ios/${page.toString()}.jpg",
  //                                   placeHolder: const Icon(
  //                                     Icons.person,
  //                                     size: 50,
  //                                   ),
  //                                   errorWidget: const ErrorIcon(),
  //                                 ),
  //                                 onTap: () {
  //                                   currentPage = page;
  //                                   _cameraDeepArController.changeMask(page);
  //                                   setState(() {});
  //                                 },
  //                               )
  //                             // android
  //                             : GestureDetector(
  //                                 child: AvatarView(
  //                                   radius: active ? 45 : 25,
  //                                   borderColor: Colors.yellow,
  //                                   borderWidth: 2,
  //                                   isOnlyText: false,
  //                                   avatarType: AvatarType.CIRCLE,
  //                                   backgroundColor: Colors.red,
  //                                   imagePath:
  //                                       "assets/android/${page.toString()}.jpg",
  //                                   placeHolder: const Icon(
  //                                     Icons.person,
  //                                     size: 50,
  //                                   ),
  //                                   errorWidget: const ErrorIcon(),
  //                                 ),
  //                                 onTap: () {
  //                                   currentPage = page;
  //                                   _cameraDeepArController.changeMask(page);
  //                                   setState(() {});
  //                                 },
  //                               );
  //                       }),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
