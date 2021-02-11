FROM rustlang/rust:nightly-buster AS builder
# ref. https://github.com/rust-lang/docker-rust-nightly

WORKDIR /app

COPY ./Cargo.toml ./Cargo.lock ./

# minimum compilable main.rs
RUN mkdir src
RUN echo "fn main(){}" > src/main.rs
RUN cargo build --release
RUN rm -f target/release/deps/rocket_template_app*

COPY ./src ./src
COPY ./migrations ./migrations
RUN cargo build --release

FROM debian:10.6-slim

RUN apt-get update -qq \
  && apt-get install -y libpq-dev

WORKDIR /app

COPY --from=builder /app/target/release/rocket-template-app /app/target/release/rocket-template-app
COPY ./public /app/public

CMD ROCKET_PORT=$PORT /app/target/release/rocket-template-app
