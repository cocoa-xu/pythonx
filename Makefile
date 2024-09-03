ifndef MIX_APP_PATH
	MIX_APP_PATH=$(shell pwd)
endif

PRIV_DIR = $(MIX_APP_PATH)/priv
NIF_SO = $(PRIV_DIR)/pythonx.so

C_SRC = $(shell pwd)/c_src
PYTHON3_VERSION_MAJOR = 3
PYTHON3_VERSION_MINOR = 8
PYTHON3_VERSION_PATCH = 16
PYTHON3_VERSION = $(PYTHON3_VERSION_MAJOR).$(PYTHON3_VERSION_MINOR).$(PYTHON3_VERSION_PATCH)
CACHE_DIR = $(shell pwd)/.cache
PYTHON3_SOURCE_TARBALL = $(CACHE_DIR)/Python-$(PYTHON3_VERSION).tgz
PYTHON3_SOURCE_URL = https://www.python.org/ftp/python/$(PYTHON3_VERSION)/Python-$(PYTHON3_VERSION).tgz
PYTHON3_SOURCE_DIR = $(CACHE_DIR)/Python-$(PYTHON3_VERSION)
PYTHON3_LIBRARY_DIR = $(PRIV_DIR)/python$(PYTHON3_VERSION)/usr/local/lib
PYTHONX_PREFER_PRECOMPILED_LIBPYTHON3 ?= true
PYTHONX_LIBPYTHON3_TRIPLET ?= native
CMAKE_PYTHONX_BUILD_DIR = $(MIX_APP_PATH)/cmake_pythonx

ifdef CC_PRECOMPILER_CURRENT_TARGET
	PYTHONX_LIBPYTHON3_TRIPLET=$(CC_PRECOMPILER_CURRENT_TARGET)
	ifeq ($(findstring darwin, $(CC_PRECOMPILER_CURRENT_TARGET)), darwin)
		ifeq ($(findstring aarch64, $(CC_PRECOMPILER_CURRENT_TARGET)), aarch64)
			CMAKE_CONFIGURE_FLAGS=-D CMAKE_OSX_ARCHITECTURES=arm64
		else
			CMAKE_CONFIGURE_FLAGS=-D CMAKE_OSX_ARCHITECTURES=x86_64
		endif
	else
		ifneq ($(findstring x86_64, $(CC_PRECOMPILER_CURRENT_TARGET)), x86_64)
			CMAKE_CONFIGURE_FLAGS=-D CMAKE_TOOLCHAIN_FILE="$(shell pwd)/cc_toolchain/$(CC_PRECOMPILER_CURRENT_TARGET).cmake"
		endif
	endif
endif
ifdef CMAKE_TOOLCHAIN_FILE
	CMAKE_CONFIGURE_FLAGS=-D CMAKE_TOOLCHAIN_FILE="$(CMAKE_TOOLCHAIN_FILE)"
endif

CMAKE_BUILD_TYPE ?= Release
DEFAULT_JOBS ?= $(shell erl -noshell -eval "io:format('~p~n',[erlang:system_info(logical_processors_online)]), halt().")
MAKE_BUILD_FLAGS ?= -j$(DEFAULT_JOBS)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
CHANGE_INSTALL_NAME = 1
endif
ifeq ($(TARGET_OS),linux)
CHANGE_INSTALL_NAME = 0
endif

build: $(NIF_SO)
	@ echo > /dev/null

$(CACHE_DIR):
	@ mkdir -p $(CACHE_DIR)

$(PRIV_DIR):
	@ mkdir -p $(PRIV_DIR)

$(PYTHON3_SOURCE_TARBALL): $(CACHE_DIR)
	@ if [ ! -f $(PYTHON3_SOURCE_TARBALL) ]; then \
		curl -fSL "$(PYTHON3_SOURCE_URL)" -o "$(PYTHON3_SOURCE_TARBALL)" ; \
	fi

$(PYTHON3_SOURCE_DIR): $(PYTHON3_SOURCE_TARBALL)
	@ if [ ! -d "$(PYTHON3_SOURCE_DIR)" ]; then \
		tar -xzf "$(PYTHON3_SOURCE_TARBALL)" -C "$(CACHE_DIR)" ; \
	fi

$(PYTHON3_LIBRARY_DIR): $(PRIV_DIR) $(PYTHON3_SOURCE_DIR)
	@ if [ ! -d "$(PYTHON3_LIBRARY_DIR)" ]; then \
		if [ "$(PYTHONX_PREFER_PRECOMPILED_LIBPYTHON3)" = "true" ]; then \
			bash ./scripts/download_precompiled_libpython3.sh "$(PYTHON3_VERSION_MINOR)" "$(PYTHON3_VERSION_PATCH)" "$(CACHE_DIR)" "$(PRIV_DIR)" "$(PYTHONX_LIBPYTHON3_TRIPLET)" ; \
			STATUS=$$? ; \
		fi ; \
		if [ "$$STATUS" != "0" ]; then \
			cd $(PYTHON3_SOURCE_DIR) && \
			CPP=cpp ./configure --prefix=/usr/local --enable-optimizations --with-lto=full --enable-shared=yes --with-static-libpython=no && \
			make $(MAKE_BUILD_FLAGS) && \
			make DESTDIR="$(PRIV_DIR)/python$(PYTHON3_VERSION)" install ; \
		fi ; \
	fi

$(NIF_SO): $(PYTHON3_LIBRARY_DIR)
	@ if [ ! -f $(NIF_SO) ]; then \
		cmake -S "$(shell pwd)" \
			-B "$(CMAKE_PYTHONX_BUILD_DIR)" \
		 	-D CMAKE_BUILD_TYPE="$(CMAKE_BUILD_TYPE)" \
			-D Python3_ROOT_DIR="$(PRIV_DIR)/python$(PYTHON3_VERSION)" \
			-D C_SRC="$(C_SRC)" \
			-D ERTS_INCLUDE_DIR="$(ERTS_INCLUDE_DIR)" \
			-D MIX_APP_PATH="$(MIX_APP_PATH)" \
			-D CMAKE_INSTALL_PREFIX="$(PRIV_DIR)" \
			$(CMAKE_CONFIGURE_FLAGS) && \
		cmake --build "$(CMAKE_PYTHONX_BUILD_DIR)" --config "$(CMAKE_BUILD_TYPE)" -j$(DEFAULT_JOBS) && \
		cmake --install "$(CMAKE_PYTHONX_BUILD_DIR)" --config "$(CMAKE_BUILD_TYPE)" && \
		if [ "$(CHANGE_INSTALL_NAME)" = "1" ]; then \
			install_name_tool -change /usr/local/lib/libpython$(PYTHON3_VERSION_MAJOR).$(PYTHON3_VERSION_MINOR).dylib @loader_path/python3/lib/libpython3.dylib "$(NIF_SO)" ; \
		fi ; \
	fi

clean:
	@ rm -rf "$(PRIV_DIR)"
	@ rm -rf "$(NIF_SO)"
	@ rm -rf "$(PYTHON3_SOURCE_DIR)"

clean_pythonx:
	@ rm -rf "$(NIF_SO)"
