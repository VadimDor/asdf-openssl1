#!/usr/bin/env bats

# shellcheck disable=SC2230

load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash
load ./lib/test_utils

setup_file() {
  PROJECT_DIR="$(realpath "$(dirname "$BATS_TEST_DIRNAME")")"
  export PROJECT_DIR
  cd "$PROJECT_DIR"
  clear_lock git

  ASDF_DIR="$(mktemp -t asdf-openssl-integration-tests.XXXX -d)"
  export ASDF_DIR

  get_lock git
  git clone \
    --branch=v0.10.2 \
    --depth=1 \
    https://github.com/asdf-vm/asdf.git \
    "$ASDF_DIR"
  clear_lock git
}

teardown_file() {
  clear_lock git
  rm -rf "$ASDF_DIR"
}

setup() {
  ASDF_OPENSSL_TEST_TEMP="$(mktemp -t asdf-openssl-integration-tests.XXXX -d)"
  export ASDF_OPENSSL_TEST_TEMP
  ASDF_DATA_DIR="${ASDF_OPENSSL_TEST_TEMP}/asdf"
  export ASDF_DATA_DIR
  mkdir -p "$ASDF_DATA_DIR/plugins"

  # `asdf plugin add openssl .` would only install from git HEAD.
  # So, we install by copying the plugin to the plugins directory.
  cp -R "$PROJECT_DIR" "${ASDF_DATA_DIR}/plugins/openssl"
  cd "${ASDF_DATA_DIR}/plugins/openssl"

  # shellcheck disable=SC1090,SC1091
  source "${ASDF_DIR}/asdf.sh"

  ASDF_OPENSSL_VERSION_INSTALL_PATH="${ASDF_DATA_DIR}/installs/openssl/ref-version-1-6"
  export ASDF_OPENSSL_VERSION_INSTALL_PATH

  # optimization if already installed
  info "asdf install openssl ref:version-1-6"
  if [ -d "${HOME}/.asdf/installs/openssl/ref-version-1-6" ]; then
    mkdir -p "${ASDF_DATA_DIR}/installs/openssl"
    cp -R "${HOME}/.asdf/installs/openssl/ref-version-1-6" "${ASDF_OPENSSL_VERSION_INSTALL_PATH}"
    rm -rf "${ASDF_OPENSSL_VERSION_INSTALL_PATH}/openssl"
    asdf reshim
  else
    get_lock git
    asdf install openssl ref:version-1-6
    clear_lock git
  fi
  asdf local openssl ref:version-1-6
}

teardown() {
  asdf plugin remove openssl || true
  rm -rf "${ASDF_OPENSSL_TEST_TEMP}"
}

info() {
  echo "# ${*} …" >&3
}

@test "openssl_configuration__without_openssldeps" {
  # Assert package index is placed in the correct location
  info "openssl refresh -y"
  get_lock git
  openssl refresh -y
  clear_lock git
  assert [ -f "${ASDF_OPENSSL_VERSION_INSTALL_PATH}/openssl/packages_official.json" ]

  # Assert package installs to correct location
  info "openssl install -y openssljson@1.2.8"
  get_lock git
  openssl install -y openssljson@1.2.8
  clear_lock git
  assert [ -x "${ASDF_OPENSSL_VERSION_INSTALL_PATH}/openssl/bin/openssljson" ]
  assert [ -f "${ASDF_OPENSSL_VERSION_INSTALL_PATH}/openssl/pkgs/openssljson-1.2.8/openssljson.openssl" ]
  assert [ ! -x "./openssldeps/bin/openssljson" ]
  assert [ ! -f "./openssldeps/pkgs/openssljson-1.2.8/openssljson.openssl" ]

  # Assert that shim was created for package binary
  assert [ -f "${ASDF_DATA_DIR}/shims/openssljson" ]

  # Assert that correct openssljson is used
  assert [ -n "$(openssljson -v | grep ' version 1\.2\.8')" ]

  # Assert that openssl finds openssl packages
  echo "import openssljson" >"${ASDF_OPENSSL_TEST_TEMP}/testopenssl.openssl"
  info "openssl c -r \"${ASDF_OPENSSL_TEST_TEMP}/testopenssl.openssl\""
  openssl c -r "${ASDF_OPENSSL_TEST_TEMP}/testopenssl.openssl"
}

@test "openssl_configuration__with_openssldeps" {
  rm -rf openssldeps
  mkdir "./openssldeps"

  # Assert package index is placed in the correct location
  info "openssl refresh"
  get_lock git
  openssl refresh -y
  clear_lock git
  assert [ -f "./openssldeps/packages_official.json" ]

  # Assert package installs to correct location
  info "openssl install -y openssljson@1.2.8"
  get_lock git
  openssl install -y openssljson@1.2.8
  clear_lock git
  assert [ -x "./openssldeps/bin/openssljson" ]
  assert [ -f "./openssldeps/pkgs/openssljson-1.2.8/openssljson.openssl" ]
  assert [ ! -x "${ASDF_OPENSSL_VERSION_INSTALL_PATH}/openssl/bin/openssljson" ]
  assert [ ! -f "${ASDF_OPENSSL_VERSION_INSTALL_PATH}/openssl/pkgs/openssljson-1.2.8/openssljson.openssl" ]

  # Assert that openssl finds openssl packages
  echo "import openssljson" >"${ASDF_OPENSSL_TEST_TEMP}/testopenssl.openssl"
  info "openssl c --opensslPath:./openssldeps/pkgs -r \"${ASDF_OPENSSL_TEST_TEMP}/testopenssl.openssl\""
  openssl c --opensslPath:./openssldeps/pkgs -r "${ASDF_OPENSSL_TEST_TEMP}/testopenssl.openssl"

  rm -rf openssldeps
}
