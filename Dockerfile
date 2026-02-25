# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
# CGO_ENABLED=0 for a static binary, -ldflags="-s -w" to reduce size
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o main .

# Final stage
FROM alpine:3.19

# Install tzdata to support time zone lookups
RUN apk add --no-cache tzdata

# Add a non-root user for security
RUN adduser -D appuser
WORKDIR /app

# Copy the binary from the builder
COPY --from=builder /app/main .

# Use the non-root user
USER appuser

EXPOSE 1001

# Run the binary
CMD ["./main"]
