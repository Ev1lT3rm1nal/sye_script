import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:image/image.dart' as im;
import 'dart:io' as io;

final mFiles = Glob("images/*.*");
final font =
    im.BitmapFont.fromZip(io.File("fonts/asman.zip").readAsBytesSync());

const size = 400;

List<im.Image?> images = List.filled(48, null);

void main(List<String> arguments) {
  var dir = io.Directory("out");
  if (!dir.existsSync()) {
    dir.createSync();
  }
  for (var file in mFiles.listSync()) {
    var image = im.decodeImage(io.File.fromUri(file.uri).readAsBytesSync());
    if (image != null) {
      var newImage = im.copyResizeCropSquare(image, size);
      newImage = im.copyCropCircle(newImage);
      final circleSize = 60;
      newImage = im.fillCircle(newImage, size ~/ 2, size - circleSize,
          circleSize ~/ 2, im.Color.fromRgb(240, 240, 240));
      var numberS = file.basename.split("_")[0];
      var height = im.findStringHeight(im.arial_48, numberS);
      im.drawStringCentered(
        newImage,
        font,
        numberS,
        y: size - circleSize - height ~/ 2,
        color: im.Color.fromRgb(0, 0, 0),
        //rightJustify: true,
      );
      im.drawCircle(
          newImage, size ~/ 2, size ~/ 2, size ~/ 2, im.Color.fromRgb(0, 0, 0));
      // io.File("out/${file.basename.split(".")[0]}.png")
      //     .writeAsBytesSync(im.encodePng(newImage));
      var number = int.tryParse(numberS);
      if (number != null) {
        images[number - 1] = newImage;
      }
    }
  }
  final columns = 8;
  final rows = 6;
  final width = columns * size;
  final height = rows * size;
  final game = im.Image(width, height);

  im.fill(game, im.Color.fromRgba(255, 255, 255, 255));

  for (var index = 0; index < images.length; index++) {
    final image = images[index];
    late int x;
    late int y;
    final imageYPos = (index ~/ columns);
    y = height - ((imageYPos + 1) * size);
    final isRight2left = imageYPos % 2 == 0;
    final imageXPos =
        isRight2left ? (index) % columns : ((columns - index - 1) % columns);
    x = width - ((imageXPos + 1) * size);
    im.drawImage(game, image!, dstX: x, dstY: y);
  }
  io.File("out/final.png").writeAsBytesSync(im.encodePng(game));
}
