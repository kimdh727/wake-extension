```
cd src

source env.sh

antlr4 Wake.g4
javac Wake*.java
grun Wake <rule> -gui
