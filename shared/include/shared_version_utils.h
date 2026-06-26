// Shared sketch version metadata utilities
// Common helper functions for printing sketch metadata

#ifndef SHARED_VERSION_UTILS_H
#define SHARED_VERSION_UTILS_H

#include <Arduino.h>

inline void printSketchMetadata(const char* sketchName,
                                const char* sketchVersion,
                                const char* sketchAuthor,
                                const char* sketchDate) {
  Serial.print(F("Sketch: "));
  Serial.println(sketchName);
  Serial.print(F("Version: "));
  Serial.println(sketchVersion);
  Serial.print(F("Author: "));
  Serial.println(sketchAuthor);
  Serial.print(F("Date: "));
  Serial.println(sketchDate);
}

inline void printSketchMetadata() {
#if defined(SKETCH_NAME) && defined(SKETCH_VERSION) && defined(SKETCH_AUTHOR) && defined(SKETCH_DATE)
  printSketchMetadata(SKETCH_NAME, SKETCH_VERSION, SKETCH_AUTHOR, SKETCH_DATE);
#else
  Serial.println(F("Sketch metadata unavailable"));
#endif
}

#endif // SHARED_VERSION_UTILS_H
