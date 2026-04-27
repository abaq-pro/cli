# abaq

Read-only CLI for the ABAQ accounting platform — advisor tooling that talks to
the ABAQ GraphQL API and can also serve as a local MCP backend for Claude Desktop.

The source lives in a private repository; this repo only hosts the published
binaries and the install script.

## Install (one-liner)

```sh
curl -fsSL https://raw.githubusercontent.com/abaq-pro/cli/main/install.sh | sh
```

The script detects your OS and CPU architecture, downloads the matching
archive from this repo's [latest release](https://github.com/abaq-pro/cli/releases/latest),
verifies its SHA-256 against `checksums.txt`, and installs the binary to
`~/.local/bin/abaq`.

Optional environment variables:

| Variable      | Default          | Purpose                              |
|---------------|------------------|--------------------------------------|
| `INSTALL_DIR` | `~/.local/bin`   | Where to drop the binary             |
| `VERSION`     | latest stable    | Pin to a specific tag, e.g. `v0.1.0` |

If `~/.local/bin` is not on your `PATH`, the script tells you the line to add
to your shell rc.

## Install (manual)

Download the right archive from
[Releases](https://github.com/abaq-pro/cli/releases/latest), unpack it, and
put the `abaq` binary somewhere on your `PATH`.

| OS      | Arch          | Archive                                  |
|---------|---------------|------------------------------------------|
| macOS   | Apple Silicon | `abaq_<version>_darwin_arm64.tar.gz`     |
| macOS   | Intel         | `abaq_<version>_darwin_amd64.tar.gz`     |
| Linux   | amd64         | `abaq_<version>_linux_amd64.tar.gz`      |
| Linux   | arm64         | `abaq_<version>_linux_arm64.tar.gz`      |
| Windows | amd64         | `abaq_<version>_windows_amd64.zip`       |
| Windows | arm64         | `abaq_<version>_windows_arm64.zip`       |

Verify the SHA-256 against `checksums.txt` from the same release.

## Quickstart

```sh
abaq login
abaq whoami
abaq describe
```

## Update

```sh
abaq update
```

The CLI checks this repository for a newer release and replaces its own
binary in place. Use `abaq update --check` to only report whether a newer
version is available.
