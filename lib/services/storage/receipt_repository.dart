import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/review/review_models.dart';

/// Local-only SQLite repository for [PolicyReviewReceipt] records.
/// Privacy Guardrail: All receipts stay strictly on the user's phone inside
/// `enprive_receipts.db`. Automatically falls back to in-memory storage during
/// headless unit/widget tests where native SQLite channels are not mounted.
class ReceiptRepository {
  static const String _dbName = 'enprive_receipts.db';
  static const String _tableName = 'policy_receipts';
  static const int _dbVersion = 1;

  final bool useInMemoryOnly;
  Database? _db;
  bool _sqliteUnavailable = false;
  final Map<String, PolicyReviewReceipt> _memoryFallback = {};

  ReceiptRepository({this.useInMemoryOnly = false});

  Future<Database?> _getDatabase() async {
    if (useInMemoryOnly || _sqliteUnavailable) return null;
    if (_db != null) return _db;

    try {
      final dbDir = await getDatabasesPath();
      final dbPath = p.join(dbDir, _dbName);
      _db = await openDatabase(
        dbPath,
        version: _dbVersion,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id TEXT PRIMARY KEY,
              subject_title TEXT NOT NULL,
              source_label TEXT NOT NULL,
              snapshot_digest TEXT NOT NULL,
              overall_state TEXT NOT NULL,
              inference_source TEXT NOT NULL,
              created_at_ms INTEGER NOT NULL,
              payload_json TEXT NOT NULL
            )
          ''');
        },
      );
      return _db;
    } catch (_) {
      _sqliteUnavailable = true;
      return null;
    }
  }

  /// Loads all saved receipts ordered newest first (`created_at_ms DESC`).
  Future<List<PolicyReviewReceipt>> loadReceipts() async {
    final db = await _getDatabase();
    if (db == null) {
      final list = _memoryFallback.values.toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    try {
      final rows = await db.query(
        _tableName,
        orderBy: 'created_at_ms DESC',
      );
      final receipts = <PolicyReviewReceipt>[];
      for (final row in rows) {
        final payload = row['payload_json'] as String?;
        if (payload == null || payload.isEmpty) continue;
        try {
          final decoded = jsonDecode(payload) as Map<String, dynamic>;
          receipts.add(PolicyReviewReceipt.fromJson(decoded));
        } catch (_) {
          // Skip malformed historical rows safely
        }
      }
      return receipts;
    } catch (_) {
      final list = _memoryFallback.values.toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  /// Inserts or replaces a [PolicyReviewReceipt] in local storage.
  Future<void> saveReceipt(PolicyReviewReceipt receipt) async {
    _memoryFallback[receipt.id] = receipt;
    final db = await _getDatabase();
    if (db == null) return;

    try {
      await db.insert(
        _tableName,
        {
          'id': receipt.id,
          'subject_title': receipt.subjectTitle,
          'source_label': receipt.sourceLabel,
          'snapshot_digest': receipt.snapshotDigest,
          'overall_state': receipt.overallState.name,
          'inference_source': receipt.inferenceSource.name,
          'created_at_ms': receipt.createdAt.millisecondsSinceEpoch,
          'payload_json': jsonEncode(receipt.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Already stored in _memoryFallback
    }
  }

  /// Deletes a single receipt by [id].
  Future<void> deleteReceipt(String id) async {
    _memoryFallback.remove(id);
    final db = await _getDatabase();
    if (db == null) return;

    try {
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {
      // Removed from _memoryFallback
    }
  }

  /// Clears all locally stored receipts.
  Future<void> clearAllReceipts() async {
    _memoryFallback.clear();
    final db = await _getDatabase();
    if (db == null) return;

    try {
      await db.delete(_tableName);
    } catch (_) {
      // Cleared _memoryFallback
    }
  }
}

enum ExplanationDepth {
  simple,
  balanced,
  detailed,
}

class UserPreferencesSnapshot {
  final ExplanationDepth explanationDepth;
  final String languageCode;
  final bool hasCompletedOnboarding;

  const UserPreferencesSnapshot({
    this.explanationDepth = ExplanationDepth.balanced,
    this.languageCode = 'en',
    this.hasCompletedOnboarding = true,
  });

  UserPreferencesSnapshot copyWith({
    ExplanationDepth? explanationDepth,
    String? languageCode,
    bool? hasCompletedOnboarding,
  }) {
    return UserPreferencesSnapshot(
      explanationDepth: explanationDepth ?? this.explanationDepth,
      languageCode: languageCode ?? this.languageCode,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class UserPreferencesRepository {
  static const String _keyExplanationDepth = 'enprive_pref_explanation_depth';
  static const String _keyLanguageCode = 'enprive_pref_language_code';
  static const String _keyHasCompletedOnboarding =
      'enprive_pref_completed_onboarding';

  UserPreferencesSnapshot _cached = const UserPreferencesSnapshot();

  Future<UserPreferencesSnapshot> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final depthStr = prefs.getString(_keyExplanationDepth) ?? 'balanced';
      final lang = prefs.getString(_keyLanguageCode) ?? 'en';
      final completedOnboarding =
          prefs.getBool(_keyHasCompletedOnboarding) ?? false;
      _cached = UserPreferencesSnapshot(
        explanationDepth: ExplanationDepth.values.firstWhere(
          (d) => d.name == depthStr,
          orElse: () => ExplanationDepth.balanced,
        ),
        languageCode: lang,
        hasCompletedOnboarding: completedOnboarding,
      );
    } catch (_) {
      // Return in-memory cached snapshot if SharedPreferences is unavailable
    }
    return _cached;
  }

  Future<UserPreferencesSnapshot> update({
    ExplanationDepth? explanationDepth,
    String? languageCode,
    bool? hasCompletedOnboarding,
  }) async {
    _cached = _cached.copyWith(
      explanationDepth: explanationDepth,
      languageCode: languageCode,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      if (explanationDepth != null) {
        await prefs.setString(_keyExplanationDepth, explanationDepth.name);
      }
      if (languageCode != null) {
        await prefs.setString(_keyLanguageCode, languageCode);
      }
      if (hasCompletedOnboarding != null) {
        await prefs.setBool(
          _keyHasCompletedOnboarding,
          hasCompletedOnboarding,
        );
      }
    } catch (_) {
      // Keep updated _cached in memory
    }
    return _cached;
  }
}
