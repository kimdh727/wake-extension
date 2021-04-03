#!/bin/sh

JAR_PATH=$(realpath $(dirname $(realpath $0))/../antlr-4.9-complete.jar)
# echo $JAR_PATH

export CLASSPATH=".:$JAR_PATH:$CLASSPATH"

alias antlr4='java -Xmx500M -cp "$JAR_PATH:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java -Xmx500M -cp "$JAR_PATH:$CLASSPATH" org.antlr.v4.gui.TestRig'
