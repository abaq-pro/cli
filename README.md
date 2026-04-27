# abaq

Read-only CLI for the ABAQ accounting platform — advisor tooling that talks to
the ABAQ GraphQL API and can also serve as a local MCP backend for Claude Desktop.

The source lives in a private repository; this repo only hosts the published
binaries.

## Install (manual)

Download the archive matching your OS/arch from
[Releases](https://github.com/abaq-pro/cli/releases/latest), unpack it, and put
the `abaq` binary somewhere on your `PATH`.

| OS      | Arch         | Archive                                    |
|---------|--------------|--------------------------------------------|
| macOS   | Apple Silicon | `abaq_<version>_darwin_arm64.tar.gz`       |
| macOS   | Intel        | `abaq_<version>_darwin_amd64.tar.gz`       |
| Linux   | amd64        | `abaq_<version>_linux_amd64.tar.gz`        |
| Linux   | arm64        | `abaq_<version>_linux_arm64.tar.gz`        |
| Windows | amd64        | `abaq_<version>_windows_amd64.zip`         |
| Windows | arm64        | `abaq_<version>_windows_arm64.zip`         |

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

Checks this repository for a newer release and replaces the binary in place.
