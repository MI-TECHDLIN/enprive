import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/deni_animated_mascot.dart';
import '../../widgets/learn/diagrams/data_collection_diagram.dart';
import '../../widgets/learn/diagrams/evidence_categories_legend.dart';
import '../../widgets/learn/diagrams/evidence_layers_diagram.dart';
import '../../widgets/learn/diagrams/permissions_ladder_diagram.dart';
import '../../widgets/learn/diagrams/policy_fog_diagram.dart';
import '../../widgets/learn/diagrams/policy_limit_diagram.dart';
import '../../widgets/learn/diagrams/retention_timeline_diagram.dart';
import '../../widgets/learn/diagrams/safe_sharing_diagram.dart';
import '../../widgets/learn/diagrams/third_party_diagram.dart';

/// Filter categories on the Learn home screen.
enum LearnTopicCategory { all, policies, permissions, sharing, evidence }

/// Stable string identifiers for bundled Learn lessons.
///
/// Future topics (e.g. data collection, retention, children's privacy rights,
/// dark patterns, safe sharing, AI tutors) can simply add an entry to
/// [buildLearnLessons] without adding routes or modifying screen logic.
abstract final class LearnLessonIds {
  static const String privacyPolicy = 'privacy_policy';
  static const String androidPermissions = 'android_permissions';
  static const String thirdParties = 'third_parties';
  static const String evidence = 'evidence';
  static const String dataCollection = 'data_collection';
  static const String retention = 'retention';
  static const String unclearPolicies = 'unclear_policies';
  static const String safeSharing = 'safe_sharing';
}

/// Builder that produces the localized Flutter-drawn vector illustration for a
/// lesson.
typedef LearnDiagramBuilder =
    Widget Function(BuildContext context, AppLocalizations l10n);

/// Interactive one-question comprehension check at the end of a lesson.
@immutable
class LearnQuickCheck {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String correctFeedback;
  final String tryAgainFeedback;

  const LearnQuickCheck({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.correctFeedback,
    required this.tryAgainFeedback,
  });
}

/// Immutable data-driven domain model for an offline illustrated Learn lesson.
@immutable
class LearnLesson {
  final String id;
  final LearnTopicCategory category;
  final String folderTitle;
  final String title;
  final String subtitle;
  final String intro;
  final List<String> steps;
  final IconData icon;
  final DeniPose headerPose;
  final LearnDiagramBuilder diagramBuilder;
  final LearnQuickCheck quickCheck;

  const LearnLesson({
    required this.id,
    required this.category,
    required this.folderTitle,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.steps,
    required this.icon,
    required this.headerPose,
    required this.diagramBuilder,
    required this.quickCheck,
  });

  /// Short folder-card stat reflecting the exact number of steps in this lesson.
  String shortStat(AppLocalizations l10n) =>
      l10n.learnLessonStepCount(steps.length);

  /// Plain-language script spoken aloud by the on-device offline TTS engine.
  ///
  /// Reads the lesson's human prose (title, intro, steps, and quick-check
  /// question) without reading diagram code or revealing the answer upfront.
  String spokenText(AppLocalizations l10n) {
    return <String>[
      title,
      intro,
      ...steps,
      l10n.learnSectionQuickCheck,
      quickCheck.question,
    ].join(' ');
  }
}

