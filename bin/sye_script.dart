import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:image/image.dart' as im;
import 'dart:io' as io;

final mFiles = Glob("images/*.*");

void main(List<String> arguments) {
  var dir = io.Directory("out");
  if (!dir.existsSync()) {
    dir.createSync();
  }
  for (var file in mFiles.listSync()) {
    var image = im.decodeImage(io.File.fromUri(file.uri).readAsBytesSync());
    if (image != null) {
      var newImage = im.copyResizeCropSquare(image, 200);
      newImage = im.copyCropCircle(newImage);
      newImage = im.fillCircle(
          newImage, 100, 180, 10, im.Color.fromRgb(240, 240, 240));
      var number = file.basename.split("_")[0];
      im.drawString(
        newImage,
        im.arial_14,
        100 - 7,
        180 - 7,
        number,
        color: im.Color.fromRgb(0, 0, 0),
        //rightJustify: true,
      );
      io.File("out/${file.basename.split(".")[0]}.png")
          .writeAsBytesSync(im.encodePng(newImage));
    }
  }
}
