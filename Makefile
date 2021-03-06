JVM = java
JAR = jar
JC = javac
LIB = lib/
CURL = curl
CURLF = -s
PNAME = tubes
OUT = bin/
JFLAGS = -g -d $(OUT)
JARFLG = cfe
MAIN = Driver
SRC = src

JUnit.ver = 4.13
JUnit.jar = junit-$(JUnit.ver).jar
Hamcrest.ver = 1.3
Hamcrest.jar = hamcrest-core-$(Hamcrest.ver).jar
Maven.http = https://repo1.maven.org/maven2/
JUnit.mvn = $(Maven.http)junit/junit/$(JUnit.ver)/$(JUnit.jar)
Hamcrest.mvn = $(Maven.http)org/hamcrest/hamcrest-core/$(Hamcrest.ver)/$(Hamcrest.jar)

.SUFFIXES = .java .class

all: clean runJar

compile: dirs
	$(JC) $(JFLAGS) $(SRC)/$(PNAME)/*.java

run: compile
	cd $(OUT); $(JVM) $(addprefix $(PNAME)., $(MAIN))

tubes.jar: compile
	$(JAR) $(JARFLG) tubes.jar $(addprefix $(PNAME)., $(MAIN)) -C $(OUT) $(PNAME)

runJar: tubes.jar
	$(JVM) -jar tubes.jar

dirs:
	mkdir -p $(OUT)
	mkdir -p lib

hamcrest-download: dirs
ifeq (, $(wildcard lib/$(Hamcrest.jar)))
	$(CURL) $(CURLF) -z lib/$(Hamcrest.jar) -o lib/$(Hamcrest.jar) $(Hamcrest.mvn)
endif

junit-download: dirs
ifeq (, $(wildcard lib/$(JUnit.jar)))
	$(CURL) $(CURLF) -z lib/$(JUnit.jar) -o lib/$(JUnit.jar) $(JUnit.mvn)
endif

compile-test: compile junit-download hamcrest-download
	$(JC) -d $(OUT)test \
		-cp lib/$(JUnit.jar):lib/$(Hamcrest.jar):$(OUT) \
		$(SRC)/test/*.java

test: compile-test
	$(JVM) \
		--class-path $(OUT)test:$(OUT):lib/$(JUnit.jar):lib/$(Hamcrest.jar) \
		org.junit.runner.JUnitCore MatriksTest PointTest

.PHONY: clean all

clean:
	$(RM) -r Matriks *.jar bin
