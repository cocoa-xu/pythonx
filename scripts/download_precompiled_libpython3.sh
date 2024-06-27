#!/usr/bin/env bash

LIBPYTHON3_VERSION=$1
LIBPYTHON3_CACHE_DIR=$2
PRIV_DIR=$3
PYTHONX_LIBPYTHON3_TRIPLET=$4
PRECOMPILED_LIBPYTHON3_URL_BASE="https://github.com/cocoa-xu/libpython3-build/releases/download/v${LIBPYTHON3_VERSION}"

if [ -z "$LIBPYTHON3_VERSION" ]; then
  echo "[!] Usage: $0 <libpython3_version> <libpython3_cache_dir> <priv_dir> <pythonx_libpython3_triplet>"
  exit 1
fi

get_triplet() {
  if [ "${PYTHONX_LIBPYTHON3_TRIPLET}" = "native" ]; then
    if [[ -n "${TARGET_ARCH}" && -n "${TARGET_OS}" && -n "${TARGET_ABI}" ]]; then
      if [ "${TARGET_ARCH}" = "arm" ]; then
        case "${TARGET_CPU}" in
          arm1176jzf_s*)
            echo "armv6-${TARGET_OS}-${TARGET_ABI}"
          ;;
          cortex*)
            echo "armv7l-${TARGET_OS}-${TARGET_ABI}"
          ;;
          *)
            echo "Unknown TARGET_CPU: ${TARGET_CPU}"
            exit 1
          ;;
        esac
      else
        echo "${TARGET_ARCH}-${TARGET_OS}-${TARGET_ABI}"
      fi
    fi

    UNAME_M="$(uname -m)"
    if [ -n "${TARGET_ARCH}" ]; then
      UNAME_M="${TARGET_ARCH}"
      if [ "${TARGET_ARCH}" = "arm" ]; then
        case "${TARGET_CPU}" in
          arm1176* | arm1156* | arm1136*)
            UNAME_M="armv6"
          ;;
          cortex*)
            UNAME_M="armv7l"
          ;;
          *)
            UNAME_M="${TARGET_ARCH}"
          ;;
        esac
      fi
    fi
    UNAME_S="$(uname -s)"
    if [ -n "${TARGET_OS}" ]; then
      UNAME_S="${TARGET_OS}"
    fi

    case "${UNAME_M}-${UNAME_S}" in
      arm64-Darwin*)
        echo "aarch64-apple-darwin"
      ;;
      x86_64-Darwin*)
        echo "x86_64-apple-darwin"
      ;;
      *-Linux*)
        # check libc type
        ABI="gnu"

        if [ -n "${TARGET_ABI}" ]; then
          ABI="${TARGET_ABI}"
        else
          if [ -x "$(which ldd)" ]; then
            ldd --version | grep musl >/dev/null ;
            if [ $? -eq 0 ]; then
              ABI="musl"
            fi
          fi

          case "${UNAME_M}" in
            armv6*|armv7*)
              ABI="${ABI}eabihf"
            ;;
          esac
        fi

        echo "${UNAME_M}-linux-${ABI}"
      ;;
    esac
  else
    if [ "${PYTHONX_LIBPYTHON3_TRIPLET}" = "powerpc64le-linux-gnu" ]; then
      echo "ppc64le-linux-gnu"
    else
      echo "${PYTHONX_LIBPYTHON3_TRIPLET}"
    fi
  fi
}

echo "[+] PYTHONX_LIBPYTHON3_TRIPLET: ${PYTHONX_LIBPYTHON3_TRIPLET}"
PRECOMPILED_LIBPYTHON3_FILENAME="libpython3-${PYTHONX_LIBPYTHON3_TRIPLET}"
if [ "${PYTHONX_LIBPYTHON3_TRIPLET}" = "native" ]; then
  PYTHONX_LIBPYTHON3_TRIPLET="$(get_triplet)"
  PRECOMPILED_LIBPYTHON3_FILENAME="libpython3-${PYTHONX_LIBPYTHON3_TRIPLET}"
fi
PRECOMPILED_LIBPYTHON3_URL="${PRECOMPILED_LIBPYTHON3_URL_BASE}/${PRECOMPILED_LIBPYTHON3_FILENAME}.tar.gz"
PRECOMPILED_LIBPYTHON3_TARBALL="${LIBPYTHON3_CACHE_DIR}/${PRECOMPILED_LIBPYTHON3_FILENAME}.tar.gz"

download_libpython3() {
    if [ ! -f "${PRECOMPILED_LIBPYTHON3_TARBALL}" ]; then
        echo "[+] Downloading precompiled libpython3 ${LIBPYTHON3_VERSION} ${PRECOMPILED_LIBPYTHON3_FILENAME}.tar.gz..."
        mkdir -p "${LIBPYTHON3_CACHE_DIR}"
        if [ -e "$(which wget)" ]; then
            wget --quiet "${PRECOMPILED_LIBPYTHON3_URL}" -O "${PRECOMPILED_LIBPYTHON3_TARBALL}"
        elif [ -e "$(which curl)" ]; then
            curl -fSsL "${PRECOMPILED_LIBPYTHON3_URL}" -o "${PRECOMPILED_LIBPYTHON3_TARBALL}"
        else
            echo "[!] No wget or curl found, please install one of them"
            exit 1
        fi
    fi
}

unarchive_libpython3() {
    if [ ! -d "${PRIV_DIR}/python3" ]; then
        echo "[+] Unarchiving libpython3 ${LIBPYTHON3_VERSION}..."
        mkdir -p "${PRIV_DIR}/python3"
        if [ -e "$(which tar)" ]; then
            tar -xzf "${PRECOMPILED_LIBPYTHON3_TARBALL}" -C "${PRIV_DIR}/python3" ;
        else
            echo "[!] Cannot find tar to unarchive the tarball"
            exit 1
        fi
    fi
}

download_libpython3 && unarchive_libpython3
