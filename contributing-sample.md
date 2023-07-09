# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test openssl https://github.com/VadimDor/asdf-openssl.git "openssl -v"
```

Tests are automatically run in GitHub Actions on push and PR.
