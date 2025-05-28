<div align="center">

# asdf-clang-tools [![Build](https://github.com/cpp-linter/asdf-clang-tools/actions/workflows/build.yml/badge.svg)](https://github.com/cpp-linter/asdf-clang-tools/actions/workflows/build.yml) [![Lint](https://github.com/cpp-linter/asdf-clang-tools/actions/workflows/lint.yml/badge.svg)](https://github.com/cpp-linter/asdf-clang-tools/actions/workflows/lint.yml)

[clang-tools](https://github.com/cpp-linter/asdf-clang-tools) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Overview

This is an asdf plugin for installing several clang tools:

- clang-format
- clang-tidy
- clang-query
- clang-apply-replacements

This plugin uses the pre-compiled binaries from the very handy [cpp-linter/clang-tools-static-binaries](https://github.com/cpp-linter/clang-tools-static-binaries) repo.

## Caveats

- Again, the source for these binaries is currently [cpp-linter/clang-tools-static-binaries](https://github.com/cpp-linter/clang-tools-static-binaries). Please make sure you trust that repository.
- Only Intel (`x86_64`/`amd64`) binaries are currently provided.
  - These binaries do work on macOS with Apple Silicon, but they will run under Rosetta.
- Signed binaries are not provided for macOS. This plugin will offer to de-quarantine the binaries for you, but please make sure you understand the consequences.

# Dependencies

- `curl`, `jq`
- `sha512sum` (optional, but recommended)

# Install

Plugin:

| Tool         | Command to add Plugin                                                        |
| ------------ | ---------------------------------------------------------------------------- |
| clang-format | `asdf plugin add clang-format https://github.com/cpp-linter/asdf-clang-tools.git` |
| clang-query  | `asdf plugin add clang-query https://github.com/cpp-linter/asdf-clang-tools.git`  |
| clang-tidy   | `asdf plugin add clang-tidy https://github.com/cpp-linter/asdf-clang-tools.git`   |
| clang-apply-replacements | `asdf plugin add clang-apply-replacements https://github.com/cpp-linter/asdf-clang-tools.git` |

Example:

```shell
asdf plugin add clang-format https://github.com/cpp-linter/asdf-clang-tools.git
```

clang-format:

```shell
# Show all installable versions
asdf list all clang-format

# Install specific version
asdf install clang-format latest

# Set a version (on your ~/.tool-versions file)
asdf set clang-format latest

# Now clang-tools commands are available
clang-format
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Configuration

## Environment Variables

- `ASDF_CLANG_TOOLS_MACOS_DEQUARANTINE`: set to "1" to automatically de-quarantine binaries. Otherwise, it will interactively ask to do so.
- `ASDF_CLANG_TOOLS_LINUX_IGNORE_ARCH`: set to "1" to install the `amd64` binary regardless of the host architecture. The [clang-tools](https://github.com/cpp-linter/clang-tools-static-binaries) project does not currently provide `arm64`/`aarch64` Linux binaries. This assumes that you have set up [QEMU User Emulation](https://wiki.debian.org/QemuUserEmulation) (or similar) to run foreign binaries under emulation.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

# License

See [LICENSE](LICENSE)
