package com.example.enprive

import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserException
import org.xml.sax.Attributes
import org.xml.sax.InputSource
import org.xml.sax.SAXException
import org.xml.sax.ext.DefaultHandler2
import java.io.IOException
import java.io.InputStream
import java.io.Reader
import javax.xml.parsers.SAXParserFactory

/**
 * The unit-test android.jar only stubs org.xmlpull, so these host parsers let
 * `DocumentTextExtractor.readDocxText` run against real token streams on the
 * JVM. Only the members the extractor touches are implemented.
 */
abstract class HostXmlPullParser : XmlPullParser {
    val features = mutableMapOf<String, Boolean>()
    protected var currentEvent = XmlPullParser.START_DOCUMENT
    protected var currentName: String? = null
    protected var currentText: String? = null

    override fun setFeature(name: String, state: Boolean) {
        features[name] = state
    }

    override fun getFeature(name: String): Boolean = features[name] ?: false
    override fun getEventType(): Int = currentEvent
    override fun getName(): String? = currentName
    override fun getText(): String? = currentText

    override fun setProperty(name: String?, value: Any?) = unsupported()
    override fun getProperty(name: String?): Any = unsupported()
    override fun setInput(reader: Reader?) = unsupported()
    override fun getInputEncoding(): String = unsupported()
    override fun defineEntityReplacementText(entityName: String?, replacementText: String?) = unsupported()
    override fun getNamespaceCount(depth: Int): Int = unsupported()
    override fun getNamespacePrefix(pos: Int): String = unsupported()
    override fun getNamespaceUri(pos: Int): String = unsupported()
    override fun getNamespace(prefix: String?): String = unsupported()
    override fun getNamespace(): String = unsupported()
    override fun getDepth(): Int = unsupported()
    override fun getPositionDescription(): String = unsupported()
    override fun getLineNumber(): Int = unsupported()
    override fun getColumnNumber(): Int = unsupported()
    override fun isWhitespace(): Boolean = unsupported()
    override fun getTextCharacters(holderForStartAndLength: IntArray?): CharArray = unsupported()
    override fun getPrefix(): String = unsupported()
    override fun isEmptyElementTag(): Boolean = unsupported()
    override fun getAttributeCount(): Int = unsupported()
    override fun getAttributeNamespace(index: Int): String = unsupported()
    override fun getAttributeName(index: Int): String = unsupported()
    override fun getAttributePrefix(index: Int): String = unsupported()
    override fun getAttributeType(index: Int): String = unsupported()
    override fun isAttributeDefault(index: Int): Boolean = unsupported()
    override fun getAttributeValue(index: Int): String = unsupported()
    override fun getAttributeValue(namespace: String?, name: String?): String = unsupported()
    override fun next(): Int = unsupported()
    override fun require(type: Int, namespace: String?, name: String?) = unsupported()
    override fun nextText(): String = unsupported()
    override fun nextTag(): Int = unsupported()

    private fun unsupported(): Nothing =
        throw UnsupportedOperationException("Not used by DocumentTextExtractor")
}

/**
 * Real XML parser for host tests: the JDK's Xerces SAX parser (android.jar
 * exposes no StAX API) records its events as pull tokens, and a parse error is
 * replayed in order as an XmlPullParserException. DTDs are reported (as
 * DOCDECL) rather than refused, so the extractor's own fail-closed rules are
 * what reject unsafe XML here. Like KXmlParser it refuses input until
 * namespaces are on, and it refuses DOCDECL processing outright so a
 * misconfigured extractor fails these tests.
 */
class SaxXmlPullParser : HostXmlPullParser() {
    private val tokens = ArrayDeque<ScriptedXmlPullParser.Token>()
    private var parseError: Exception? = null

    override fun setFeature(name: String, state: Boolean) {
        check(!(name == XmlPullParser.FEATURE_PROCESS_DOCDECL && state)) {
            "DOCDECL processing must stay off for DOCX extraction"
        }
        super.setFeature(name, state)
    }

