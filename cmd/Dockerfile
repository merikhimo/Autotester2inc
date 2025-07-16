FROM golang:1.23-alpine AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
RUN go mod tidy

COPY . .
RUN go build -o autotester ./cmd/main.go

# Сразу положим скрипт в корень builder‑стадии
COPY cmd/wait-for-postgres.sh ./wait-for-postgres.sh
RUN chmod +x ./wait-for-postgres.sh

FROM alpine:latest
WORKDIR /app

# Бинарь, конфиги
COPY --from=builder /app/autotester .
COPY --from=builder /app/configs ./configs

# Скрипт из builder
COPY --from=builder /wait-for-postgres.sh .
RUN apk add --no-cache bash postgresql-client

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

RUN ls -al /app
CMD ["./wait-for-postgres.sh", "postgres", "5432", "./autotester"]