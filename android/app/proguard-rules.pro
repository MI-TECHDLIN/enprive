# PDFBox-Android (2.0.27.0) declares com.gemalto.jp2:jp2-android as an optional
# compile-only dependency omitted from its Maven POM. JPXFilter guards
# JP2Decoder lookup via Class.forName(...) at runtime, and Enprive only invokes
# PDFTextStripper for selectable text extraction.
-dontwarn com.gemalto.jp2.JP2Decoder
-dontwarn com.gemalto.jp2.JP2Encoder
