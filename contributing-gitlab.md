# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

# TODO: adapt this
asdf plugin test openssl https://gitlab.com/<YOUR GITLAB USERNAME>/asdf-openssl.git "openssl --version"
```

Tests are automatically run in GitLab CI on push and merge request.
