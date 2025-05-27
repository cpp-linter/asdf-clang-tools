# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test clang-tools https://github.com/cpp-linter/asdf-clang-tools.git "clang-format"
```

Tests are automatically run in GitHub Actions on push and PR.
