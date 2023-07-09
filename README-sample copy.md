![build](https://github.com/VadimDor/asdf-openssl/workflows/build/badge.svg) ![lint](https://github.com/VadimDor/asdf-openssl/workflows/lint/badge.svg) [![Join the chat at https://gitter.im/asdf-openssl/community](https://badges.gitter.im/asdf-openssl/community.svg)](https://gitter.im/asdf-openssl/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# asdf-openssl

asdf-openssl allows you to quickly install any version of [Openssl](https://openssl-lang.org).

asdf-openssl is intended for end-users and continuous integration. Whether macOS or Linux, x86 or ARM - all you'll need to install Openssl is bash.

## Installation

[Install asdf](https://asdf-vm.com/guide/getting-started.html), then:

```sh
asdf plugin add openssl # install the asdf-openssl plugin
asdf openssl install-deps  # install system-specific dependencies for downloading & building Openssl
```

### To install Openssl:

When available for the version and platform, the plugin will install pre-compiled binaries of Openssl. If no binaries are available the plugin will build Openssl from source.

```sh
# latest stable version of Openssl
asdf install openssl latest
# or latest stable minor/patch release of Openssl 1.x.x
asdf install openssl latest:1
# or latest stable patch release of Openssl 1.6.x
asdf install openssl latest:1.6
# or specific patch release
asdf install openssl 1.6.8
```

### To install a nightly build of Openssl:

```sh
# nightly unstable build of devel branch
asdf install openssl ref:devel
# or nightly unstable build of version-1-6 branch, i.e. the latest 1.6.x release + any recent backports from devel
asdf install openssl ref:version-1-6
# or nightly unstable build of version-1-4 branch, i.e. the latest 1.4.x release + any recent backports from devel
asdf install openssl ref:version-1-4
# or nightly unstable build of version-1-2 branch, i.e. the 1.2.x release + any recent backports from devel
asdf install openssl ref:version-1-2
# or nightly unstable build of version-1-0 branch, i.e. the 1.0.x release + any recent backports from devel
asdf install openssl ref:version-1-0
```

### To build a specific git commit or branch of Openssl:

```sh
# build using latest commit from the devel branch
asdf install openssl ref:HEAD
# build using the specific commit 7d15fdd
asdf install openssl ref:7d15fdd
# build using the tagged release v1.6.8
asdf install openssl ref:v1.6.8
```

### To set the default version of Openssl for your user:

```sh
asdf global openssl latest:1.6
```

This creates a `.tool-versions` file in your home directory specifying the Openssl version.

### To set the version of Openssl for a project directory:

```sh
cd my-project
asdf local openssl latest:1.6
```

This creates a `.tool-versions` file in the current directory specifying the Openssl version. For additional plugin usage see the [asdf documentation](https://asdf-vm.com/#/core-manage-asdf).

## openssl packages

openssl packages are installed in `~/.asdf/installs/openssl/<openssl-version>/openssl/pkgs`, unless a `openssldeps` directory exists in the directory where `openssl install` is run from.

See the [openssl documentation](https://github.com/openssl-lang/openssl#openssls-folder-structure-and-packages) for more information about openssldeps.

## Continuous Integration

### A simple example using GitHub Actions:

```yaml
name: Build
on:
  push:
    paths-ignore:
      - README.md

env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

jobs:
  build:
    name: Test
    runs-on: ${{ matrix.os }}
    matrix:
      include:
        # Test against stable Openssl builds on linux
        - os: ubuntu-latest
          openssl-version: latest:1.6
        - os: ubuntu-latest
          openssl-version: latest:1.4

        # Test against unstable nightly Openssl builds on macos (faster than building from source)
        - os: macos-latest
          openssl-version: ref:version-1-6
        - os: macos-latest
          openssl-version: ref:version-1-4
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Install Openssl
        uses: asdf-vm/actions/install@v1
        with:
          tool_versions: |
            openssl ${{ matrix.openssl-version }}
      - name: Run tests
        run: |
          asdf local openssl ${{ matrix.openssl-version }}
          openssl develop -y
          openssl test
          openssl examples
```

### Continuous Integration on Non-x86 Architectures

Using [uraimo/run-on-arch-action](https://github.com/uraimo/run-on-arch-action):

```yaml
name: Build
on:
  push:
    paths-ignore:
      - README.md

jobs:
  test_non_x86:
    name: Test openssl-${{ matrix.openssl-version }} / debian-buster / ${{ matrix.arch }}
    strategy:
      fail-fast: false
      matrix:
        include:
          - openssl-version: ref:version-1-6
            arch: armv7
          - openssl-version: ref:version-1-2
            arch: aarch64

    runs-on: ubuntu-latest
    steps:
      - name: Checkout Openssl project
        uses: actions/checkout@v2

      - uses: uraimo/run-on-arch-action@v2
        name: Install Openssl & run tests
        with:
          arch: ${{ matrix.arch }}
          distro: buster

          dockerRunArgs: |
            --volume "${HOME}/.cache:/root/.cache"

          setup: mkdir -p "${HOME}/.cache"

          shell: /usr/bin/env bash

          install: |
            set -uexo pipefail
            # Install asdf and dependencies
            apt-get update -q -y
            apt-get -qq install -y build-essential curl git
            git clone https://github.com/asdf-vm/asdf.git "${HOME}/.asdf" --branch v0.10.2

          env: |
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

          run: |
            set -uexo pipefail
            . "${HOME}/.asdf/asdf.sh"

            # Install asdf-openssl and dependencies
            git clone https://github.com/VadimDor/asdf-openssl.git ~/asdf-openssl --branch main --depth 1
            asdf plugin add openssl ~/asdf-openssl
            asdf openssl install-deps -y

            # Install Openssl
            asdf install openssl ${{ matrix.openssl-version }}
            asdf local openssl ${{ matrix.openssl-version }}

            # Run tests
            openssl develop -y
            openssl test
            openssl examples
```

## Stable binaries

[openssl-lang.org](https://openssl-lang.org/install.html) supplies pre-compiled stable binaries of Openssl for:

Linux:

- `x86_64` (gnu libc)
- `x86` (gnu libc)

## Unstable nightly binaries

[openssl-lang/nightlies](https://github.com/openssl-lang/nightlies) supplies pre-compiled unstable binaries of Openssl for:

Linux:

- `x86_64` (gnu libc)
- `x86` (gnu libc)
- `aaarch64` (gnu libc)
- `armv7l` (gnu libc)

macOS:

- `x86_64`

## Updating asdf and asdf-openssl

```sh
asdf update
asdf plugin update openssl main
```

## Contributing

Pull requests are welcome!

Fork this repo, then run:

```sh
rm -rf ~/.asdf/plugins/openssl
git clone git@github.com:<your-username>/asdf-openssl.git ~/.asdf/plugins/openssl
```

### Testing

This project uses [bats](https://github.com/bats-core/bats-core) for unit testing. Please follow existing patterns and add unit tests for your changeset. Dev dependencies for unit tests are installed via:

```shell
cd ~/.asdf/plugins/openssl
npm install --include=dev
```

Run tests with:

```sh
npm run test
```

### Linting

This project uses [lintball](https://github.com/elijahr/lintball) to auto-format code. Please ensure your changeset passes linting. Enable the githooks with:

```sh
git config --local core.hooksPath .githooks
```
