#!/bin/sh
# Launch WEKA; keeps all WEKA config/packages inside this folder (instead of ~/wekafiles)
DIR="$(cd "$(dirname "$0")" && pwd)"
export WEKA_HOME="$DIR/weka/wekafiles"
cd "$DIR/weka/weka-3-8-6"
exec java -Xmx2g -Djava.security.manager=allow --add-opens java.base/java.lang=ALL-UNNAMED -jar weka.jar "$@"
