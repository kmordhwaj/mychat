import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class PhotoPlay extends StatelessWidget {
  final String photofile;
  const PhotoPlay({Key? key, required this.photofile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PinchZoom(
        maxScale: 5,
        resetDuration: const  Duration(milliseconds: 100),
        child: Container(
          color: Colors.black,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.93,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(photofile),
                      fit: BoxFit.cover)),
            ),
          ),
        ),
      ),
    );
  }
}
