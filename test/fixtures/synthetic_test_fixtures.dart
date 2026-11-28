import 'package:enprive/services/platform/hybrid_ai_bridge.dart';

/// Test-only synthetic privacy policies and Android permission snapshots.
///
/// These fixtures are strictly for automated tests and are never bundled into
/// or exposed by the shipped application.
const String syntheticEduTrackPolicy = '''
EDUTRACK KIDS & CLASSROOM COMPANION — PRIVACY POLICY
Effective Date: November 1, 2026 | Snapshot Version: 2026.11-R2

1. OVERVIEW AND SCOPE
EduTrack Kids ("EduTrack", "we", "our") provides digital homework assignments, reading fluency recording, and classroom participation tools for students and families.

2. INFORMATION WE COLLECT AUTOMATICALLY
When a student uses EduTrack on a mobile device, we collect device identifiers, operating system telemetry, and session duration logs. In addition, our mobile application collects precise GPS location coordinates even when the application is running in the background to verify school bus zone attendance and regional classroom routing.

3. VOICE RECORDINGS AND BIOMETRIC FLUENCY DATA
For reading-aloud exercises, EduTrack records student voice audio through the device microphone. Student voice recordings and derived speech-fluency transcripts are retained indefinitely on our cloud servers to train and improve our automated speech recognition models unless a verified school administrator submits a written deletion ticket.

4. THIRD-PARTY ANALYTICS AND ADVERTISING PARTNERS
We partner with external analytics providers and third-party advertising networks. We may share persistent advertising identifiers and app usage events with third-party advertising partners to measure campaign performance and deliver contextual or behavioral promotions across partner educational services.

5. PARENTAL RIGHTS AND LIMITATIONS
Parents and legal guardians may request a summary of their child's classroom profile by contacting privacy@edutrack-example.org. Please note that revoking microphone or location permissions in Android Settings may disable core homework submission features.
''';

const String syntheticCalmMathPolicy = '''
CALMMATH ABACUS — PRIVACY & DATA HANDLING NOTICE
Effective Date: November 1, 2026 | Snapshot Version: 2026.11-LOCAL

1. LOCAL-ONLY COMPUTATION
CalmMath Abacus is designed for early elementary arithmetic practice. All math problem sets, practice scores, and learning progress are stored exclusively on this device inside local application storage.

2. NO THIRD-PARTY DATA SHARING OR ADVERTISING
We do not collect personal identifiers, precise location data, microphone audio, or camera input. We do not integrate third-party advertising SDKs, and we never sell, rent, or transmit student usage data to external analytics brokers.

3. PARENTAL & TEACHER CONTROLS
Parents and teachers can reset or permanently delete all local practice records at any time directly from the in-app Settings screen without creating an account or contacting support.
''';

const AppPermissionSnapshot syntheticEduTrackSnapshot = AppPermissionSnapshot(
  packageName: 'com.edutrack.classroom.demo',
  appName: 'EduTrack Classroom Companion',
  requestedPermissions: [
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_BACKGROUND_LOCATION',
    'android.permission.RECORD_AUDIO',
    'android.permission.CAMERA',
    'com.google.android.gms.permission.AD_ID',
    'android.permission.INTERNET',
  ],
  grantedPermissions: [
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.RECORD_AUDIO',
    'android.permission.CAMERA',
    'com.google.android.gms.permission.AD_ID',
    'android.permission.INTERNET',
  ],
);

const AppPermissionSnapshot syntheticCalmMathSnapshot = AppPermissionSnapshot(
  packageName: 'com.calmmath.abacus.demo',
  appName: 'CalmMath Abacus',
  requestedPermissions: ['android.permission.VIBRATE'],
  grantedPermissions: ['android.permission.VIBRATE'],
);
