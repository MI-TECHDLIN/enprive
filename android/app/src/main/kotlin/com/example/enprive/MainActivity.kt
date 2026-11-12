package com.example.enprive

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.lifecycleScope
import com.google.firebase.Firebase
import com.google.firebase.ai.InferenceMode
import com.google.firebase.ai.InferenceSource
import com.google.firebase.ai.OnDeviceConfig
import com.google.firebase.ai.OnDeviceModelOption
import com.google.firebase.ai.OnDeviceModelStatus
import com.google.firebase.ai.ai
import com.google.firebase.ai.type.GenerativeBackend
import com.google.firebase.ai.type.PublicPreviewAPI
import com.google.firebase.ai.type.generationConfig
import com.google.firebase.appcheck.appCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject

@OptIn(PublicPreviewAPI::class)
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.enprive/hybrid_ai"
    private val TAG = "EnpriveHybridAi"
    private var initialSelectedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIncomingTextIntent(intent)

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
        setIntent(intent)
        handleIncomingTextIntent(intent)
    }

    private fun handleIncomingTextIntent(incomingIntent: Intent?) {
        when (incomingIntent?.action) {
            Intent.ACTION_PROCESS_TEXT -> {
                initialSelectedText = incomingIntent
                    .getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
                    ?.toString()
                Log.d(TAG, "Received ACTION_PROCESS_TEXT with ${initialSelectedText?.length ?: 0} chars")
            }
            Intent.ACTION_SEND -> {
                if (incomingIntent.type == "text/plain") {
                    initialSelectedText = incomingIntent.getStringExtra(Intent.EXTRA_TEXT)
                    Log.d(TAG, "Received ACTION_SEND with ${initialSelectedText?.length ?: 0} chars")
                }
            }
        }
    }

    private fun createOnDeviceModel() = Firebase.ai(
        backend = GenerativeBackend.googleAI(),
        useLimitedUseAppCheckTokens = true
    ).generativeModel(
        modelName = "gemini-3.8-flash",
        onDeviceConfig = OnDeviceConfig(
            mode = InferenceMode.ONLY_ON_DEVICE,
            maxOutputTokens = 1024,
            temperature = 0.1f,
            topK = 20,
            seed = null,
            candidateCount = 1,
            modelOption = OnDeviceModelOption.PREVIEW
        )
    )

    private fun mapModelStatus(status: OnDeviceModelStatus?): String {
        return when (status) {
            OnDeviceModelStatus.AVAILABLE -> "AVAILABLE"
            OnDeviceModelStatus.DOWNLOADABLE -> "DOWNLOADABLE"
            OnDeviceModelStatus.DOWNLOADING -> "DOWNLOADING"
            else -> "UNAVAILABLE"
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceCapability" -> {
                    val apiLevel = Build.VERSION.SDK_INT
                    if (apiLevel < 26) {
                        result.success(mapOf(
                            "isSupported" to false,
                            "modelStatus" to "UNAVAILABLE",
                            "modelCategory" to "PREVIEW",
                            "apiLevel" to apiLevel,
                            "userMessage" to "Android API $apiLevel is below minimum required SDK 26."
                        ))
                        return@setMethodCallHandler
                    }

                    lifecycleScope.launch(Dispatchers.IO) {
                        val mappedStatus = try {
                            val ext = createOnDeviceModel().onDeviceExtension
                            val status = ext?.checkStatus()
                            mapModelStatus(status)
                        } catch (e: Exception) {
                            Log.w(TAG, "On-device checkStatus fallback: ${e.message}")
                            "UNAVAILABLE"
                        }
                        val isSupported = mappedStatus == "AVAILABLE" ||
                                mappedStatus == "DOWNLOADABLE" ||
                                mappedStatus == "DOWNLOADING"

                        withContext(Dispatchers.Main) {
                            result.success(mapOf(
                                "isSupported" to isSupported,
                                "modelStatus" to mappedStatus,
                                "modelCategory" to "PREVIEW",
                                "apiLevel" to apiLevel,
                                "userMessage" to if (isSupported) {
                                    "Gemini Nano on-device status: $mappedStatus (API $apiLevel)."
                                } else {
                                    "Gemini Nano unavailable on this device ($mappedStatus). Consented cloud analysis available."
                                }
                            ))
                        }
                    }
                }

                "downloadOrCheckModel" -> {
                    lifecycleScope.launch(Dispatchers.IO) {
                        val finalStatus = try {
                            val ext = createOnDeviceModel().onDeviceExtension
                            val current = ext?.checkStatus()
                            if (current == OnDeviceModelStatus.DOWNLOADABLE) {
                                ext.download().collect()
                                mapModelStatus(ext.checkStatus())
                            } else {
                                mapModelStatus(current)
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "Model download/check failed: ${e.message}")
                            "FAILED"
                        }
                        withContext(Dispatchers.Main) {
                            result.success(finalStatus)
                        }
                    }
                }

                "warmUpModel" -> {
                    lifecycleScope.launch(Dispatchers.IO) {
                        val warmed = try {
                            val ext = createOnDeviceModel().onDeviceExtension
                            ext?.warmUp()
                            true
                        } catch (e: Exception) {
                            Log.w(TAG, "Model warmUp note: ${e.message}")
                            false
                        }
                        withContext(Dispatchers.Main) {
                            result.success(warmed)
                        }
                    }
                }

                "getInitialSelectedText" -> {
                    val text = initialSelectedText
                    initialSelectedText = null
                    result.success(text)
                }

                "listLaunchableApps" -> {
                    lifecycleScope.launch(Dispatchers.IO) {
                        val apps = try {
                            val pm = packageManager
                            val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
                                addCategory(Intent.CATEGORY_LAUNCHER)
                            }
                            val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                pm.queryIntentActivities(
                                    mainIntent,
                                    PackageManager.ResolveInfoFlags.of(0L)
                                )
                            } else {
                                @Suppress("DEPRECATION")
                                pm.queryIntentActivities(mainIntent, 0)
                            }

                            val seen = mutableSetOf<String>()
                            resolveInfos.mapNotNull { info ->
                                val pkg = info.activityInfo?.packageName ?: return@mapNotNull null
                                if (pkg == applicationContext.packageName || !seen.add(pkg)) {
                                    return@mapNotNull null
                                }
                                val appInfo = info.activityInfo?.applicationInfo
                                val label = info.loadLabel(pm).toString().takeIf { it.isNotBlank() }
                                    ?: appInfo?.loadLabel(pm)?.toString()
                                    ?: pkg
                                val isSystem = ((appInfo?.flags ?: 0) and ApplicationInfo.FLAG_SYSTEM) != 0
                                mapOf(
                                    "packageName" to pkg,
                                    "appName" to label,
                                    "isSystemApp" to isSystem
                                )
                            }.sortedWith(
                                compareBy<Map<String, Any>> { it["isSystemApp"] as Boolean }
                                    .thenBy { (it["appName"] as String).lowercase() }
                            )
                        } catch (e: Exception) {
                            Log.w(TAG, "listLaunchableApps error: ${e.message}")
                            emptyList<Map<String, Any>>()
                        }

                        withContext(Dispatchers.Main) {
                            result.success(apps)
                        }
                    }
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

                    // Enforce privacy constraint: without cloud consent, strictly block ONLY_IN_CLOUD requests
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

                    lifecycleScope.launch(Dispatchers.IO) {
                        try {
                            val inferenceMode = when {
                                !cloudConsent -> InferenceMode.ONLY_ON_DEVICE
                                requestedMode == "ONLY_IN_CLOUD" -> InferenceMode.ONLY_IN_CLOUD
                                else -> InferenceMode.PREFER_ON_DEVICE
                            }

                            val ai = Firebase.ai(
                                backend = GenerativeBackend.googleAI(),
                                useLimitedUseAppCheckTokens = true
                            )

                            val model = ai.generativeModel(
                                modelName = "gemini-3.8-flash",
                                generationConfig = generationConfig {
                                    responseMimeType = "application/json"
                                    temperature = 0.1f
                                },
                                onDeviceConfig = OnDeviceConfig(
                                    mode = inferenceMode,
                                    maxOutputTokens = 1024,
                                    temperature = 0.1f,
                                    topK = 20,
                                    seed = null,
                                    candidateCount = 1,
                                    modelOption = OnDeviceModelOption.PREVIEW
                                )
                            )

                            val systemPrompt = if (task == "explain_finding") {
                                """
                                You are Deni, Enprive's calm, evidence-first privacy guide for parents and teachers.
                                Explain the cited privacy finding in plain, reassuring, non-alarmist language.

                                You MUST return a JSON object with this exact structure:
                                {
                                  "answer": "2-3 sentence plain-language explanation directly answering the user's question based only on the quote",
                                  "whatPolicySays": "1 sentence restating the verbatim policy claim",
                                  "unknownBoundary": "1 sentence clearly stating what this excerpt does NOT prove or specify"
                                }
                                Never certify an app as safe. Never invent facts outside the provided excerpt.
                                """.trimIndent()
                            } else {
                                """
                                You are Enprive, an evidence-first privacy analyst for children's apps.
                                Analyze the following privacy policy excerpt.
                                
                                Task: $task
                                
                                You MUST return a JSON object with this exact structure:
                                {
                                  "overall_state": "REVIEW_RECOMMENDED" | "NO_CONCERN" | "INSUFFICIENT_EVIDENCE",
                                  "summary": "Short 1-2 sentence calibrated summary",
                                  "concerns": [
                                    {
                                      "id": "finding_1",
                                      "title": "Short descriptive finding title",
                                      "category": "DATA_COLLECTION" | "SHARING" | "TRACKING" | "RETENTION" | "PARENTAL_CONSENT",
                                      "severity": "HIGH" | "MEDIUM" | "LOW",
                                      "quote": "EXACT substring quoted verbatim from the text",
                                      "explanation": "Clear parent/teacher explanation of why this clause matters",
                                      "unknowns": ["What the policy text leaves unspecified"]
                                    }
                                  ],
                                  "calibratedDisclaimer": "No concern identified in the reviewed evidence. This is not a safety certification."
                                }
                                
                                Strictly quote verbatim substrings for quotes. Never fabricate facts.
                                """.trimIndent()
                            }

                            val prompt = "$systemPrompt\n\n--- POLICY TEXT ---\n$text"
                            val response = model.generateContent(prompt)
                            val responseText = response.text ?: "{}"

                            val actualSource = when (response.inferenceSource) {
                                InferenceSource.ON_DEVICE -> "ON_DEVICE"
                                InferenceSource.IN_CLOUD -> "IN_CLOUD"
                                else -> if (cloudConsent) "IN_CLOUD" else "ON_DEVICE"
                            }

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
                                    "inferenceSource" to actualSource,
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
