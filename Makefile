#!/usr/bin/env make -f

# Java Repo Template
# ..................................
# Copyright (c) 2017, Kendrick Walls
# ..................................
# Licensed under MIT (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# ..........................................
# http://www.github.com/reactive-firewall/java-repo/LICENSE
# ..........................................
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


ifeq "$(ECHO)" ""
	ECHO=/bin/echo
endif

ifeq "$(LINK)" ""
	LINK = ln -s -f
endif

ifeq "$(MAKE)" ""
	MAKE=make
endif

ifeq "$(WAIT)" ""
	WAIT=wait
endif

ifeq "$(INSTALL)" ""
	INSTALL=install
	ifeq "$(INST_OWN)" ""
		INST_OWN=-o root -g staff
	endif
	ifeq "$(INST_OPTS)" ""
		INST_OPTS=-m 755
	endif
endif

ifeq "$(LOG)" ""
	LOG=no
endif

ifeq "$(LOG)" "no"
	QUIET=@
endif

ifeq "$(DO_FAIL)" ""
	DO_FAIL=$(ECHO) "ok"
endif

ifeq "$(LOGNAME)" ""
	LOGNAME=`whoami`
endif

CHGRP = chgrp
CHMOD = chmod
CHOWN = chown
CP = /bin/cp -v
EXIT = exit
GENMANIFEST = ./genManifest.sh
JAVAC = javac
JAVADOC = javadoc
JAVADOCTAGS = -protected -version -link http://download.oracle.com/javase/7/docs/api/ -charset "UTF-8" -windowtitle "java-repo Documentation" -author -group "Java Template Repository" org:org.* -sourcepath ./src/
JARZIP = jar
MAKE_OPTIONS = --no-print-directory
MAKEWHATIS = /usr/libexec/makewhatis.local 
MKDIR = mkdir -p
MV = mv -v
PROJECT_NAME = "java-repo"
PRINT = printf
PATCH = patch -f -i
QUIET = @

RM = rm -f
RMDIR = rmdir
SHELL = /bin/bash
SYNC = sync
TARGET_NAME = "javarepo"
TOUCH = touch -am
UNTAR = tar --extract
UNTAR_OPTION = --file
UNZIP = unzip
UNZIP_OPTION = -q -u -o

#reset time to January 01 2017 at 12:46:13 AM

RESET_TIME = $(TOUCH) -c -f -t 201701010046.13

PHONY: must_be_root cleanup

safe:
	$(QUIET)$(ECHO) "No target." ;
	$(QUIET)$(EXIT) 0 ;

init:
	$(QUIET)$(ECHO) "$@: Done."

build: ./src ./bin ./dist ./dist/$(TARGET_NAME).jar JavaDoc clean
	$(QUIET)$(ECHO) "Built "$(PROJECT_NAME)"." ;

install: build
	$(QUIET)if [[ `uname -s` == "Darwin" ]] ; then $(MAKE) $(MAKE_OPTIONS) DIRECTIVE=install darwin ; else $(MAKE) $(MAKE_OPTIONS) DIRECTIVE=install linux ; fi
	$(QUIET)$(ECHO) "Installed "$(PROJECT_NAME)"." ;

darwin:
	$(QUIET)$(CP) ./dist/Tools.jar /usr/local/share/java/$(TARGET_NAME).jar ; 
	$(QUIET)$(WAIT) ;
	$(QUIET)$(CHMOD) 0755 /usr/local/share/java/$(TARGET_NAME).jar ;
	$(QUIET)$(CHOWN) 0 /usr/local/share/java/$(TARGET_NAME).jar ;
	$(QUIET)$(CHGRP) staff /usr/local/share/java/$(TARGET_NAME).jar ;
	$(QUIET)$(ECHO) "Installed "$(PROJECT_NAME)".jar." ;
    
linux:
	$(QUIET)$(CP) ./dist/$(TARGET_NAME).jar /usr/local/share/java/$(TARGET_NAME).jar ;
	$(QUIET)$(WAIT) ;
	$(QUIET)$(CHMOD) 0750 /usr/local/share/java/$(TARGET_NAME).jar ;
	$(QUIET)$(CHOWN) 0 /usr/local/share/java/$(TARGET_NAME).jar ;
	$(QUIET)$(CHGRP) bin /usr/local/share/java/$(TARGET_NAME).jar ;
	$(QUIET)$(ECHO) "Installed "$(PROJECT_NAME)".jar." ;

