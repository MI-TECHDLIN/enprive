package com.example.enprive

import android.app.Activity
import android.app.KeyguardManager
import android.app.StatusBarManager
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.speech.tts.TextToSpeech
import android.util.Log
import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean
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
import com.google.firebase.ai.type.TextPart
import com.google.firebase.ai.type.ThinkingLevel
import com.google.firebase.ai.type.generationConfig
import com.google.firebase.ai.type.thinkingConfig
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ConcurrentHashMap
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject

@OptIn(PublicPreviewAPI::class)
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.enprive/hybrid_ai"
    private val TAG = "EnpriveHybridAi"
    private val PICK_DOCUMENT_REQUEST_CODE = 4091
    private var initialSelectedText: String? = null
    private var initialIncomingPayload: Map<String, Any?>? = null
    private var initialCompanionInvocation: CompanionContract.CompanionInvocation? = null
    private val companionInvocationTracker = CompanionContract.InvocationTracker()
    private var pendingDocumentResult: MethodChannel.Result? = null
    private var tts: TextToSpeech? = null
    private var isTtsReady: Boolean = false
    private var methodChannel: MethodChannel? = null
    private var companionChannel: MethodChannel? = null
    private val activeAnalysisJobs = ConcurrentHashMap<String, Job>()
    private val userCancelledRequestIds = ConcurrentHashMap.newKeySet<String>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIncomingTextIntent(intent, dispatchIfAttached = false)

        try {
            PDFBoxResourceLoader.init(applicationContext)
        } catch (e: Exception) {
            Log.w(TAG, "PDFBox resource init fallback (${e.javaClass.simpleName})")
        }

        // Initialize local Android TextToSpeech for Enprive Voice (English & Korean)
        try {
            tts = TextToSpeech(applicationContext) { status ->
                if (status == TextToSpeech.SUCCESS) {
                    isTtsReady = true
                    tts?.language = Locale.US
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "TextToSpeech init note (${e.javaClass.simpleName})")
        }
    }

    override fun onDestroy() {
        try {
            tts?.stop()
            tts?.shutdown()
            tts = null
            isTtsReady = false
        } catch (_: Exception) {}
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIncomingTextIntent(intent, dispatchIfAttached = true)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_DOCUMENT_REQUEST_CODE) return

        val callback = pendingDocumentResult
        pendingDocumentResult = null
        if (callback == null) return

        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            callback.success(
                mapOf(
                    "status" to "cancelled",
                    "documentType" to null,
                    "fileName" to null,
                    "mimeType" to null,
                    "byteLength" to 0,
                    "extractedText" to "",
                    "userMessage" to "Document selection cancelled.",
                )
            )
            return
        }

        lifecycleScope.launch(Dispatchers.IO) {
            val extracted = DocumentUriExtractor.extract(contentResolver, uri, declaredMime = data.type)
            withContext(Dispatchers.Main) {
                callback.success(extracted)
            }
        }
    }

    private fun handleIncomingTextIntent(
        incomingIntent: Intent?,
        dispatchIfAttached: Boolean,
    ) {
        if (incomingIntent?.action == CompanionContract.ACTION_OPEN_COMPANION) {
            val invocation = CompanionContract.parseCompanionInvocation(
                intent = incomingIntent,
                isDeviceLocked = isDeviceLockedNow(),
            ) ?: return
            if (!companionInvocationTracker.consumeIfUnprocessed(invocation.invocationId)) {
                return
            }
            val activeCompanionChannel = companionChannel
            if (dispatchIfAttached && activeCompanionChannel != null) {
                initialCompanionInvocation = null
                activeCompanionChannel.invokeMethod("onCompanionInvocation", invocation.toMap())
            } else {
                initialCompanionInvocation = invocation
            }
            Log.d(TAG, "Received OPEN_COMPANION invocation (source=${invocation.source})")
            return
        }

        when (incomingIntent?.action) {
            Intent.ACTION_PROCESS_TEXT -> {
                val text = incomingIntent
                    .getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
                    ?.toString()
                initialSelectedText = text
                if (!text.isNullOrBlank()) {
                    initialIncomingPayload = mapOf(
                        "kind" to "text",
                        "sourceAction" to "ACTION_PROCESS_TEXT",
                        "text" to text,
                    )
                }
                Log.d(TAG, "Received ACTION_PROCESS_TEXT with ${text?.length ?: 0} chars")
            }
            Intent.ACTION_SEND -> {
                when (val route = IncomingShareRouter.fromSendIntent(incomingIntent, contentResolver)) {
                    is SendShareRoute.TextOrUrl -> {
                        initialSelectedText = route.text
                        initialIncomingPayload = mapOf(
                            "kind" to "text_or_url",
                            "sourceAction" to "ACTION_SEND",
                            "text" to route.text,
                            "subject" to route.subject,
                        )
                        Log.d(TAG, "Received ACTION_SEND text payload (${route.text.length} chars)")
                    }
                    is SendShareRoute.DocumentUri -> {
                        initialSelectedText = null
                        initialIncomingPayload = mapOf(
                            "kind" to "document_uri",
                            "sourceAction" to "ACTION_SEND",
                            "uriString" to route.uriString,
                            "mimeType" to route.declaredMimeType,
                            "fileName" to route.fileName,
                        )
                        Log.d(
                            TAG,
                            "Received ACTION_SEND stream URI (mime=${route.declaredMimeType ?: "unknown"})",
                        )
                    }
                    is SendShareRoute.Rejected -> {
                        initialSelectedText = null
                        initialIncomingPayload = mapOf(
                            "kind" to "document",
                            "sourceAction" to "ACTION_SEND",
                            "status" to route.reasonCode,
                            "extractedText" to "",
                            "userMessage" to route.userMessage,
                        )
                        Log.d(TAG, "Rejected empty or malformed ACTION_SEND payload (${route.reasonCode})")
                    }
                }
            }
        }

        val activeChannel = methodChannel
        val payloadToPush = initialIncomingPayload
        if (dispatchIfAttached && activeChannel != null && payloadToPush != null) {
            initialIncomingPayload = null
            initialSelectedText = null
            lifecycleScope.launch(Dispatchers.IO) {
                val resolved = resolveIncomingPayloadMap(payloadToPush)
                withContext(Dispatchers.Main) {
                    activeChannel.invokeMethod("onIncomingPayload", resolved)
                }
            }
        }
    }

    private fun resolveIncomingPayloadMap(rawPayload: Map<String, Any?>): Map<String, Any?> {
        if (rawPayload["kind"] != "document_uri") {
            return rawPayload
        }
        val uriStr = rawPayload["uriString"] as? String ?: ""
        val declaredMime = rawPayload["mimeType"] as? String
        val uri = Uri.parse(uriStr)
        if (uri.scheme?.lowercase() != "content") {
            return mapOf(
                "kind" to "document",
                "sourceAction" to (rawPayload["sourceAction"] ?: "ACTION_SEND"),
                "status" to "permission_denied",
                "extractedText" to "",
                "userMessage" to "Only Android content:// document URIs can be inspected safely.",
            )
        }
        val docMap = DocumentUriExtractor.extract(contentResolver, uri, declaredMime = declaredMime)
        return mapOf(
            "kind" to "document",
            "sourceAction" to (rawPayload["sourceAction"] ?: "ACTION_SEND"),
            *docMap.entries.map { it.key to it.value }.toTypedArray(),
        )
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

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel = channel
        channel.setMethodCallHandler { call, result ->
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
                            Log.w(TAG, "On-device checkStatus fallback (${e.javaClass.simpleName})")
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
                            Log.w(TAG, "Model download/check failed (${e.javaClass.simpleName})")
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
                            Log.w(TAG, "Model warmUp note (${e.javaClass.simpleName})")
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

                "getInitialIncomingPayload" -> {
                    val pending = initialIncomingPayload
                    initialIncomingPayload = null
                    initialSelectedText = null
                    if (pending == null) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    lifecycleScope.launch(Dispatchers.IO) {
                        val resolved = resolveIncomingPayloadMap(pending)
                        withContext(Dispatchers.Main) {
                            result.success(resolved)
                        }
                    }
                }

                "pickAndExtractDocument" -> {
                    if (pendingDocumentResult != null) {
                        result.error(
                            "PICK_IN_PROGRESS",
                            "A document picker session is already active.",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    try {
                        pendingDocumentResult = result
                        val openIntent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "*/*"
                            putExtra(
                                Intent.EXTRA_MIME_TYPES,
                                DocumentTextExtractor.SUPPORTED_PICKER_MIMES,
                            )
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        startActivityForResult(openIntent, PICK_DOCUMENT_REQUEST_CODE)
                    } catch (e: Exception) {
                        pendingDocumentResult = null
                        Log.w(TAG, "Document picker launch failed (${e.javaClass.simpleName})")
                        result.success(
                            mapOf(
                                "status" to "read_error",
                                "documentType" to null,
                                "fileName" to null,
                                "mimeType" to null,
                                "byteLength" to 0,
                                "extractedText" to "",
                                "userMessage" to "Could not open Android's system document picker on this device.",
                            )
                        )
                    }
                }

                "speakText" -> {
                    val text = call.argument<String>("text") ?: ""
                    val languageCode = call.argument<String>("languageCode") ?: "en"
                    if (text.isBlank() || !isTtsReady || tts == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    try {
                        val targetLocale = resolveBcp47Locale(languageCode)
                        tts?.language = targetLocale
                        val speakRes = tts?.speak(
                            text,
                            TextToSpeech.QUEUE_FLUSH,
                            null,
                            "enprive_utterance_${System.currentTimeMillis()}"
                        )
                        result.success(speakRes == TextToSpeech.SUCCESS)
                    } catch (e: Exception) {
                        Log.w(TAG, "speakText error (${e.javaClass.simpleName})")
                        result.success(false)
                    }
                }

                "stopSpeaking" -> {
                    try {
                        tts?.stop()
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }

                "listLaunchableApps" -> {
                    lifecycleScope.launch(Dispatchers.IO) {
                        val apps = try {
                            AppPackageInspector.listLaunchableApps(applicationContext)
                        } catch (e: Exception) {
                            Log.w(TAG, "listLaunchableApps error (${e.javaClass.simpleName})")
                            emptyList()
                        }

                        withContext(Dispatchers.Main) {
                            result.success(apps)
                        }
                    }
                }

                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "packageName cannot be empty", null)
                        return@setMethodCallHandler
                    }
                    val requestedSize = call.argument<Int>("sizePx") ?: 112
                    val targetSize = requestedSize.coerceIn(32, 192)
                    lifecycleScope.launch(Dispatchers.IO) {
                        val iconBytes = AppPackageInspector.loadAppIconPngBytes(
                            applicationContext,
                            packageName,
                            targetSize,
                        )
                        withContext(Dispatchers.Main) {
                            result.success(iconBytes)
                        }
                    }
                }

                "inspectSelectedApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "packageName cannot be empty", null)
                        return@setMethodCallHandler
                    }

                    val snapshotMap = try {
                        AppPackageInspector.inspectRawPermissionSnapshot(packageManager, packageName)
                    } catch (_: Exception) {
                        null
                    }
                    if (snapshotMap == null) {
                        result.error(
                            "PACKAGE_NOT_FOUND",
                            "Selected application package could not be inspected.",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    // Strictly local on-device result - never leaves the device
                    result.success(snapshotMap)
                }

                "analyseText" -> {
                    val schemaVersion = call.argument<Int>("schemaVersion") ?: 1
                    val requestId = call.argument<String>("requestId") ?: ""
                    val task = call.argument<String>("task") ?: "summarise_concerns"
                    val text = call.argument<String>("text") ?: ""
                    val cloudConsent = call.argument<Boolean>("cloudConsent") ?: false
                    val requestedMode = call.argument<String>("requestedMode") ?: "ONLY_ON_DEVICE"
                    val languageCode = call.argument<String>("languageCode") ?: "en"
                    val targetLanguage = languageDisplayName(languageCode)

                    if (text.isBlank()) {
                        result.error("EMPTY_TEXT", "Text for privacy analysis cannot be empty.", null)
                        return@setMethodCallHandler
                    }

                    // Enforce privacy constraint: without cloud consent, strictly block non-ONLY_ON_DEVICE requests
                    if (!HybridAiPolicy.isRequestPermitted(cloudConsent, requestedMode)) {
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

                    val jobKey = requestId.ifBlank { "op_${System.nanoTime()}" }
                    if (userCancelledRequestIds.remove(jobKey)) {
                        result.error(
                            "CANCELLED",
                            "Analysis cancelled by user.",
                            mapOf("reason" to "user_cancelled"),
                        )
                        return@setMethodCallHandler
                    }

                    lifecycleScope.launch(Dispatchers.IO) {
                        var replySubmitted = false
                        val selfJob = kotlin.coroutines.coroutineContext[Job]
                        if (selfJob != null) {
                            activeAnalysisJobs[jobKey] = selfJob
                        }
                        try {
                            if (userCancelledRequestIds.remove(jobKey)) {
                                throw HybridAiPolicy.UserAnalysisCancelledException()
                            }
                            HybridAiPolicy.executeSingleOperation(
                                onRun = {
                                val inferenceMode =
                                    HybridAiPolicy.resolveInferenceMode(cloudConsent, requestedMode)
                                val modelName = "gemini-3.8-flash"

                                val ai = Firebase.ai(
                                    backend = GenerativeBackend.googleAI(),
                                    useLimitedUseAppCheckTokens = true
                                )

                                fun createModel(includeThoughts: Boolean) = run {
                                    val config = generationConfig {
                                        responseMimeType = "application/json"
                                        temperature = 0.1f
                                        if (includeThoughts) {
                                            thinkingConfig = thinkingConfig {
                                                this.includeThoughts = true
                                                thinkingLevel = HybridAiPolicy.CLOUD_THINKING_LEVEL
                                            }
                                        }
                                    }
                                if (HybridAiPolicy.shouldAttachOnDeviceConfig(inferenceMode)) {
                                    ai.generativeModel(
                                        modelName = modelName,
                                        generationConfig = config,
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
                                } else {
                                    ai.generativeModel(
                                        modelName = modelName,
                                        generationConfig = config
                                    )
                                }
                            }

                            val systemPrompt = if (task == "explain_finding") {
                                """
                                You are Deni, Enprive's calm, evidence-first privacy guide for parents and teachers.
                                Explain the cited privacy finding in plain, reassuring, non-alarmist language.
                                Output language: Write "answer", "whatPolicySays", and "unknownBoundary" naturally in $targetLanguage. Keep any verbatim quote in the policy text's original language.

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
                                Output language: Write "summary", "title", "explanation", "unknowns", and "calibratedDisclaimer" naturally in $targetLanguage. Keep JSON keys, enum values ("REVIEW_RECOMMENDED", "NO_CONCERN", "INSUFFICIENT_EVIDENCE", "DATA_COLLECTION", "SHARING", "TRACKING", "RETENTION", "PARENTAL_CONSENT", "HIGH", "MEDIUM", "LOW"), and "quote" EXACTLY as specified.
                                
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
                                      "quote": "EXACT substring quoted verbatim from the policy text in its original language",
                                      "explanation": "Clear parent/teacher explanation of why this clause matters",
                                      "unknowns": ["What the policy text leaves unspecified"]
                                    }
                                  ],
                                  "calibratedDisclaimer": "No concern identified in the reviewed evidence. This is not a safety certification."
                                }
                                
                                Strictly quote verbatim substrings from the provided policy text for "quote". Never translate or alter "quote". Never fabricate facts.
                                """.trimIndent()
                            }

                            val prompt = "$systemPrompt\n\n--- POLICY TEXT ---\n$text"
                            val thoughtBuilder = StringBuilder()
                            val answerBuilder = StringBuilder()
                            val signatures = mutableListOf<String>()
                            var lastInferenceSource: InferenceSource? = null

                            suspend fun pushStreamEvent(
                                stage: String,
                                label: String,
                                detail: String? = null,
                                sourceStr: String? = null
                            ) {
                                withContext(Dispatchers.Main) {
                                    methodChannel?.invokeMethod(
                                        "onAnalysisStreamEvent",
                                        mapOf(
                                            "requestId" to requestId,
                                            "stage" to stage,
                                            "label" to label,
                                            "detail" to detail,
                                            "thoughtSummary" to thoughtBuilder.toString().trim().ifEmpty { null },
                                            "thoughtSignature" to signatures.lastOrNull(),
                                            "inferenceSource" to sourceStr,
                                            "isCompleted" to false
                                        )
                                    )
                                }
                            }

                            suspend fun collectStream(enableThoughts: Boolean) {
                                pushStreamEvent(
                                    stage = "model_stream_started",
                                    label = HybridAiPolicy.initialStreamLabel(inferenceMode),
                                    sourceStr = HybridAiPolicy.initialStreamSource(inferenceMode)
                                )
                                val firstTimeoutMs = if (inferenceMode == InferenceMode.ONLY_IN_CLOUD) {
                                    HybridAiPolicy.CLOUD_FIRST_RESPONSE_TIMEOUT_MS
                                } else {
                                    HybridAiPolicy.ON_DEVICE_FIRST_RESPONSE_TIMEOUT_MS
                                }
                                val totalTimeoutMs = if (inferenceMode == InferenceMode.ONLY_IN_CLOUD) {
                                    HybridAiPolicy.CLOUD_TOTAL_TIMEOUT_MS
                                } else {
                                    HybridAiPolicy.ON_DEVICE_TOTAL_TIMEOUT_MS
                                }
                                HybridAiPolicy.collectWithTimeoutBudgets(
                                    flow = createModel(enableThoughts).generateContentStream(prompt),
                                    firstResponseTimeoutMs = firstTimeoutMs,
                                    totalTimeoutMs = totalTimeoutMs,
                                ) { chunk ->
                                    lastInferenceSource = chunk.inferenceSource
                                    val srcLabel = HybridAiPolicy.mapInferenceSource(lastInferenceSource)
                                    var chunkAddedThought = false
                                    var chunkAddedSignature = false

                                    for (candidate in chunk.candidates) {
                                        for (part in candidate.content.parts) {
                                            if (part is TextPart) {
                                                val sig = part.thoughtSignature?.trim()
                                                if (!sig.isNullOrEmpty() && !signatures.contains(sig)) {
                                                    signatures.add(sig)
                                                    chunkAddedSignature = true
                                                }
                                                if (part.isThought) {
                                                    thoughtBuilder.append(part.text)
                                                    chunkAddedThought = true
                                                } else {
                                                    answerBuilder.append(part.text)
                                                }
                                            }
                                        }
                                    }

                                    if (!chunkAddedThought) {
                                        val fallbackSummary = chunk.thoughtSummary
                                        if (!fallbackSummary.isNullOrEmpty()) {
                                            thoughtBuilder.append(fallbackSummary)
                                            chunkAddedThought = true
                                        }
                                    }

                                    if (chunkAddedThought || chunkAddedSignature) {
                                        pushStreamEvent(
                                            stage = if (chunkAddedSignature && !chunkAddedThought) {
                                                "thought_signature_received"
                                            } else {
                                                "streaming_thoughts"
                                            },
                                            label = when (srcLabel) {
                                                "IN_CLOUD" -> "Streaming reasoning & thought signature"
                                                "ON_DEVICE" -> "Streaming reasoning on this phone"
                                                else -> "Streaming model reasoning"
                                            },
                                            sourceStr = srcLabel
                                        )
                                    }
                                }
                            }

                            // Execute strictly once via shared policy guard; never retry pre-output failures.
                            HybridAiPolicy.executeSingleGenerationAttempt(
                                cloudConsent = cloudConsent,
                                requestedMode = requestedMode,
                                modelName = modelName,
                                thinkingLevel = HybridAiPolicy.CLOUD_THINKING_LEVEL,
                                onBlocked = { reason -> throw SecurityException(reason) },
                                onAttempt = { _, enableThoughts ->
                                    collectStream(enableThoughts)
                                }
                            )

                            val responseText = answerBuilder.toString().trim().ifEmpty { "{}" }
                            val actualSource = HybridAiPolicy.mapInferenceSource(lastInferenceSource)
                            val finalThoughtSummary = thoughtBuilder.toString().trim().ifEmpty { null }
                            val finalSignature = signatures.lastOrNull()

                            pushStreamEvent(
                                stage = "structured_output_received",
                                label = "Structured response received — validating quotes",
                                sourceStr = actualSource
                            )

                            val jsonOutput = try {
                                val cleaned = responseText
                                    .removePrefix("```json")
                                    .removePrefix("```")
                                    .removeSuffix("```")
                                    .trim()
                                val jsonObj = JSONObject(cleaned)
                                toMap(jsonObj)
                            } catch (e: Exception) {
                                mapOf("rawText" to responseText)
                            }

                            withContext(Dispatchers.Main) {
                                replySubmitted = true
                                result.success(mapOf(
                                    "schemaVersion" to schemaVersion,
                                    "requestId" to requestId,
                                    "status" to "success",
                                    "inferenceSource" to actualSource,
                                    "structuredOutput" to jsonOutput,
                                    "thoughtSummary" to finalThoughtSummary,
                                    "thoughtSignature" to finalSignature,
                                    "thoughtSignatures" to signatures.toList()
                                ))
                            }
                        },
                        onCancel = { ce ->
                                val wasUserCancelled =
                                    userCancelledRequestIds.remove(jobKey) ||
                                        ce is HybridAiPolicy.UserAnalysisCancelledException ||
                                        ce.cause is HybridAiPolicy.UserAnalysisCancelledException
                                val isTimeout =
                                    !wasUserCancelled &&
                                        (ce is TimeoutCancellationException ||
                                            ce is HybridAiPolicy.AnalysisTimeoutCancellationException ||
                                            ce.cause is TimeoutCancellationException ||
                                            ce.cause is HybridAiPolicy.AnalysisTimeoutCancellationException)
                                if (!replySubmitted) {
                                    withContext(NonCancellable + Dispatchers.Main) {
                                        replySubmitted = true
                                        try {
                                            result.error(
                                                if (isTimeout) "TIMED_OUT" else "CANCELLED",
                                                if (isTimeout) {
                                                    "Cloud AI timed out before completing."
                                                } else {
                                                    "Analysis cancelled."
                                                },
                                                mapOf("reason" to if (isTimeout) "timeout" else "user_cancelled"),
                                            )
                                        } catch (_: Exception) {
                                            // Flutter engine may already be detached on cancellation.
                                        }
                                    }
                                }
                            },
                            onFailure = { info, _ ->
                                if (info.isUnavailable) {
                                    Log.i(TAG, "On-device model unavailable on this hardware/emulator; prompting user choice.")
                                } else {
                                    Log.w(TAG, "Inference note (code=${info.errorCode}, status=${info.status})")
                                }
                                withContext(Dispatchers.Main) {
                                    replySubmitted = true
                                    result.success(mapOf(
                                        "schemaVersion" to schemaVersion,
                                        "requestId" to requestId,
                                        "status" to info.status,
                                        "inferenceSource" to "UNKNOWN",
                                        "errorCode" to info.errorCode,
                                        "message" to info.message
                                    ))
                                }
                            }
                        )
                        } finally {
                            if (selfJob != null) {
                                activeAnalysisJobs.remove(jobKey, selfJob)
                            }
                            userCancelledRequestIds.remove(jobKey)
                        }
                    }
                }

                "cancelAnalysis" -> {
                    val requestedId = call.argument<String>("requestId")?.trim()
                    var cancelledAny = false
                    if (!requestedId.isNullOrEmpty()) {
                        val candidateIds = listOf(requestedId, "${requestedId}_appcheck")
                        for (cid in candidateIds) {
                            userCancelledRequestIds.add(cid)
                            activeAnalysisJobs[cid]?.let { activeJob ->
                                activeJob.cancel(HybridAiPolicy.UserAnalysisCancelledException())
                                cancelledAny = true
                            }
                        }
                    } else {
                        for ((id, activeJob) in activeAnalysisJobs.entries) {
                            userCancelledRequestIds.add(id)
                            activeJob.cancel(HybridAiPolicy.UserAnalysisCancelledException())
                            cancelledAny = true
                        }
                    }
                    result.success(cancelledAny)
                }

                else -> result.notImplemented()
            }
        }

        val companionCh = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CompanionContract.CHANNEL)
        companionChannel = companionCh
        companionCh.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialCompanionInvocation" -> {
                    val pending = initialCompanionInvocation
                    initialCompanionInvocation = null
                    result.success(pending?.toMap())
                }

                "checkUsageAccess" -> {
                    val status = ForegroundAppResolver.checkUsageAccess(applicationContext)
                    result.success(
                        mapOf(
                            "schemaVersion" to 1,
                            "status" to status.wireValue,
                            "deviceLocked" to isDeviceLockedNow(),
                        ),
                    )
                }

                "openUsageAccessSettings" -> {
                    val launched = openUsageAccessSettingsScreen()
                    result.success(launched)
                }

                "resolveForegroundApp" -> {
                    if (isDeviceLockedNow()) {
                        result.success(
                            mapOf(
                                "schemaVersion" to 1,
                                "resolutionStatus" to "deviceLocked",
                                "packageName" to null,
                                "applicationLabel" to null,
                                "eventTimestamp" to null,
                                "eventAgeMillis" to null,
                                "confidence" to "none",
                                "fallbackReason" to "Unlock your device before viewing app context.",
                                "candidates" to emptyList<Map<String, Any?>>(),
                                "permissionMetadataAvailable" to false,
                            ),
                        )
                        return@setMethodCallHandler
                    }
                    val endTimeMs = call.argument<Number>("invocationTimestampMs")?.toLong()
                        ?: System.currentTimeMillis()
                    val windowMs = call.argument<Number>("windowMs")?.toLong()
                        ?: ForegroundAppResolver.DEFAULT_CANDIDATE_WINDOW_MS
                    lifecycleScope.launch(Dispatchers.IO) {
                        val resolution = ForegroundAppResolver.resolveCurrentForegroundApp(
                            context = applicationContext,
                            queryEndTimeMs = endTimeMs,
                            windowMs = windowMs,
                        )
                        withContext(Dispatchers.Main) {
                            result.success(resolution.toMap())
                        }
                    }
                }

                "getDeclaredSensitivePermissions" -> {
                    if (isDeviceLockedNow()) {
                        result.success(
                            mapOf(
                                "schemaVersion" to 1,
                                "status" to "device_locked",
                                "packageName" to "",
                                "permissions" to emptyList<Map<String, Any?>>(),
                                "errorMessage" to "Unlock your device to view declared permissions.",
                            ),
                        )
                        return@setMethodCallHandler
                    }
                    val packageName = call.argument<String>("packageName") ?: ""
                    lifecycleScope.launch(Dispatchers.IO) {
                        val inspected = AppPackageInspector.inspectDeclaredSensitivePermissions(
                            packageManager = packageManager,
                            packageName = packageName,
                        )
                        withContext(Dispatchers.Main) {
                            result.success(inspected.toMap())
                        }
                    }
                }

                "getQuickSettingsTileStatus" -> {
                    val tileState = QuickSettingsTileStateStore.read(applicationContext)
                    result.success(
                        mapOf(
                            "schemaVersion" to 1,
                            "canRequestDirectAdd" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU),
                            "isTileAdded" to tileState.isTileAdded,
                            "hasDeclinedBefore" to tileState.hasDeclinedBefore,
                            "apiLevel" to Build.VERSION.SDK_INT,
                        ),
                    )
                }

                "requestQuickSettingsTile" -> {
                    requestQuickSettingsTileInstallation(result)
                }

                "openPlayStoreListing" -> {
                    val requestedPkg = call.argument<String>("packageName")
                    val navResult = openPlayStoreListingOnDevice(requestedPkg)
                    result.success(navResult.toMap())
                }

                "openAppSystemSettings" -> {
                    val requestedPkg = call.argument<String>("packageName")
                    val navResult = openAppSystemSettingsOnDevice(requestedPkg)
                    result.success(navResult.toMap())
                }

                "returnToPreviousApp" -> {
                    val moved = try {
                        moveTaskToBack(true)
                    } catch (_: Throwable) {
                        false
                    }
                    result.success(moved)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun isDeviceLockedNow(): Boolean {
        return try {
            val km = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            km?.isKeyguardLocked == true
        } catch (_: Throwable) {
            false
        }
    }

    private fun openUsageAccessSettingsScreen(): Boolean {
        val packageSpecificIntent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            data = Uri.fromParts("package", packageName, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return try {
            startActivity(packageSpecificIntent)
            true
        } catch (_: ActivityNotFoundException) {
            try {
                val genericIntent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(genericIntent)
                true
            } catch (_: Throwable) {
                false
            }
        } catch (_: Throwable) {
            false
        }
    }

    private fun openPlayStoreListingOnDevice(
        packageName: String?,
    ): CompanionContract.ExternalNavigationResult {
        return CompanionContract.executeOpenPlayStoreListing(
            packageName = packageName,
            launcher = ::launchExternalSpec,
        )
    }

    private fun openAppSystemSettingsOnDevice(
        packageName: String?,
    ): CompanionContract.ExternalNavigationResult {
        return CompanionContract.executeOpenAppSystemSettings(
            packageName = packageName,
            launcher = ::launchExternalSpec,
        )
    }

    private fun launchExternalSpec(
        spec: CompanionContract.ExternalLaunchSpec,
    ): CompanionContract.ExternalLaunchOutcome {
        val intent = Intent(spec.action, Uri.parse(spec.uriString)).apply {
            addFlags(spec.flags)
        }
        return try {
            startActivity(intent)
            CompanionContract.ExternalLaunchOutcome.LAUNCHED
        } catch (_: ActivityNotFoundException) {
            CompanionContract.ExternalLaunchOutcome.ACTIVITY_NOT_FOUND
        } catch (_: Throwable) {
            CompanionContract.ExternalLaunchOutcome.FAILED
        }
    }

    private fun requestQuickSettingsTileInstallation(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(
                mapOf(
                    "outcome" to "manual_required",
                    "apiLevel" to Build.VERSION.SDK_INT,
                ),
            )
            return
        }
        val sbm = getSystemService(Context.STATUS_BAR_SERVICE) as? StatusBarManager
        if (sbm == null) {
            result.success(
                mapOf(
                    "outcome" to "unavailable",
                    "apiLevel" to Build.VERSION.SDK_INT,
                ),
            )
            return
        }

        val replied = AtomicBoolean(false)
        try {
            sbm.requestAddTileService(
                ComponentName(this, EnpriveCheckTileService::class.java),
                getString(R.string.qs_tile_label),
                Icon.createWithResource(this, R.drawable.ic_qs_enprive_check),
                mainExecutor,
            ) { code ->
                if (!replied.compareAndSet(false, true)) return@requestAddTileService
                val outcome = CompanionContract.mapTileAddRequestResult(code)
                when (outcome) {
                    "tile_added", "already_added" -> QuickSettingsTileStateStore.markTileAdded(applicationContext)
                    "declined" -> QuickSettingsTileStateStore.markTileDeclined(applicationContext)
                }
                result.success(
                    mapOf(
                        "outcome" to outcome,
                        "apiLevel" to Build.VERSION.SDK_INT,
                    ),
                )
            }
        } catch (e: Throwable) {
            Log.w(TAG, "requestAddTileService failed (${e.javaClass.simpleName})")
            if (replied.compareAndSet(false, true)) {
                result.success(
                    mapOf(
                        "outcome" to "failed",
                        "apiLevel" to Build.VERSION.SDK_INT,
                    ),
                )
            }
        }
    }

    private fun resolveBcp47Locale(languageCode: String): Locale {
        val base = languageCode.lowercase().split('-', '_').firstOrNull() ?: "en"
        val tag = when (base) {
            "ko" -> "ko-KR"
            "es" -> "es-ES"
            "fr" -> "fr-FR"
            "de" -> "de-DE"
            "ar" -> "ar-SA"
            "ja" -> "ja-JP"
            "zh" -> "zh-CN"
            "hi" -> "hi-IN"
            "pt" -> "pt-BR"
            "it" -> "it-IT"
            "ru" -> "ru-RU"
            else -> "en-US"
        }
        return Locale.forLanguageTag(tag)
    }

    private fun languageDisplayName(languageCode: String): String {
        val base = languageCode.lowercase().split('-', '_').firstOrNull() ?: "en"
        return when (base) {
            "ko" -> "Korean"
            "es" -> "Spanish"
            "fr" -> "French"
            "de" -> "German"
            "ar" -> "Arabic"
            "ja" -> "Japanese"
            "zh" -> "Simplified Chinese"
            "hi" -> "Hindi"
            "pt" -> "Portuguese"
            "it" -> "Italian"
            "ru" -> "Russian"
            else -> "English"
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
