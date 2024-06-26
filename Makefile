ifndef MIX_APP_PATH
	MIX_APP_PATH=$(shell pwd)
endif

PRIV_DIR = $(MIX_APP_PATH)/priv
NIF_SO = $(PRIV_DIR)/pythonx.so

C_SRC = $(shell pwd)/c_src
PYTHON3_VERSION = 3.12.4
CACHE_DIR = $(shell pwd)/.cache
PYTHON3_SOURCE_TARBALL = $(CACHE_DIR)/Python-$(PYTHON3_VERSION).tgz
PYTHON3_SOURCE_URL = https://www.python.org/ftp/python/$(PYTHON3_VERSION)/Python-$(PYTHON3_VERSION).tgz
PYTHON3_SOURCE_DIR = $(CACHE_DIR)/Python-$(PYTHON3_VERSION)
PYTHON3_LIBRARY_DIR = $(PRIV_DIR)/lib
CMAKE_PYTHONX_BUILD_DIR = $(MIX_APP_PATH)/cmake_pythonx

ifdef CMAKE_TOOLCHAIN_FILE
	CMAKE_CONFIGURE_FLAGS=-D CMAKE_TOOLCHAIN_FILE="$(CMAKE_TOOLCHAIN_FILE)"
endif

CMAKE_BUILD_TYPE ?= Release
DEFAULT_JOBS ?= $(shell erl -noshell -eval "io:format('~p~n',[erlang:system_info(logical_processors_online)]), halt().")
MAKE_BUILD_FLAGS ?= -j$(DEFAULT_JOBS)

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
		cd $(PYTHON3_SOURCE_DIR) && \
		./configure --prefix=/priv/python3 --enable-optimizations --with-lto=full --enable-shared=yes --with-static-libpython=no && \
		make $(MAKE_BUILD_FLAGS) && \
		make DESTDIR="$(MIX_APP_PATH)" install ; \
	fi

$(NIF_SO): $(PYTHON3_LIBRARY_DIR)
	@ if [ ! -f $(NIF_SO) ]; then \
		cmake -S "$(shell pwd)" \
			-B "$(CMAKE_PYTHONX_BUILD_DIR)" \
		 	-D CMAKE_BUILD_TYPE="$(CMAKE_BUILD_TYPE)" \
			-D Python3_ROOT_DIR="$(PRIV_DIR)/python3" \
			-D C_SRC="$(C_SRC)" \
			$(CMAKE_CONFIGURE_FLAGS) && \
		cmake --build "$(CMAKE_PYTHONX_BUILD_DIR)" --config "$(CMAKE_BUILD_TYPE)" -j$(DEFAULT_JOBS) && \
		cp "$(CMAKE_PYTHONX_BUILD_DIR)/pythonx.so" "$(NIF_SO)" ; \
	fi

clean:
	@ rm -rf "$(PRIV_DIR)/python3"
	@ rm -rf "$(NIF_SO)"
	@ if [ -d "$(PYTHON3_SOURCE_DIR)" ]; then \
		cd $(PYTHON3_SOURCE_DIR) && \
		make clean ; \
	fi

clean_pythonx:
	@ rm -rf "$(NIF_SO)"
