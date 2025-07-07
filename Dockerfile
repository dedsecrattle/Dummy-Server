# ---- Build stage ----
FROM rust:1.87 as builder

WORKDIR /app

# Copy manifests first to leverage Docker layer caching
COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY data ./data

# Build in release mode
RUN cargo build --release

# ---- Runtime stage ----
FROM debian:buster-slim

WORKDIR /app

# Copy the compiled binary from the builder
COPY --from=builder /app/target/release/dummy-cruncy-server .

# Copy your data files
COPY --from=builder /app/data ./data

# Expose your app port
EXPOSE 9090

# Run the server
CMD ["./dummy-cruncy-server"]
