#!/usr/bin/env bash

set -euo pipefail

# Settings
ASDF_CLANG_TOOLS_MACOS_DEQUARANTINE=${ASDF_CLANG_TOOLS_MACOS_DEQUARANTINE:-0}
ASDF_CLANG_TOOLS_LINUX_IGNORE_ARCH=${ASDF_CLANG_TOOLS_LINUX_IGNORE_ARCH:-0}

GH_REPO="cpp-linter/clang-tools-static-binaries"
PLUGIN_NAME="clang-tools"
USE_KERNEL=
USE_ARCH=
USE_PLATFORM=
YES_REGEX='^[Yy](E|e)?(S|s)?$'

fail() {
  echo -e "asdf-$PLUGIN_NAME: $*"
  exit 1
}

validate_deps() {

  deps=(jq curl)

  for d in "${deps[@]}"; do
    if ! command -v "$d" >/dev/null; then
      fail "Required dependency '$d' not found."
    fi
  done
}

log() {
  echo -e "asdf-$PLUGIN_NAME: $*"
}

curl_opts=(-fsSL)

# NOTE: no Authorization header here on purpose. GitHub's browser_download_url
# (used below to fetch the actual asset) returns 404 if a token is sent with
# the request, even for public repos/assets. The GitHub API calls in
# fetch_all_assets() authenticate separately, since that's where the token is
# actually needed to avoid unauthenticated rate limits.

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

fetch_all_assets() {
  # Build API-specific curl options without -f so we can read the error body
  local api_curl_opts=(-sSL)
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    api_curl_opts+=(-H "Authorization: token $GITHUB_TOKEN")
  fi

  local response attempt
  for attempt in 1 2 3; do
    response=$(curl "${api_curl_opts[@]}" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/${GH_REPO}/releases")

    if echo "$response" | jq -e 'type == "array"' >/dev/null 2>&1; then
      echo "$response" | jq -r '.[0].assets[] | "\(.name) \(.browser_download_url)"'
      return 0
    fi

    local msg
    msg=$(echo "$response" | jq -r '.message // "unexpected response"' 2>/dev/null || echo "invalid JSON")
    log "GitHub API error (attempt $attempt/3): $msg"

    if [ "$attempt" -lt 3 ]; then
      log "Retrying in $((attempt * 15))s..."
      sleep "$((attempt * 15))"
    fi
  done

  fail "GitHub API error after 3 attempts: $msg"
}

validate_platform() {
  if [ -n "$USE_PLATFORM" ]; then
    return
  fi

  local kernel arch
  kernel=$(uname -s)
  arch=$(uname -m)

  case $kernel in
  Darwin)
    case $arch in
    arm64)
      USE_KERNEL=macos
      USE_ARCH=arm64
      ;;
    x86_64)
      USE_KERNEL=macos
      USE_ARCH=amd64
      ;;
    esac
    ;;
  Linux)
    USE_KERNEL=linux
    if [ "$ASDF_CLANG_TOOLS_LINUX_IGNORE_ARCH" != 0 ]; then
      USE_ARCH=amd64
      log "ASDF_CLANG_TOOLS_LINUX_IGNORE_ARCH is set - using '$USE_ARCH' binary."
    else
      case $arch in
      x86_64)
        USE_ARCH=amd64
        ;;
      arm64 | aarch64)
        USE_ARCH=arm64
        ;;
      esac
    fi
    ;;
  MINGW* | MSYS* | CYGWIN*)
    USE_KERNEL=windows
    case $arch in
    x86_64)
      USE_ARCH=amd64
      ;;
    arm64 | aarch64)
      USE_ARCH=arm64
      ;;
    esac
    ;;
  esac

  if [ -z "${USE_KERNEL}" ] || [ -z "${USE_ARCH}" ]; then
    local msg="Unsupported platform '${kernel}-${arch}'."
    if [ "$USE_KERNEL" = "linux" ]; then
      msg="${msg}\n\nSee the 'ASDF_CLANG_TOOLS_LINUX_IGNORE_ARCH' setting."
    fi

    fail "$msg"
  fi

  USE_PLATFORM="${USE_KERNEL}-${USE_ARCH}"
}

list_all_versions() {

  validate_platform

  local toolname=$1

  fetch_all_assets |
    grep "$toolname" |
    grep "$USE_PLATFORM" |
    grep -v "sha" |
    awk '{print $1}' |
    sed "s/^${toolname}-\(.*\)_.*/\1/"
}

