FROM rust:latest AS builder
WORKDIR /sources

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y libclang-dev

# build cargo deps before copying sources (for caching)
COPY Cargo.lock Cargo.toml ./
RUN mkdir -p src/ \
	&& echo 'fn main() {}' >src/main.rs \
	&& cargo build --release \
	&& rm -rf src

COPY . .
RUN cargo build --release
RUN chown nobody:nogroup /sources/target/release/bin

FROM debian:bullseye as runtime
USER nobody
COPY --from=builder --chown=nobody:nogroup /sources/target/release/bin /pastebin

ENTRYPOINT ["/pastebin", "0.0.0.0:8000"]
