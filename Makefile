#* Dtop++ makefile v1.2

BANNER  = \n \
\033[38;5;208m██████╗ ████████╗ ██████╗ ██████╗\033[0m\n \
\033[38;5;208m██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗\033[0m\n \
\033[38;5;202m██║  ██║   ██║   ██║   ██║██████╔╝\033[0m\n \
\033[38;5;202m██║  ██║   ██║   ██║   ██║██╔═══╝\033[0m\n \
\033[38;5;166m██████╔╝   ██║   ╚██████╔╝██║\033[0m\n \
\033[38;5;166m╚═════╝    ╚═╝    ╚═════╝ ╚═╝\033[0m\n

override DTOP_VERSION := $(shell head -n100 src/dtop.cpp 2>/dev/null | grep "Version =" | cut -f2 -d"\"" || echo " unknown")
override TIMESTAMP := $(shell date +%s 2>/dev/null || echo "0")

PREFIX ?= /usr/local

#? NOTICE! Manually set PLATFORM and ARCH if not compiling for host system
RDK_Series ?= $(shell cat /sys/firmware/devicetree/base/model)
PLATFORM ?= $(shell uname -s || echo unknown)
ARCH ?= $(shell uname -p || echo unknown)

#? Only enable fcf-protection if on x86_64
ifeq ($(ARCH),unknown)
	ARCH := $(shell uname -m || echo unknown)
endif
ifeq ($(ARCH),x86_64)
	override ADDFLAGS += -fcf-protection
endif

ifeq ($(STATIC),true)
	override ADDFLAGS += -static -static-libgcc -static-libstdc++
endif

#? Make sure PLATFORM Darwin is OSX and not Darwin
ifeq ($(PLATFORM),Darwin)
	ifeq ($(shell sw_vers >/dev/null 2>&1; echo $$?),0)
		PLATFORM := OSX
	endif
endif

#? Compiler and Linker
CXX ?= g++
override CXX_VERSION := $(shell $(CXX) -dumpfullversion -dumpversion || echo 0)

#? Try to make sure we are using GCC/G++ version 11 or later if not instructed to use g++-10
ifneq ($(CXX),g++-10)
	V_MAJOR := $(shell echo $(CXX_VERSION) | cut -f1 -d".")
	ifneq ($(shell test $(V_MAJOR) -ge 11; echo $$?),0)
		ifeq ($(shell command -v g++-11 >/dev/null; echo $$?),0)
			override CXX := g++-11
			override CXX_VERSION := $(shell $(CXX) -dumpfullversion -dumpversion || echo 0)
		endif
	endif
endif

#? Pull in platform specific source files and get thread count
ifeq ($(PLATFORM),Linux)
	PLATFORM_DIR := linux
	THREADS	:= $(shell getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
else ifeq ($(PLATFORM),FreeBSD)
	PLATFORM_DIR := freebsd
	THREADS	:= $(shell getconf NPROCESSORS_ONLN 2>/dev/null || echo 1)
else ifeq ($(PLATFORM),OSX)
	PLATFORM_DIR := osx
	THREADS	:= $(shell sysctl -n hw.ncpu || echo 1)
else
$(error $(shell printf "\033[1;91mERROR: \033[97mUnsupported platform ($(PLATFORM))\033[0m"))
endif

#? Use all CPU cores (will only be set if using Make 4.3+)
MAKEFLAGS	:= --jobs=$(THREADS)
ifeq ($(THREADS),1)
	override THREADS := auto
endif

#? The Directories, Source, Includes, Objects and Binary
SRCDIR		:= src
INCDIR		:= include
BUILDDIR	:= obj
TARGETDIR	:= bin
DEBIANDIR	:= debian
SRCEXT		:= cpp
DEPEXT		:= d
OBJEXT		:= o

#? Flags, Libraries and Includes
override REQFLAGS   := -std=c++20
WARNFLAGS			:= -Wall -Wextra -pedantic
OPTFLAGS			?= -O2 -ftree-loop-vectorize -flto=$(THREADS)
LDCXXFLAGS			:= -pthread -D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS -fexceptions -fstack-protector -fstack-clash-protection $(ADDFLAGS)
override CXXFLAGS	+= $(REQFLAGS) $(LDCXXFLAGS) $(OPTFLAGS) $(WARNFLAGS)
override LDFLAGS	+= $(LDCXXFLAGS) $(OPTFLAGS) $(WARNFLAGS)
INC					:= -I$(INCDIR) -I$(SRCDIR)
SU_USER				:= root
SU_GROUP			:= root

SOURCES	:= $(shell find $(SRCDIR) -maxdepth 1 -type f -name *.$(SRCEXT))

SOURCES += $(shell find $(SRCDIR)/$(PLATFORM_DIR) -type f -name *.$(SRCEXT))

OBJECTS	:= $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.$(OBJEXT)))

#? Default Make
all: pre directories dtop

debian: pre directories dtop
	@rm -rf $(DEBIANDIR)/*
	@cp -rf DEBIAN $(DEBIANDIR)
	@sed -i 's/$${VERSION}/$(DTOP_VERSION)/' $(DEBIANDIR)/DEBIAN/control
	@install -d $(DEBIANDIR)/usr/hobot/bin/
	@install -m 755 $(TARGETDIR)/dtop $(DEBIANDIR)/usr/hobot/bin/
	@install -d $(DEBIANDIR)/usr/share/doc/dtop
	@install -m 666 README.md $(DEBIANDIR)/usr/share/doc/dtop
	@install -d $(DEBIANDIR)/usr/share/doc/dtop/themes
	@install themes/* $(DEBIANDIR)/usr/share/doc/dtop/themes
	@fakeroot dpkg-deb -b $(DEBIANDIR) ./

pre:
	@printf " $(BANNER)\n"
	@printf "\033[1;33mRDK_Series \033[1;33m?| \033[0m$(RDK_Series)\n"
	@printf "\033[1;92mPLATFORM   \033[1;93m?| \033[0m$(PLATFORM)\n"
	@printf "\033[1;96mARCH       \033[1;93m?| \033[0m$(ARCH)\n"
	@printf "\033[1;93mCXX        \033[1;93m?| \033[0m$(CXX) \033[1;93m(\033[97m$(CXX_VERSION)\033[93m)\n"
	@printf "\033[1;94mTHREADS    \033[1;94m:| \033[0m$(THREADS)\n"
	@printf "\033[1;92mREQFLAGS   \033[1;91m!| \033[0m$(REQFLAGS)\n"
	@printf "\033[1;91mWARNFLAGS  \033[1;94m:| \033[0m$(WARNFLAGS)\n"
	@printf "\033[1;94mOPTFLAGS   \033[1;94m:| \033[0m$(OPTFLAGS)\n"
	@printf "\033[1;93mLDCXXFLAGS \033[1;94m:| \033[0m$(LDCXXFLAGS)\n"
	@printf "\033[1;95mCXXFLAGS   \033[1;92m+| \033[0;37m\$$(\033[92mREQFLAGS\033[37m) \$$(\033[93mLDCXXFLAGS\033[37m) \$$(\033[94mOPTFLAGS\033[37m) \$$(\033[91mWARNFLAGS\033[37m)\n"
	@printf "\033[1;95mLDFLAGS    \033[1;92m+| \033[0;37m\$$(\033[93mLDCXXFLAGS\033[37m) \$$(\033[94mOPTFLAGS\033[37m) \$$(\033[91mWARNFLAGS\033[37m)\n"

	@printf "\n\033[1;92mBuilding dtop++ \033[93m(\033[97mv$(DTOP_VERSION)\033[93m)\033[0m\n"

help:
	@printf " $(BANNER)\n"
	@printf "\033[1;97mdtop++ makefile\033[0m\n"
	@printf "usage: make [argument]\n\n"
	@printf "arguments:\n"
	@printf "  all          Compile dtop (default argument)\n"
	@printf "  clean        Remove built objects\n"
	@printf "  distclean    Remove built objects and binaries\n"
	@printf "  install      Install dtop++ to \$$PREFIX ($(PREFIX))\n"
	@printf "  setuid       Set installed binary owner/group to \$$SU_USER/\$$SU_GROUP ($(SU_USER)/$(SU_GROUP)) and set SUID bit\n"
	@printf "  uninstall    Uninstall dtop++ from \$$PREFIX\n"
	@printf "  debian       Create debian package from \$$TARGETDIR\n"

#? Make the Directories
directories:
	@mkdir -p $(TARGETDIR)
	@mkdir -p $(BUILDDIR)/$(PLATFORM_DIR)
	@mkdir -p $(DEBIANDIR)/

#? Clean only Objects
clean:
	@printf "\033[1;91mRemoving: \033[1;97mbuilt objects...\033[0m\n"
	@rm -rf $(BUILDDIR)

#? Clean Objects and Binaries
distclean: clean
	@printf "\033[1;91mRemoving: \033[1;97mbuilt binaries...\033[0m\n"
	@rm -rf $(TARGETDIR) $(DEBIANDIR)

install:
	@printf "\033[1;92mInstalling binary to: \033[1;97m$(DESTDIR)$(PREFIX)/bin/dtop\n"
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -p $(TARGETDIR)/dtop $(DESTDIR)$(PREFIX)/bin/dtop
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/dtop
	@printf "\033[1;92mInstalling doc to: \033[1;97m$(DESTDIR)$(PREFIX)/share/dtop\n"
	@mkdir -p $(DESTDIR)$(PREFIX)/share/dtop
	@cp -p README.md $(DESTDIR)$(PREFIX)/share/dtop
	@printf "\033[1;92mInstalling themes to: \033[1;97m$(DESTDIR)$(PREFIX)/share/dtop/themes\n"
	@cp -pr themes $(DESTDIR)$(PREFIX)/share/dtop

#? Set SUID bit for dtop as $SU_USER in $SU_GROUP
setuid:
	@printf "\033[1;97mFile: $(DESTDIR)$(PREFIX)/bin/dtop\n"
	@printf "\033[1;92mSetting owner \033[1;97m$(SU_USER):$(SU_GROUP)\033[0m\n"
	@chown $(SU_USER):$(SU_GROUP) $(DESTDIR)$(PREFIX)/bin/dtop
	@printf "\033[1;92mSetting SUID bit\033[0m\n"
	@chmod u+s $(DESTDIR)$(PREFIX)/bin/dtop

uninstall:
	@printf "\033[1;91mRemoving: \033[1;97m$(DESTDIR)$(PREFIX)/bin/dtop\033[0m\n"
	@rm -rf $(DESTDIR)$(PREFIX)/bin/dtop
	@printf "\033[1;91mRemoving: \033[1;97m$(DESTDIR)$(PREFIX)/share/dtop\033[0m\n"
	@rm -rf $(DESTDIR)$(PREFIX)/share/dtop

#? Pull in dependency info for *existing* .o files
-include $(OBJECTS:.$(OBJEXT)=.$(DEPEXT))

#? Link
.ONESHELL:
dtop: $(OBJECTS)
	@sleep 0.1 2>/dev/null || true
	@TSTAMP=$$(date +%s 2>/dev/null || echo "0")
	@printf "\n\033[1;92mLinking and optimizing binary\033[37m...\033[0m\n"
	@$(CXX) -o $(TARGETDIR)/dtop $^ $(LDFLAGS) || exit 1
	@printf "\033[1;92m-> \033[1;37m$(TARGETDIR)/dtop \033[100D\033[35C\033[1;93m(\033[1;97m$$(du -ah $(TARGETDIR)/dtop | cut -f1)iB\033[1;93m) \033[92m(\033[97m$$(date -d @$$(expr $$(date +%s 2>/dev/null || echo "0") - $${TSTAMP} 2>/dev/null) -u +%Mm:%Ss 2>/dev/null | sed 's/^00m://' || echo '')\033[92m)\033[0m\n"
	@printf "\n\033[1;92mBuild complete in \033[92m(\033[97m$$(date -d @$$(expr $$(date +%s 2>/dev/null || echo "0") - $(TIMESTAMP) 2>/dev/null) -u +%Mm:%Ss 2>/dev/null | sed 's/^00m://' || echo "unknown")\033[92m)\033[0m\n"

#? Compile
.ONESHELL:
$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(SRCEXT)
	@sleep 0.1 2>/dev/null || true
	@TSTAMP=$$(date +%s 2>/dev/null || echo "0")
	@printf "\033[1;97mCompiling $<\033[0m\n"
	@$(CXX) $(CXXFLAGS) $(INC) -c -o $@ $< || exit 1
	@$(CXX) $(CXXFLAGS) $(INC) -MM $(SRCDIR)/$*.$(SRCEXT) > $(BUILDDIR)/$*.$(DEPEXT) >/dev/null || exit 1
	@cp -f $(BUILDDIR)/$*.$(DEPEXT) $(BUILDDIR)/$*.$(DEPEXT).tmp
	@sed -e 's|.*:|$(BUILDDIR)/$*.$(OBJEXT):|' < $(BUILDDIR)/$*.$(DEPEXT).tmp > $(BUILDDIR)/$*.$(DEPEXT)
	@sed -e 's/.*://' -e 's/\\$$//' < $(BUILDDIR)/$*.$(DEPEXT).tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $(BUILDDIR)/$*.$(DEPEXT)
	@rm -f $(BUILDDIR)/$*.$(DEPEXT).tmp
	@printf "\033[1;92m-> \033[1;37m$@ \033[100D\033[35C\033[1;93m(\033[1;97m$$(du -ah $@ | cut -f1)iB\033[1;93m) \033[92m(\033[97m$$(date -d @$$(expr $$(date +%s 2>/dev/null || echo "0") - $${TSTAMP} 2>/dev/null) -u +%Mm:%Ss 2>/dev/null | sed 's/^00m://' || echo '')\033[92m)\033[0m\n"

#? Non-File Targets
.PHONY: all msg help pre debian
