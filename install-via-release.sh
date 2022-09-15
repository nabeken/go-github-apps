#!/bin/bash
#
# This script downloads a binary of `go-github-apps` into the current working directory with adding execution bit.
# After that, you can move the binary to an arbitrary directory like /usr/local/bin.
#

VERSION=

usage() {
  echo "usage: $0 -v VERSION" >&2
}

get_arch() {
  case "$(uname -m)" in
    aarch64|arm64)
      echo "arm64"
      ;;
    x86_64)
      echo "amd64"
      ;;
    *)
      echo "Currently $(uname -m) isn't supported. PR is welcome." >&2
      exit 1
      ;;
  esac
}

get_os() {
  case "$(uname -s)" in
    Linux)
      echo linux
      ;;
    Darwin)
      echo darwin
      ;;
    *)
      echo "Currently $(uname -s) isn't supported. PR is welcome." >&2
      exit 1
      ;;
  esac
}

while getopts hv: OPT; do
  case $OPT in
    v)
      VERSION=$OPTARG
      ;;
    *|h) usage; exit 1 ;;
  esac
done

if [ -z "${VERSION}" ]; then
  echo "Please specify VERSION via -v" >&2
  echo
  usage
  exit 1
fi

BASE_URL="https://github.com/nabeken/go-github-apps/releases/download/${VERSION}"
URL="${BASE_URL}/go-github-apps_${VERSION#v}_$(get_os)_$(get_arch).tar.gz"

shift $((OPTIND - 1))

DIR=$(mktemp -d)
trap "rm -rf '${DIR}'" EXIT 1 2 3 15

pushd $DIR > /dev/null
echo "Downloading ${URL} into ${DIR}" >&2
  curl --fail -sSL -O "${URL}"
  if [ $? -ne 0 ]; then
    echo "unable to download via Github Releases" >&2
    exit 1
  fi
popd > /dev/null

FN="$(basename ${URL})"
tar xvf "${DIR}/${FN}" go-github-apps || exit 1
