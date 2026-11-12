import 'package:flutter_test/flutter_test.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_models.dart';

void main() {
  const sampleEduTrackPolicy = '''
When a student uses EduTrack on a mobile device, our mobile application collects precise GPS location coordinates even when the application is running in the background.
EduTrack records student voice audio through the device microphone.
We may share persistent advertising identifiers with third-party advertising partners.
''';

  const sampleCalmMathPolicy = '''
All math problem sets are stored exclusively on this device.
We do not collect personal identifiers, precise location data, microphone audio, or camera input.
We do not integrate third-party advertising SDKs.
''';

  group('PermissionComparator Deterministic Tests', () {
    test('detects undisclosed CAMERA mismatch and disclosed GPS/Mic on EduTrack', () {
      final report = PermissionComparator.compare(
        snapshot: PermissionComparator.demoEduTrackSnapshot,
        policyText: sampleEduTrackPolicy,
      );

      expect(report.mismatchCount, 1);
      final cameraItem = report.items.firstWhere(
        (i) => i.androidPermission == 'android.permission.CAMERA',
      );
      expect(
        cameraItem.alignmentState,
        PermissionAlignmentState.undisclosedInPolicy,
      );

      final gpsItem = report.items.firstWhere(
        (i) => i.androidPermission == 'android.permission.ACCESS_FINE_LOCATION',
      );
      expect(
        gpsItem.alignmentState,
        PermissionAlignmentState.grantedAndDisclosed,
      );

      final enriched = PermissionComparator.enrichFindingsWithDeviceReport(
        policyFindings: const [],
        report: report,
      );
      expect(enriched.length, 1);
      expect(enriched.first.status, EvidenceStatus.deviceObserved);
      expect(enriched.first.title, contains('Camera'));
    });

    test('reports zero sensitive permission mismatches on CalmMath', () {
      final report = PermissionComparator.compare(
        snapshot: PermissionComparator.demoCalmMathSnapshot,
        policyText: sampleCalmMathPolicy,
      );

      expect(report.mismatchCount, 0);
      expect(report.items, isEmpty);
      expect(
        report.limitationNotice,
        contains('It does not prove whether the app actually accessed'),
      );
    });
  });
}
