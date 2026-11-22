import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceResultat {
  final int nombreVisages;
  final double? sourire; // 0.0 -> 1.0
  const FaceResultat(this.nombreVisages, this.sourire);

  bool get unSeulVisage => nombreVisages == 1;
  bool get sourit => (sourire ?? 0) > 0.7;
}

class FaceService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true, // sourire, yeux ouverts
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<FaceResultat> analyser(String cheminImage) async {
    final image = InputImage.fromFilePath(cheminImage);
    final visages = await _detector.processImage(image);
    final sourire = visages.isNotEmpty ? visages.first.smilingProbability : null;
    return FaceResultat(visages.length, sourire);
  }

  void dispose() => _detector.close();
}