/// Single content registry for all bundled offline illustrated lessons.
///
/// Adding future lessons (topics 2, 5, 6, 7, 9, 10) requires only appending
/// new [LearnLesson] content entries here — navigation, progress ("Lesson X
/// of N"), and Previous/Next links adapt automatically.
List<LearnLesson> buildLearnLessons(AppLocalizations l10n) {
  return [
    LearnLesson(
      id: LearnLessonIds.privacyPolicy,
      category: LearnTopicCategory.policies,
      folderTitle: l10n.learnPolicyFolderTitle,
      title: l10n.learnPolicyTitle,
      subtitle: l10n.learnPolicySubtitle,
      intro: l10n.learnPolicyIntro,
      steps: [
        l10n.learnPolicyStep1,
        l10n.learnPolicyStep2,
        l10n.learnPolicyStep3,
        l10n.learnPolicyStep4,
      ],
      icon: LucideIcons.fileText,
      headerPose: DeniPose.explaining,
      diagramBuilder: (context, l10n) => PolicyLimitDiagram(
        labels: PolicyLimitDiagramLabels(
          policySaysTitle: l10n.learnDiagramPolicySaysTitle,
          policySaysBody: l10n.learnDiagramPolicySaysBody,
          policyQuoteSample: l10n.learnDiagramPolicyQuoteSample,
          phoneShowsTitle: l10n.learnDiagramPhoneShowsTitle,
          phoneShowsBody: l10n.learnDiagramPhoneShowsBody,
          unknownTitle: l10n.learnDiagramUnknownTitle,
          unknownBody: l10n.learnDiagramUnknownBody,
          caption: l10n.learnDiagramPolicyCaption,
          semanticDescription: l10n.learnDiagramPolicySemantic,
        ),
      ),
      quickCheck: LearnQuickCheck(
        question: l10n.learnPolicyQuickQuestion,
        options: [
          l10n.learnPolicyQuickOption1,
          l10n.learnPolicyQuickOption2,
          l10n.learnPolicyQuickOption3,
        ],
        correctIndex: 1,
        correctFeedback: l10n.learnPolicyQuickCorrectFeedback,
        tryAgainFeedback: l10n.learnPolicyQuickTryAgainFeedback,
      ),
    ),
    LearnLesson(
      id: LearnLessonIds.androidPermissions,
      category: LearnTopicCategory.permissions,
      folderTitle: l10n.learnPermissionsFolderTitle,
      title: l10n.learnPermissionsTitle,
      subtitle: l10n.learnPermissionsSubtitle,
      intro: l10n.learnPermissionsIntro,
      steps: [
        l10n.learnPermissionsStep1,
        l10n.learnPermissionsStep2,
        l10n.learnPermissionsStep3,
        l10n.learnPermissionsStep4,
        l10n.learnPermissionsStep5,
      ],
      icon: LucideIcons.slidersHorizontal,
      headerPose: DeniPose.pointing,
      diagramBuilder: (context, l10n) => PermissionsLadderDiagram(
        labels: PermissionsLadderDiagramLabels(
          headerTitle: l10n.learnDiagramPermLadderTitle,
          denyTitle: l10n.learnDiagramPermDenyTitle,
          denyDetail: l10n.learnDiagramPermDenyDetail,
          askTitle: l10n.learnDiagramPermAskTitle,
          askDetail: l10n.learnDiagramPermAskDetail,
          whileUsingTitle: l10n.learnDiagramPermWhileUsingTitle,
          whileUsingDetail: l10n.learnDiagramPermWhileUsingDetail,
          allTimeTitle: l10n.learnDiagramPermAllTimeTitle,
          allTimeDetail: l10n.learnDiagramPermAllTimeDetail,
          featureFitNote: l10n.learnDiagramPermFitNote,
          semanticDescription: l10n.learnDiagramPermSemantic,
        ),
      ),
      quickCheck: LearnQuickCheck(
        question: l10n.learnPermissionsQuickQuestion,
        options: [
          l10n.learnPermissionsQuickOption1,
          l10n.learnPermissionsQuickOption2,
          l10n.learnPermissionsQuickOption3,
        ],
        correctIndex: 0,
        correctFeedback: l10n.learnPermissionsQuickCorrectFeedback,
        tryAgainFeedback: l10n.learnPermissionsQuickTryAgainFeedback,
      ),
    ),
    LearnLesson(
      id: LearnLessonIds.thirdParties,
      category: LearnTopicCategory.sharing,
      folderTitle: l10n.learnSharingFolderTitle,
      title: l10n.learnSharingTitle,
      subtitle: l10n.learnSharingSubtitle,
      intro: l10n.learnSharingIntro,
      steps: [
        l10n.learnSharingStep1,
        l10n.learnSharingStep2,
        l10n.learnSharingStep3,
        l10n.learnSharingStep4,
      ],
      icon: LucideIcons.share2,
      headerPose: DeniPose.thinking,
      diagramBuilder: (context, l10n) => ThirdPartyDiagram(
        labels: ThirdPartyDiagramLabels(
          app: l10n.learnDiagramThirdPartyApp,
          you: l10n.learnDiagramThirdPartyYou,
          hosting: l10n.learnDiagramThirdPartyHosting,
          analytics: l10n.learnDiagramThirdPartyAnalytics,
          ads: l10n.learnDiagramThirdPartyAds,
          firstParty: l10n.learnDiagramThirdPartyFirstParty,
          thirdParty: l10n.learnDiagramThirdPartyThirdParty,
          semanticDescription: l10n.learnDiagramThirdPartySemantic,
        ),
      ),
      quickCheck: LearnQuickCheck(
        question: l10n.learnSharingQuickQuestion,
        options: [
          l10n.learnSharingQuickOption1,
          l10n.learnSharingQuickOption2,
          l10n.learnSharingQuickOption3,
        ],
        correctIndex: 2,
        correctFeedback: l10n.learnSharingQuickCorrectFeedback,
        tryAgainFeedback: l10n.learnSharingQuickTryAgainFeedback,
      ),
    ),
    LearnLesson(
      id: LearnLessonIds.evidence,
      category: LearnTopicCategory.evidence,
      folderTitle: l10n.learnEvidenceFolderTitle,
      title: l10n.learnEvidenceTitle,
      subtitle: l10n.learnEvidenceSubtitle,
      intro: l10n.learnEvidenceIntro,
      steps: [
        l10n.learnEvidenceStep1,
        l10n.learnEvidenceStep2(l10n.statusSourceMatched),
        l10n.learnEvidenceStep3(l10n.statusDeviceObserved),
        l10n.learnEvidenceStep4(
          l10n.statusInterpretation,
          l10n.statusUnverified,
        ),
        l10n.learnEvidenceStep5(
          l10n.stateReviewRecommended,
          l10n.stateNoConcern,
          l10n.stateInsufficientEvidence,
        ),
      ],
      icon: LucideIcons.layers3,
      headerPose: DeniPose.raiseHand,
      diagramBuilder: (context, l10n) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          EvidenceLayersDiagram(
            labels: EvidenceLayersDiagramLabels(
              policySays: l10n.statusSourceMatched,
              phoneShows: l10n.statusDeviceObserved,
              deniExplains: l10n.statusInterpretation,
              notFound: l10n.statusUnverified,
              policySaysDetail: l10n.learnDiagramEvidencePolicyDetail,
              phoneShowsDetail: l10n.learnDiagramEvidencePhoneDetail,
              deniExplainsDetail: l10n.learnDiagramEvidenceDeniDetail,
              notFoundDetail: l10n.learnDiagramEvidenceUnknownDetail,
              semanticDescription: l10n.learnDiagramEvidenceSemantic(
                l10n.statusSourceMatched,
                l10n.statusDeviceObserved,
                l10n.statusInterpretation,
                l10n.statusUnverified,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const EvidenceCategoriesLegend(),
        ],
      ),
      quickCheck: LearnQuickCheck(
        question: l10n.learnEvidenceQuickQuestion(l10n.statusDeviceObserved),
        options: [
          l10n.learnEvidenceQuickOption1,
          l10n.learnEvidenceQuickOption2,
          l10n.learnEvidenceQuickOption3,
        ],
        correctIndex: 1,
        correctFeedback: l10n.learnEvidenceQuickCorrectFeedback,
        tryAgainFeedback: l10n.learnEvidenceQuickTryAgainFeedback,
      ),
    ),
    // Lesson 5: Topic 2 — What Data Apps Collect
    LearnLesson(
      id: LearnLessonIds.dataCollection,
      category: LearnTopicCategory.policies,
      folderTitle: l10n.learnDataCollectionFolderTitle,
      title: l10n.learnDataCollectionTitle,
      subtitle: l10n.learnDataCollectionSubtitle,
      intro: l10n.learnDataCollectionIntro1,
      steps: [
        l10n.learnDataCollectionStep1,
        l10n.learnDataCollectionStep2,
        l10n.learnDataCollectionStep3,
        l10n.learnDataCollectionStep4,
      ],
      icon: LucideIcons.database,
      headerPose: DeniPose.thinking,
      diagramBuilder: (context, l10n) => DataCollectionDiagram(
        labels: DataCollectionDiagramLabels(
          youTypeTitle: l10n.learnDataCollectionDiagramYouTypeTitle,
          youTypeItems: [
            l10n.learnDataCollectionDiagramYouTypeItem1,
            l10n.learnDataCollectionDiagramYouTypeItem2,
            l10n.learnDataCollectionDiagramYouTypeItem3,
            l10n.learnDataCollectionDiagramYouTypeItem4,
          ],
          runsQuietlyTitle: l10n.learnDataCollectionDiagramRunsQuietlyTitle,
          runsQuietlyItems: [
            l10n.learnDataCollectionDiagramRunsQuietlyItem1,
            l10n.learnDataCollectionDiagramRunsQuietlyItem2,
            l10n.learnDataCollectionDiagramRunsQuietlyItem3,
            l10n.learnDataCollectionDiagramRunsQuietlyItem4,
          ],
          quietNote: l10n.learnDataCollectionDiagramQuietNote,
          semanticDescription: l10n.learnDataCollectionDiagramSemanticDescription,
        ),
      ),
      quickCheck: LearnQuickCheck(
        question: l10n.learnDataCollectionQuizQuestion,
        options: [
          l10n.learnDataCollectionQuizChoiceA,
          l10n.learnDataCollectionQuizChoiceB,
          l10n.learnDataCollectionQuizChoiceC,
        ],
        correctIndex: 1,
        correctFeedback: l10n.learnDataCollectionQuizFeedbackRight,
        tryAgainFeedback: l10n.learnDataCollectionQuizFeedbackWrong,
      ),
    ),
    // Lesson 6: Topic 5 — Retention and Deletion
    LearnLesson(
      id: LearnLessonIds.retention,
      category: LearnTopicCategory.evidence,
      folderTitle: l10n.learnRetentionFolderTitle,
      title: l10n.learnRetentionTitle,
      subtitle: l10n.learnRetentionSubtitle,
      intro: l10n.learnRetentionIntro1,
      steps: [
        l10n.learnRetentionStep1,
        l10n.learnRetentionStep2,
        l10n.learnRetentionStep3,
        l10n.learnRetentionStep4,
        l10n.learnRetentionStep5,
      ],
      icon: LucideIcons.clock,
      headerPose: DeniPose.explaining,
      diagramBuilder: (context, l10n) => RetentionTimelineDiagram(
        labels: RetentionTimelineDiagramLabels(
          collected: l10n.learnRetentionDiagramCollected,
          stored: l10n.learnRetentionDiagramStored,
          uninstall: l10n.learnRetentionDiagramUninstall,
          deleteRequest: l10n.learnRetentionDiagramDeleteRequest,
          unknownTail: l10n.learnRetentionDiagramUnknownTail,
          semanticDescription: l10n.learnRetentionDiagramSemanticDescription,
        ),
      ),
      quickCheck: LearnQuickCheck(
        question: l10n.learnRetentionQuizQuestion,
        options: [
          l10n.learnRetentionQuizChoiceA,
          l10n.learnRetentionQuizChoiceB,
          l10n.learnRetentionQuizChoiceC,
        ],
        correctIndex: 1,
        correctFeedback: l10n.learnRetentionQuizFeedbackRight,
        tryAgainFeedback: l10n.learnRetentionQuizFeedbackWrong,
      ),
    ),
    // Lesson 7: Topic 7 — Spotting Unclear Policies & Dark Patterns
    LearnLesson(
      id: LearnLessonIds.unclearPolicies,
      category: LearnTopicCategory.policies,
      folderTitle: l10n.learnUnclearPoliciesFolderTitle,
      title: l10n.learnUnclearPoliciesTitle,
      subtitle: l10n.learnUnclearPoliciesSubtitle,
      intro: l10n.learnUnclearPoliciesIntro1,
      steps: [
        l10n.learnUnclearPoliciesStep1,
        l10n.learnUnclearPoliciesStep2,
        l10n.learnUnclearPoliciesStep3,
        l10n.learnUnclearPoliciesStep4,
        l10n.learnUnclearPoliciesStep5,
      ],
      icon: LucideIcons.alertCircle,
      headerPose: DeniPose.thinking,
      diagramBuilder: (context, l10n) => PolicyFogDiagram(
        labels: PolicyFogDiagramLabels(
          clearTitle: l10n.learnUnclearPoliciesDiagramClearTitle,
          clearExample: l10n.learnUnclearPoliciesDiagramClearExample,
          foggyTitle: l10n.learnUnclearPoliciesDiagramFoggyTitle,
          foggyExample: l10n.learnUnclearPoliciesDiagramFoggyExample,
          tipsTitle: l10n.learnUnclearPoliciesDiagramTipsTitle,
          tips: [
            l10n.learnUnclearPoliciesDiagramTip1,
            l10n.learnUnclearPoliciesDiagramTip2,
            l10n.learnUnclearPoliciesDiagramTip3,
          ],
          silenceNote: l10n.learnUnclearPoliciesDiagramSilenceNote,
          semanticDescription: l10n.learnUnclearPoliciesDiagramSemanticDescription,
        ),
      ),
      quickCheck: LearnQuickCheck(
        question: l10n.learnUnclearPoliciesQuizQuestion,
        options: [
          l10n.learnUnclearPoliciesQuizChoiceA,
          l10n.learnUnclearPoliciesQuizChoiceB,
          l10n.learnUnclearPoliciesQuizChoiceC,
        ],
        correctIndex: 1,
        correctFeedback: l10n.learnUnclearPoliciesQuizFeedbackRight,
        tryAgainFeedback: l10n.learnUnclearPoliciesQuizFeedbackWrong,
      ),
    ),
    // Lesson 8: Topic 9 — Safe-Sharing Habits for Kids
    LearnLesson(
      id: LearnLessonIds.safeSharing,
      category: LearnTopicCategory.sharing,
      folderTitle: l10n.learnSafeSharingFolderTitle,
      title: l10n.learnSafeSharingTitle,
      subtitle: l10n.learnSafeSharingSubtitle,
      intro: l10n.learnSafeSharingIntro1,
      steps: [
        l10n.learnSafeSharingStep1,
        l10n.learnSafeSharingStep2,
        l10n.learnSafeSharingStep3,
        l10n.learnSafeSharingStep4,
        l10n.learnSafeSharingStep5,
      ],
      icon: LucideIcons.shieldCheck,
      headerPose: DeniPose.raiseHand,
      diagramBuilder: (context, l10n) => SafeSharingDiagram(
        labels: SafeSharingDiagramLabels(
          stop: l10n.learnSafeSharingDiagramStop,
          think: l10n.learnSafeSharingDiagramThink,
          connect: l10n.learnSafeSharingDiagramConnect,
          cafeteriaTest: l10n.learnSafeSharingDiagramCafeteriaTest,
          semanticDescription: l10n.learnSafeSharingDiagramSemanticDescription,
        ),
      ),
      quickCheck: LearnQuickCheck(
        question: l10n.learnSafeSharingQuizQuestion,
        options: [
          l10n.learnSafeSharingQuizChoiceA,
          l10n.learnSafeSharingQuizChoiceB,
          l10n.learnSafeSharingQuizChoiceC,
        ],
        correctIndex: 1,
        correctFeedback: l10n.learnSafeSharingQuizFeedbackRight,
        tryAgainFeedback: l10n.learnSafeSharingQuizFeedbackWrong,
      ),
    ),
  ];
}
