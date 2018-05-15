// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class MyDiagram extends StatefulWidget {
  const MyDiagram({this.size: 1.0});

  final double size;

  @override
  _MyDiagramState createState() => new _MyDiagramState();
}

class _MyDiagramState extends State<MyDiagram> {
  @override
  Widget build(BuildContext context) {
    return new AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: widget.size,
      height: widget.size,
      decoration: const ShapeDecoration(
        shape: const BeveledRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        ),
        color: Color(0xfeedbeef),
      ),
    );
  }
}

Future<Null> main() async {
  final Directory directory = new Directory(
    path.join((await getApplicationDocumentsDirectory()).absolute.path, 'output'),
  );
  if (directory.existsSync()) {
    directory.deleteSync(recursive: true);
  }
  directory.createSync(recursive: true);
  final DiagramController controller = new DiagramController(
    builder: (BuildContext context) => const MyDiagram(),
    outputDirectory: directory,
    pixelRatio: 3.0,
    screenDimensions: const Size(100.0, 100.0),
  );

  // Start the implicit animation by changing the builder.
  controller.builder = (BuildContext context) => const MyDiagram(size: 50.0);

  // Capture some frames.
  await controller.drawAnimatedDiagramToFiles(
    end: const Duration(seconds: 1),
    frameRate: 10.0,
  );

  controller.builder = (BuildContext context) => const Text('Done');
  await controller.drawDiagramToFile(new File('done.png'));
}