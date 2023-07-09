<div align="center">

# asdf-openssl ![Build Status](https://gitlab.com/<YOUR GITLAB USERNAME>/asdf-openssl/badges/main/pipeline.svg)

[openssl](https://github.com/VadimDor/openssl) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add openssl
# or
asdf plugin add https://gitlab.com/<YOUR GITLAB USERNAME>/asdf-openssl.git
```

openssl:

```shell
# Show all installable versions
asdf list-all openssl

# Install specific version
asdf install openssl latest

# Set a version globally (on your ~/.tool-versions file)
asdf global openssl latest

# Now openssl commands are available
openssl --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://gitlab.com/<YOUR GITLAB USERNAME>/asdf-openssl/-/graphs/main)!

# License

See [LICENSE](LICENSE) © [Vadim Dor](https://gitlab.com/<YOUR GITLAB USERNAME>/)
