import 'package:flutter/material.dart';

class ImgConf {
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ImgConf({
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });
}

Widget img({required String url, ImgConf conf = const ImgConf()}) {
  final Widget child = url.startsWith('http')
      ? Image.network(
          url,
          width: conf.width,
          height: conf.height,
          fit: conf.fit,
        )
      : Image.asset(url, width: conf.width, height: conf.height, fit: conf.fit);

  if (conf.borderRadius == null) {
    return child;
  }
  return ClipRRect(borderRadius: conf.borderRadius!, child: child);
}
