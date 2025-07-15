FROM golang:1.23-alpine AS builder

WORKDIR /app

# First copy only the files needed for dependencies
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# Copy all remaining files (including the wait script)
COPY . .

# Build the application
RUN go build -o autotester ./cmd/main.go

FROM alpine:latest

WORKDIR /app

# Copy built binary and configs
COPY --from=builder /app/autotester .
COPY --from=builder /app/configs ./configs

# Copy the wait script directly from host
COPY wait-for-postgres.sh .

# Install dependencies
RUN apk add --no-cache bash postgresql-client && \
    chmod +x wait-for-postgres.sh

ENV TIMEOUT=3 \
    PYTHON_API_URL=http://python-api:3000 \
    FRONTEND_URL=http://frontend:3001 \
    DB_HOST=postgres \
    DB_PORT=5432 \
    DB_USER=postgres \
    DB_PASSWORD=password \
    DB_NAME=autotester \
    JWT_SECRET=your_strong_secret_here

EXPOSE 8081

CMD ["./wait-for-postgres.sh", "postgres", "5432", "./autotester"]