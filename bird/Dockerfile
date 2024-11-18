# Use a Golang base image
FROM golang:1.22.5-alpine AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go Modules manifests
COPY go.mod ./

# Download all dependencies. Dependencies will be cached if the go.mod file is not changed
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN go build -o getBird

# Start a new stage from scratch
FROM alpine:latest

# Add a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/getBird .

# Change ownership of the binary
RUN chown appuser:appgroup /app/getBird

# Use a non-root user to run the application
USER appuser

# Expose port 4201 to the outside world
EXPOSE 4201

# Command to run the executable
CMD ["./getBird"]
