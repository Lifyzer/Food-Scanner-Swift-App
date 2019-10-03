# 2018-11-20 -- v0.13.0
- Face contour detection will only return contours for the most prominent face.
- The face tracking feature is disabled for contour-only detection in `.fast` mode.

# 2018-10-09 -- v0.12.0
- Added support for face contour detection.
- Added synchronous face detection API `resultsInImage:error:`.
- (breaking change) Renamed the asynchronous face detection API from `detectInImage:completion:` to `processImage:completion:`.
- (breaking change) Renamed some properties and enums in `VisionFaceDetectorOptions`.
- (breaking change) Removed the constant `VisionFaceDetectionMinSize` in `VisionFaceDetectorOptions`.

# 2018-07-31 -- v0.11.0
- (breaking change) Unified and enhanced on-device and cloud text recognition
  API.
- (breaking change) Enhanced cloud document scanning API.