download_release() {
  local toolname version url asset_pattern
  toolname="$1"
  version="$2"

  validate_platform

  # Windows assets have an .exe extension
  if [ "$USE_KERNEL" = "windows" ]; then
    asset_pattern="^${toolname}-${version}_${USE_PLATFORM}.exe\s"
  else
    asset_pattern="^${toolname}-${version}_${USE_PLATFORM}\s"
  fi

  # TODO: split output without piping to awk
  url=$(fetch_all_assets |
    grep "$asset_pattern" |
    awk '{print $2}')

  (
    cd "${ASDF_DOWNLOAD_PATH}" || exit 1

    echo "* Downloading $toolname release $version..."
    curl "${curl_opts[@]}" -O "$url" || fail "Could not download $url"
    # TODO: range request ('-C -') does not seem to work

    # clang-tools-static-binaries no longer publishes a per-binary
    # <asset>.sha512sum sidecar file; it publishes one SHA512SUMS file per
    # release instead (cpp-linter/clang-tools-static-binaries#119). Fetch
    # that and pull out just this asset's line, in the same format
    # check_shasum() already expects.
    local asset sums_url
    asset=$(basename "$url")
    sums_url="${url%/*}/SHA512SUMS"
    curl "${curl_opts[@]}" -o SHA512SUMS "$sums_url" || fail "Could not download $sums_url"
    grep -F "  $asset" SHA512SUMS >"${asset}.sha512sum" || fail "Checksum for $asset not found in $sums_url"
    rm -f SHA512SUMS
  )
}

check_shasum() {
  local sha_cmd

  if command -v sha512sum >/dev/null; then
    sha_cmd=(sha512sum)
  elif command -v shasum >/dev/null; then
    sha_cmd=(shasum -a 512)
  else
    log "WARNING: sha512sum/shasum program not found - unable to checksum. Proceed with caution."
    return 0
  fi

  (
    log "Checking sha512 sum..."
    cd "${ASDF_DOWNLOAD_PATH}" || exit 1
    "${sha_cmd[@]}" -c ./*.sha512sum
  )
}

install_version() {
  local toolname="$1"
  local install_type="$2"
  local version="$3"
  local install_path="$4"

  validate_platform

  if [ "$install_type" != "version" ]; then
    fail "asdf-$PLUGIN_NAME supports release installs only"
  fi

  check_shasum

  (
    local asset_path full_tool_cmd tool_cmd
    asset_path="$install_path/assets"

    mkdir -p "$asset_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$asset_path"

    # TODO: detect this instead of hard-coding in case the format changes?
    full_tool_cmd=${toolname}-${version}_${USE_PLATFORM}
    # Windows assets have an .exe extension
    if [ "$USE_KERNEL" = "windows" ]; then
      full_tool_cmd="${full_tool_cmd}.exe"
    fi
    tool_cmd="$(echo "$toolname" | cut -d' ' -f1)"

    chmod +x "${asset_path}/${full_tool_cmd}"

    mkdir -p "${install_path}/bin" || true
    # Use cp on Windows where symlinks may not work
    if [ "$USE_KERNEL" = "windows" ]; then
      cp "${asset_path}/${full_tool_cmd}" "$install_path/bin/$tool_cmd"
    else
      ln -s "${asset_path}/${full_tool_cmd}" "$install_path/bin/$tool_cmd"
    fi

    if [ "$USE_KERNEL" == "macosx" ]; then
      if [ "$ASDF_CLANG_TOOLS_MACOS_DEQUARANTINE" != 1 ]; then
        log "$toolname needs to be de-quarantined to run:\n\n"
        echo -e "  xattr -dr com.apple.quarantine \"${asset_path}/${full_tool_cmd}\""
        echo -e -n "\n\nProceed? [y/N] "
        read -r reply
        if [[ $reply =~ $YES_REGEX ]]; then
          ASDF_CLANG_TOOLS_MACOS_DEQUARANTINE=1
        else
          exit 1
        fi

        if [ "$ASDF_CLANG_TOOLS_MACOS_DEQUARANTINE" == 1 ]; then
          xattr -dr com.apple.quarantine "${asset_path}/${full_tool_cmd}"
        fi
      fi
    fi

    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

    echo "$toolname $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $toolname $version."
  )
}
