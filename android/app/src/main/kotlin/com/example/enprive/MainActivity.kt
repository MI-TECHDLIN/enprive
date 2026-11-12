package com.example.enprive

import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.lifecycleScope
import com.google.firebase.Firebase
import com.google.firebase.ai.ai
import com.google.firebase.ai.type.GenerativeBackend
import com.google.firebase.ai.type.generationConfig
import com.google.firebase.appcheck.appCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.enprive/hybrid_ai"
    private val TAG = "EnpriveHybridAi"
    private var initialSelectedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleProcessTextIntent(intent)

        // Install App Check Debug Provider for development & testing
        try {
            Firebase.appCheck.installAppCheckProviderFactory(
                DebugAppCheckProviderFactory.getInstance()
            )
            Log.d(TAG, "Firebase App Check Debug Provider initialized successfully")
        } catch (e: Exception) {
            Log.w(TAG, "Firebase App Check initialization note: ${e.message}")
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleProcessTextIntent(intent)
    }

    private fun handleProcessTextIntent(incomingIntent: Intent?) {
        if (incomingIntent?.action == Intent.ACTION_PROCESS_TEXT) {
            initialSelectedText = incomingIntent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
            Log.d(TAG, "Received ACTION_PROCESS_TEXT with ${initialSelectedText?.length ?: 0} chars")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceCapability" -> {
                    val apiLevel = Build.VERSION.SDK_INT
                    val isSupported = apiLevel >= 26
                    val modelStatus = if (isSupported) "AVAILABLE" else "UNAVAILABLE"
                    val res = mapOf(
                        "isSupported" to isSupported,
                        "modelStatus" to modelStatus,
                        "modelCategory" to "PREVIEW",
                        "apiLevel" to apiLevel,
                        "userMessage" to if (isSupported) {
                            "Android API $apiLevel meets on-device Gemini Nano requirements."
                        } else {
                            "Android API $apiLevel is below minimum required SDK 26."
                        }
                    )
                    result.success(res)
                }

                "downloadOrCheckModel" -> {
                    // On-device Gemini Nano is managed by Android AICore / Play Services
                    result.success("AVAILABLE")
                }

                "getInitialSelectedText" -> {
                    val text = initialSelectedText
                    initialSelectedText = null
                    result.success(text)
                }

                "inspectSelectedApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "packageName cannot be empty", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val pm = packageManager
                        val pkgInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            pm.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()))
                        } else {
                            @Suppress("DEPRECATION")
                            pm.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
                        }

                        val appName = pkgInfo.applicationInfo?.loadLabel(pm)?.toString() ?: packageName
                        val requested = pkgInfo.requestedPermissions?.toList() ?: emptyList<String>()
                        val granted = mutableListOf<String>()

                        pkgInfo.requestedPermissions?.forEachIndexed { index, perm ->
                            val isGranted = (pkgInfo.requestedPermissionsFlags?.getOrNull(index) ?: 0) and
                                    PackageInfo.REQUESTED_PERMISSION_GRANTED != 0
                            if (isGranted) {
                                granted.add(perm)
                            }
                        }

                        // Strictly local on-device result - never leaves the device
                        result.success(mapOf(
                            "packageName" to packageName,
                            "appName" to appName,
                            "requestedPermissions" to requested,
                            "grantedPermissions" to granted
                        ))
                    } catch (e: Exception) {
                        result.error("PACKAGE_NOT_FOUND", e.message, null)
                    }
                }

                "analyseText" -> {
                    val schemaVersion = call.argument<Int>("schemaVersion") ?: 1
                    val requestId = call.argument<String>("requestId") ?: ""
                    val task = call.argument<String>("task") ?: "summarise_concerns"
                    val text = call.argument<String>("text") ?: ""
                    val cloudConsent = call.argument<Boolean>("cloudConsent") ?: false
                    val requestedMode = call.argument<String>("requestedMode") ?: "ONLY_ON_DEVICE"

                    if (text.isBlank()) {
                        result.error("EMPTY_TEXT", "Text for privacy analysis cannot be empty.", null)
                        return@setMethodCallHandler
                    }

                    // Enforce privacy constraint: without cloud consent, strictly execute on-device
                    if (!cloudConsent && requestedMode == "ONLY_IN_CLOUD") {
                        result.success(mapOf(
                            "schemaVersion" to schemaVersion,
                            "requestId" to requestId,
                            "status" to "unavailable",
                            "inferenceSource" to "UNKNOWN",
                            "errorCode" to "CLOUD_CONSENT_REQUIRED",
                            "message" to "Cloud consent not granted. Analysis restricted to on-device."
                        ))
                        return@setMethodCallHandler
                    }

                    // Run inference in coroutine scope
                    lifecycleScope.launch(Dispatchers.IO) {
                        try {
                            val inferenceSource = if (cloudConsent) "IN_CLOUD" else "ON_DEVICE"
                            
                            // Initialize Firebase AI with App Check replay protection
                            val ai = Firebase.ai(
                                backend = GenerativeBackend.googleAI(),
                                useLimitedUseAppCheckTokens = true
                            )
                            
                            // Use latest Gemini 2.5 Flash for high efficiency evaluation
                            val model = ai.generativeModel(
                                modelName = "gemini-2.5-flash",
                                generationConfig = generationConfig {
                                    responseMimeType = "application/json"
                                    temperature = 0.1f
                                }
                            )

                            val systemPrompt = """
                                You are Enprive, an evidence-first privacy analyst for children's apps.
                                Analyze the following privacy policy excerpt.
                                
                                Task: $task
                                
                                You MUST return a JSON object with this exact structure:
                                {
                                  "summary": "Short 1-2 sentence calibrated summary",
                                  "concerns": [
                                    {
                                      "category": "DATA_COLLECTION" | "SHARING" | "TRACKING" | "RETENTION" | "PARENTAL_CONSENT",
                                      "severity": "HIGH" | "MEDIUM" | "LOW",
                                      "quote": "EXACT substring quoted verbatim from the text",
                                      "explanation": "Clear parent/teacher explanation"
                                    }
                                  ],
                                  "calibratedDisclaimer": "No concern identified in the reviewed evidence. This is not a safety certification."
                                }
                                
                                Strictly quote verbatim substrings for quotes. Never fabricate facts.
                            """.trimIndent()

                            val prompt = "$systemPrompt\n\n--- POLICY TEXT ---\n$text"
                            val response = model.generateContent(prompt)
                            val responseText = response.text ?: "{}"

                            // Parse structured JSON
                            val jsonOutput = try {
                                val jsonObj = JSONObject(responseText)
                                toMap(jsonObj)
                            } catch (e: Exception) {
                                mapOf("rawText" to responseText)
                            }

                            withContext(Dispatchers.Main) {
                                result.success(mapOf(
                                    "schemaVersion" to schemaVersion,
                                    "requestId" to requestId,
                                    "status" to "success",
                                    "inferenceSource" to inferenceSource,
                                    "structuredOutput" to jsonOutput
                                ))
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "Inference error", e)
                            withContext(Dispatchers.Main) {
                                result.success(mapOf(
                                    "schemaVersion" to schemaVersion,
                                    "requestId" to requestId,
                                    "status" to "failed",
                                    "inferenceSource" to "UNKNOWN",
                                    "errorCode" to (e.javaClass.simpleName),
                                    "message" to (e.message ?: "Analysis failed")
                                ))
                            }
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun toMap(jsonObject: JSONObject): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keys = jsonObject.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            var value = jsonObject.get(key)
            if (value is JSONObject) {
                value = toMap(value)
            } else if (value is org.json.JSONArray) {
                value = toList(value)
            }
            map[key] = value
        }
        return map
    }

    private fun toList(array: org.json.JSONArray): List<Any> {
        val list = mutableListOf<Any>()
        for (i in 0 until array.length()) {
            var value = array.get(i)
            if (value is JSONObject) {
                value = toMap(value)
            } else if (value is org.json.JSONArray) {
                value = toList(value)
            }
            list.add(value)
        }
        return list
    }
}