cleanup:
	$(QUIET)$(RM) ./bin/org/*.class 2>/dev/null || true
	$(QUIET)$(RM) ./bin/org/**/*.class 2>/dev/null || true
	$(QUIET)$(RMDIR) ./bin/org/* 2>/dev/null || true
	$(QUIET)$(RM) ./bin/*.class 2>/dev/null || true
	$(QUIET)$(RMDIR) ./bin/org 2>/dev/null || true
	$(QUIET)$(RMDIR) ./bin 2>/dev/null || true
	$(QUIET)$(RM) tests/*.class 2>/dev/null || true
	$(QUIET)$(RM) tests/*~ 2>/dev/null || true
	$(QUIET)$(RM) src/*.class 2>/dev/null || true
	$(QUIET)$(RM) src/*~ 2>/dev/null || true
	$(QUIET)$(RM) *.class 2>/dev/null || true
	$(QUIET)$(RM) bin/*/*.class 2>/dev/null || true
	$(QUIET)$(RM) bin/*/*~ 2>/dev/null || true
	$(QUIET)$(RM) *.DS_Store 2>/dev/null || true
	$(QUIET)$(RM) bin/*.DS_Store 2>/dev/null || true
	$(QUIET)$(RM) bin/*/*.DS_Store 2>/dev/null || true
	$(QUIET)$(RM) jar/* 2>/dev/null || true
	$(QUIET)$(RMDIR) jar 2>/dev/null || true
	$(QUIET)$(RM) ./*/*~ 2>/dev/null || true
	$(QUIET)$(RM) ./*~ 2>/dev/null || true
	$(QUIET)$(RM) ./.*~ 2>/dev/null || true

clean: cleanup
	$(QUIET)$(WAIT) ;
	$(QUIET)$(ECHO) "Cleaned "$(PROJECT_NAME)"." ;
	$(QUIET)$(ECHO) "$@: Done."

./bin: ./src
	$(QUIET)$(MKDIR) $@
	$(QUIET)$(CHMOD) 750 $@
	$(QUIET)$(CHOWN) $(LOGNAME) $@
	$(QUIET)$(JAVAC) -encoding UTF8 -classpath ./src/:**/*.jar -d $@ ./src/org/**/*.java
	$(QUIET)$(WAIT) ;
	$(QUIET)$(SYNC) ;
	$(QUIET)$(ECHO) "Compiled "$(TARGET_NAME)"." ;

./dist:
	$(QUIET)$(MKDIR) $@
	$(QUIET)$(CHMOD) 750 $@
	$(QUIET)$(CHOWN) $(LOGNAME) $@


./dist/$(TARGET_NAME).jar: ./bin ./dist ./resources ./resources/Manifest ./README
	$(QUIET)$(JARZIP) cmf ./resources/Manifest ./dist/$(TARGET_NAME).jar -C ./bin .
	$(QUIET)$(WAIT) ;
	$(QUIET)$(JARZIP) uf ./dist/$(TARGET_NAME).jar README ;
	$(QUIET)$(WAIT) ;
	$(QUIET)$(RM) ./dist/.DS_Store 2>/dev/null || true
	$(QUIET)$(WAIT) ;
	$(QUIET)$(ECHO) "Bundled "$(TARGET_NAME)"." ;

./src:
	$(QUIET)$(MKDIR) $@
	$(QUIET)$(CHMOD) 750 $@
	$(QUIET)$(CHOWN) $(LOGNAME) $@
	$(QUIET)$(ECHO) "No Source Code ... You're Screwed." ;

./resources/Manifest: ./bin ./resources
	$(QUIET)$(ECHO) "Class-Path: "$(TARGET_NAME)".jar" > ./resources/Manifest ;
	$(QUIET)$(GENMANIFEST) ./bin/org >> ./resources/Manifest ;
	$(QUIET)$(WAIT) ;

./resources:
	$(QUIET)$(MKDIR) $@
	$(QUIET)$(CHMOD) 750 $@
	$(QUIET)$(CHOWN) $(LOGNAME) $@
	$(QUIET)$(ECHO) "No Resource Files ... Need to Generate." ;

./docs/stylesheet.css: ./docs
	$(QUIET)$(ECHO) "... Whatever \"$@\" actually is, it is suffering from massive existence failure, try looking on another plane of existence ..." ;

JavaDoc: ./docs ./docs/robots.txt
	$(QUIET)$(ECHO) -n "Generating Documentation... "
	$(QUIET)if [[ ( -e ./docs/stylesheet.css ) ]] ; then $(JAVADOC) -d ./docs/ $(JAVADOCTAGS) -stylesheetfile ./docs/stylesheet.css org.* ; else $(JAVADOC) -d ./docs/ $(JAVADOCTAGS) org.* org.pythonrepo.* ; fi
	$(QUIET)$(ECHO) "DONE" ;

./docs:
	$(QUIET)$(MKDIR) $@
	$(QUIET)$(CHMOD) 750 $@
	$(QUIET)$(CHOWN) $(LOGNAME) $@

./docs/robots.txt: ./docs
	$(QUIET)$(ECHO) "User-agent: *" > $@
	$(QUIET)$(ECHO) "Disallow: package-list" >> $@
	$(QUIET)$(ECHO) "" >> $@
	$(QUIET)$(ECHO) "User-agent: Googlebot" >> $@
	$(QUIET)$(ECHO) "Disallow: *.html" >> $@

uninstall:
	$(QUITE)$(WAIT)
	$(QUIET)$(ECHO) "$@: Done."

purge: clean uninstall
	$(QUIET)$(ECHO) "$@: Done."

test: cleanup build
	$(QUIET)$(WAIT)
	$(QUIET)$(ECHO) "$@: Done."

test-style: cleanup
	$(QUIET)$(ECHO) "$@: Done."

must_be_root:
	$(QUIET)runner=`whoami` ; \
	if test $$runner != "root" ; then echo "You are not root." ; exit 1 ; fi

%:
	$(QUIET)$(ECHO) "No Rule Found For $@" ; $(WAIT) ;
	$(QUIET)$(ECHO) "... MISSING UNKNOWN FILE \"$@\" ..." ;
	$(QUIET)$(ECHO) "... Whatever \"$@\" actually is, it is suffering from massive existence failure, try looking on another plane of existence ..." ;

