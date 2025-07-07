# Use the official Rust image as a builder
FROM rust:1.87 as builder

# Create app dir
WORKDIR /app

# Copy Cargo.toml and Cargo.lock first
COPY Cargo.toml Cargo.lock ./

# Copy src and data
COPY src ./src
COPY data ./data

# Build the app in release mode
RUN cargo build --release

# Use a small runtime image
FROM debian:buster-slim

WORKDIR /app

# Copy the binary
COPY --from=builder /app/target/release/my-axum-app .

# Copy the data folder
COPY --from=builder /app/data ./data

# Expose the port (match your axum bind port)
EXPOSE 9090

# Run the binary
CMD ["./my-axum-app"]
