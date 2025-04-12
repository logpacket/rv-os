# rv-os

A bare-metal operating system for ARM64 architecture.

## Overview

rv-os is a lightweight, bare-metal operating system targeting ARM64 (aarch64) architectures. This project aims to provide a minimal OS implementation for educational and experimental purposes.

## Features

- Bare-metal implementation for ARM64 architecture
- Custom boot sequence
- Minimal runtime environment

## Project Structure

- `src/`: Source code
  - `main.rs`: Main entry point
  - `boot/`: Boot related code
    - `arm_entry.S`: ARM entry point
    - `boot_header.S`: Boot header definitions
    - `boot.S`: Boot sequence implementation
    - `vectors.S`: Exception vectors

## Building

This project uses Rust and requires the nightly toolchain with the `aarch64-unknown-none` target.

```bash
# Install required Rust components
rustup toolchain install nightly
rustup component add rust-src --toolchain nightly
rustup target add aarch64-unknown-none

# Build the project
cargo build --target aarch64-unknown-none
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
