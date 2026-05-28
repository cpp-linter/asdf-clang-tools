# Contributing

Contributions of any kind are welcome! This guide will help you get started.

## Development Setup

1. Install [asdf](https://asdf-vm.com) if you haven't already.
2. Clone the repo and set up the plugin locally:

   ```shell
   git clone https://github.com/cpp-linter/asdf-clang-tools.git
   cd asdf-clang-tools
   ```

3. Install the development dependencies:

   ```shell
   # Install shellcheck (for linting shell scripts)
   # macOS:
   brew install shellcheck shfmt jq

   # Linux (Debian/Ubuntu):
   sudo apt-get install shellcheck jq

   # Install shfmt:
   go install mvdan.cc/sh/v3/cmd/shfmt@latest
   ```

4. Set up pre-commit hooks:

   ```shell
   # Install pre-commit if not already installed
   pip install pre-commit
   # or: brew install pre-commit

   pre-commit install
   ```

## Testing Locally

Use the asdf plugin test command to verify your changes:

```shell
# Basic test
asdf plugin test clang-tools https://github.com/cpp-linter/asdf-clang-tools.git "clang-format --version"

# Test a specific version
asdf plugin test clang-tools https://github.com/cpp-linter/asdf-clang-tools.git --asdf-tool-version 18 "clang-tidy --version"

# Test with all supported tools
asdf plugin test clang-tools https://github.com/cpp-linter/asdf-clang-tools.git "clang-format --version && clang-tidy --version && clang-query --version"
```

For local development, you can also test by adding the plugin from your local path:

```shell
asdf plugin add clang-format .
asdf install clang-format latest
asdf set clang-format latest
clang-format --version
```

## Code Style

This project follows these conventions:

- **Shell scripts**: All scripts in `bin/` and `lib/` are written in Bash.
- **Formatting**: Use [shfmt](https://github.com/mvdan/sh) for consistent formatting:

  ```shell
  ./scripts/shfmt.bash
  ```

- **Linting**: Use [shellcheck](https://www.shellcheck.net) to catch issues:

  ```shell
  ./scripts/shellcheck.bash
  ```

- **EditorConfig**: The project includes an `.editorconfig` — make sure your editor supports it. Key settings:
  - 2-space indentation
  - UTF-8 encoding
  - Trim trailing whitespace
  - Insert final newline

- **Pre-commit hooks** automatically check for trailing whitespace, missing EOF newlines, large files, and valid YAML.

## Project Structure

```
.
├── bin/              # asdf plugin scripts (download, install, list-all, etc.)
├── lib/              # Shared Bash utilities
├── scripts/          # Development helper scripts (linting, formatting)
├── .github/          # GitHub Actions workflows and templates
├── .pre-commit-config.yaml
├── .editorconfig
└── .tool-versions    # asdf tool versions for this project
```

## Pull Request Process

1. **Create a branch**: Use a descriptive branch name (e.g., `feature/add-version-23`, `fix/macos-arm64-error`).
2. **Make your changes**: Follow the code style guidelines above.
3. **Test your changes**: Run tests locally to make sure everything works.
4. **Run linting**: Ensure `shellcheck` and `shfmt` pass.
5. **Submit a PR**: Push your branch and open a pull request. Fill out the PR template with:
   - A description of your changes
   - Motivation and context
   - Types of changes (bug fix, feature, breaking change)
   - How you tested the changes
6. **CI checks**: Your PR will trigger automated builds and lint checks via GitHub Actions.
7. **Review**: A maintainer will review your PR. Please be responsive to feedback.

## Release Process

Releases are managed by [release-please](https://github.com/googleapis/release-please). The workflow:
  - On each push to `main`, release-please opens/updates a release PR.
  - When that PR is merged, a new release is created.

## Questions?

Feel free to open an issue if you have questions or run into problems.