    override fun setInput(inputStream: InputStream, inputEncoding: String?) {
        check(features[XmlPullParser.FEATURE_PROCESS_NAMESPACES] == true) {
            "Namespace processing must be enabled before setInput"
        }
        val factory = SAXParserFactory.newInstance().apply {
            isNamespaceAware = true
            setFeature("http://xml.org/sax/features/external-general-entities", false)
            setFeature("http://xml.org/sax/features/external-parameter-entities", false)
            setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false)
        }
        val recorder = TokenRecorder(tokens)
        try {
            val parser = factory.newSAXParser()
            parser.setProperty("http://xml.org/sax/properties/lexical-handler", recorder)
            parser.parse(InputSource(inputStream).apply { encoding = inputEncoding }, recorder)
        } catch (e: SAXException) {
            parseError = e
        } catch (e: IOException) {
            parseError = e
        }
    }

    override fun nextToken(): Int {
        val token = tokens.removeFirstOrNull()
        if (token == null) {
            parseError?.let { throw XmlPullParserException(it.message) }
            currentEvent = XmlPullParser.END_DOCUMENT
            currentName = null
            currentText = null
            return currentEvent
        }
        currentEvent = token.type
        currentName = token.name
        currentText = token.text
        return currentEvent
    }

    private class TokenRecorder(
        private val tokens: ArrayDeque<ScriptedXmlPullParser.Token>,
    ) : DefaultHandler2() {
        private var depth = 0
        private var inCdata = false

        private fun add(type: Int, name: String? = null, text: String? = null) {
            tokens.addLast(ScriptedXmlPullParser.Token(type, name, text))
        }

        override fun startDTD(name: String?, publicId: String?, systemId: String?) =
            add(XmlPullParser.DOCDECL)

        override fun startEntity(name: String) {
            // Parameter entities and the external subset only occur inside the DTD.
            if (depth > 0 && !name.startsWith("%") && !name.startsWith("[")) {
                add(XmlPullParser.ENTITY_REF, name = name, text = "")
            }
        }

        override fun skippedEntity(name: String) = add(XmlPullParser.ENTITY_REF, name = name)

        override fun startElement(uri: String?, localName: String, qName: String?, attributes: Attributes?) {
            depth++
            add(XmlPullParser.START_TAG, name = localName)
        }

        override fun endElement(uri: String?, localName: String, qName: String?) {
            depth--
            add(XmlPullParser.END_TAG, name = localName)
        }

        override fun characters(ch: CharArray, start: Int, length: Int) =
            add(if (inCdata) XmlPullParser.CDSECT else XmlPullParser.TEXT, text = String(ch, start, length))

        override fun ignorableWhitespace(ch: CharArray, start: Int, length: Int) =
            add(XmlPullParser.IGNORABLE_WHITESPACE, text = String(ch, start, length))

        override fun startCDATA() {
            inCdata = true
        }

        override fun endCDATA() {
            inCdata = false
        }

        override fun comment(ch: CharArray, start: Int, length: Int) = add(XmlPullParser.COMMENT)

        override fun processingInstruction(target: String?, data: String?) =
            add(XmlPullParser.PROCESSING_INSTRUCTION)
    }
}

/** Replays a fixed token list, for rules a conforming XML parser never reaches. */
class ScriptedXmlPullParser(private val tokens: List<Token>) : HostXmlPullParser() {
    data class Token(val type: Int, val name: String? = null, val text: String? = null)

    private var index = 0

    override fun setInput(inputStream: InputStream, inputEncoding: String?) {}

    override fun nextToken(): Int {
        val token = tokens.getOrElse(index++) { Token(XmlPullParser.END_DOCUMENT) }
        currentEvent = token.type
        currentName = token.name
        currentText = token.text
        return currentEvent
    }
}
