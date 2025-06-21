# Используем минимальный образ с Go
FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . .

RUN go build -o autotester ./cmd/main.go

# Финальный минимальный образ
FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/autotester .
COPY --from=builder /app/configs ./configs
COPY --from=builder /app/.env .env

ENV TIMEOUT=3
ENV PYTHON_API_URL=http://python-api:3000
ENV FRONTEND_URL=http://frontend:3001

EXPOSE 8081

CMD ["./autotester"]