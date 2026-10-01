# asdf-clang-tools

[![ci](https://img.shields.io/github/actions/workflow/status/cpp-linter/asdf-clang-tools/build.yml?branch=main&label=ci&labelColor=454a63)](https://github.com/cpp-linter/asdf-clang-tools/actions/workflows/build.yml)
[![part of cpp-linter](https://img.shields.io/badge/part%20of-cpp--linter-ffc20a?labelColor=454a63)](https://cpp-linter.github.io/)

An [asdf](https://asdf-vm.com) plugin that installs `clang-format`, `clang-tidy` and other LLVM tools from the cpp-linter [static binaries](https://github.com/cpp-linter/clang-tools-static-binaries/releases), without building LLVM.

[Website](https://cpp-linter.github.io/) · [Get started](https://cpp-linter.github.io/getting-started/#just-the-clang-tools) · [Discussions](https://github.com/orgs/cpp-linter/discussions)

## Quick start

With asdf 0.16 or later:

```shell
# Add the plugin
asdf plugin add clang-format https://github.com/cpp-linter/asdf-clang-tools.git

# Show all installable versions
asdf list all clang-format

# Install the latest version
asdf install clang-format latest

# Set a version (writes .tool-versions in the current directory; -u writes ~/.tool-versions)
asdf set clang-format latest

# Now clang-format is available
clang-format --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

## Usage

Each tool is a separate plugin. Add it by URL, with the tool name as the plugin name:

| Tool         | Command to add Plugin                                                        |
| ------------ | ---------------------------------------------------------------------------- |
| clang-format | `asdf plugin add clang-format https://github.com/cpp-linter/asdf-clang-tools.git` |
| clang-query  | `asdf plugin add clang-query https://github.com/cpp-linter/asdf-clang-tools.git`  |
| clang-tidy   | `asdf plugin add clang-tidy https://github.com/cpp-linter/asdf-clang-tools.git`   |
| clang-apply-replacements | `asdf plugin add clang-apply-replacements https://github.com/cpp-linter/asdf-clang-tools.git` |
| clang-include-cleaner | `asdf plugin add clang-include-cleaner https://github.com/cpp-linter/asdf-clang-tools.git` |

## Supported versions

Clang versions **12** through **23** are supported. `clang-include-cleaner` is only available from version 18 onward.

Versions are major versions (`21`, not `21.1.0`). `asdf list all <tool>` shows the versions in the latest [clang-tools-static-binaries release](https://github.com/cpp-linter/clang-tools-static-binaries/releases/latest).

## Platforms

- Pre-compiled binaries are provided for:
  - Linux: `amd64` (`x86_64`), `arm64` (`aarch64`)
  - macOS: `amd64` (Intel), `arm64` (Apple Silicon)
- The macOS binaries are ad-hoc signed, not notarized. The plugin downloads them with `curl`, which does not set the quarantine attribute, so they run without a Gatekeeper prompt.

## Dependencies

- `curl`, `jq`
- `sha512sum` or `shasum` (optional, but recommended): checks each download against the release's `SHA512SUMS` file

## Environment variables

- `ASDF_CLANG_TOOLS_LINUX_IGNORE_ARCH`: set to "1" to install the `amd64` binary regardless of the host architecture. This can be useful if you have set up [QEMU User Emulation](https://wiki.debian.org/QemuUserEmulation) (or similar) to run foreign binaries under emulation. Normally, the native `arm64`/`aarch64` Linux binaries are used automatically when detected.
- `GITHUB_TOKEN`: if set, the plugin sends it with the GitHub API request that lists the release's assets, which avoids the lower rate limit for unauthenticated requests (for example in CI).

## Contributing

See the [contributing guide](https://github.com/cpp-linter/asdf-clang-tools/blob/main/CONTRIBUTING.md) and [open an issue](https://github.com/cpp-linter/asdf-clang-tools/issues) for bugs and feature requests.

## License

This project is licensed under the [MIT License](https://github.com/cpp-linter/asdf-clang-tools/blob/main/LICENSE).
