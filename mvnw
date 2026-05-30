#!/usr/bin/env sh
set -eu

# Minimal Maven Wrapper bootstrapper for Unix-like shells.

BASEDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
WRAPPER_DIR="$BASEDIR/.mvn/wrapper"
WRAPPER_JAR="$WRAPPER_DIR/maven-wrapper.jar"
PROPS="$WRAPPER_DIR/maven-wrapper.properties"

mkdir -p "$WRAPPER_DIR"

if [ ! -f "$WRAPPER_JAR" ]; then
  echo "Downloading Maven Wrapper..."
  if [ ! -f "$PROPS" ]; then
    echo "Missing $PROPS" >&2
    exit 1
  fi
  WRAPPER_URL=$(grep -E '^\s*wrapperUrl=' "$PROPS" | head -n 1 | sed 's/^\s*wrapperUrl=//')
  if [ -z "$WRAPPER_URL" ]; then
    WRAPPER_URL="https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar"
  fi

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$WRAPPER_URL" -o "$WRAPPER_JAR"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$WRAPPER_URL" -O "$WRAPPER_JAR"
  else
    echo "Neither curl nor wget is available to download Maven Wrapper." >&2
    exit 1
  fi
fi

JAVA_EXE="${JAVA_HOME:-}/bin/java"
if [ -x "$JAVA_EXE" ]; then
  :
elif command -v java >/dev/null 2>&1; then
  JAVA_EXE=$(command -v java)
else
  echo "Java not found. Install JDK 21 and set JAVA_HOME or PATH." >&2
  exit 1
fi

exec "$JAVA_EXE" -Dmaven.multiModuleProjectDirectory="$BASEDIR" -classpath "$WRAPPER_JAR" org.apache.maven.wrapper.MavenWrapperMain "$@"
