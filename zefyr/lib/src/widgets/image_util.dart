import 'dart:io';
import 'package:image/image.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_luban/flutter_luban.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtil {
  static final uploadPath =
      'http://www.zhuzuovip.com/test/api/v1/upload?type=post';

  static String uploadToken = '';
  static void setToken(String token) {
    uploadToken = token;
  }

  /// 上传图片，成功后返回图片地址
  static Future<String> upLoadImage(String path) async {
    if (path.startsWith('file://')) {
      path = path.replaceFirst('file://', '');
    }
    FormData formData =
        FormData.fromMap({"file": await MultipartFile.fromFile(path)});
    Dio dio = Dio();
    dio.options.headers = {'Authorization': 'Bearer $uploadToken'};

    String imageUrl =
        await dio.post<String>(uploadPath, data: formData).then((response) {
      var data = jsonDecode(response.data);
      if (data['success']) {
        return data['data']['image_src'];
      } else {
        throw Exception('接口返回：success:false');
      }
    }).catchError((error) {
      print('上传失败：$error');
      throw error;
    }).whenComplete(() {
      // 图片上传后删除本地temp图片
      ImageUtil.removeImage(path);
    });

    print('接口返回的图片地址：$imageUrl');

    return imageUrl;
  }

  /// 图片压缩（使用Luban算法）
  static Future<String> compressImage(String path) async {
    /* CompressObject compressObject = CompressObject(
         imageFile:imageFile, //image
         path:tempDir.path, //compress to path
         quality: 85,//first compress quality, default 80
         step: 9,//compress quality step, The bigger the fast, Smaller is more accurate, default 6
         mode: CompressMode.LARGE2SMALL,//default AUTO
       ); */
    if (path.startsWith('file://')) {
      path = path.replaceFirst('file://', '');
    }
    File imageFile = File(path);
    print('imageFile: $path');

    String appDir = (await getApplicationDocumentsDirectory()).path;
    String tempPath = appDir + '/temp';
    Directory dir = Directory(tempPath);
    if (!await dir.exists()) {
      // 如果目录不存在，就创建
      await dir.create(recursive: true);
    }

    //tempPath = '/storage/emulated/0/DCIM';
    print('tempPath: $tempPath');

    CompressObject compressObject = CompressObject(
        imageFile: imageFile, //image
        path: tempPath, //compress to path
        step: 9);

    print('file: $path: before size:${imageFile.lengthSync() ~/ 1024} kb');

    int start = DateTime.now().millisecondsSinceEpoch;
    String tempFilePath = await Luban.compressImage(compressObject);
    int end = DateTime.now().millisecondsSinceEpoch;

    print(
        'after compress: $path, size: ${File(tempFilePath).lengthSync() ~/ 1024} kb');
    print('耗时：${(end - start)}豪秒');

    return tempFilePath;
  }

  /// resize 发现没有压缩效果好
  static Future<void> resizeImage(File imageFile, String tempPath) async {
    // Read a jpeg image from file.
    Image image = decodeImage(imageFile.readAsBytesSync());
    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    Image thumbnail = copyResize(image, width: 600);
    // Save the thumbnail as a Jpg.
    await File(tempPath).writeAsBytesSync(encodeJpg(thumbnail, quality: 80));
    return tempPath;
  }

  /// 删除刚才上传的图片
  static Future<void> removeImage(String path) async {
    File file = File(path);
    if (file.existsSync()) {
      print('删除临时文件:$path');
      file.deleteSync();
    }
  }
}
