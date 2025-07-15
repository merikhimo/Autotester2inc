package configs

import (
	"log"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

// Config holds application configuration.
type Config struct {
	Rights      string
	Timeout     time.Duration
	PythonPath  string
	FrontendURL string

	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string

	JWTSecret  string
	JWTExpiry  time.Duration
}

// LoadConfig loads configuration from environment.
func LoadConfig() *Config {
	err := godotenv.Load(".env")
	if err != nil {
		log.Println("Error loading .env file, using default config")
	}
	return &Config{
		Rights: os.Getenv("RIGHTS"),
		Timeout: func() time.Duration {
			timeout := os.Getenv("TIMEOUT")
			intTimeout, _ := strconv.Atoi(timeout)
			return time.Duration(intTimeout) * time.Second
		}(),
		PythonPath:  os.Getenv("PYTHON_API_URL"),
		FrontendURL: os.Getenv("FRONTEND_URL"),

		DBHost:     getEnv("DB_HOST", "postgres"),
		DBPort:     getEnv("DB_PORT", "5432"),
		DBUser:     getEnv("DB_USER", "postgres"),
		DBPassword: getEnv("DB_PASSWORD", ""),
		DBName:     getEnv("DB_NAME", "autotester"),

		JWTSecret: getEnv("JWT_SECRET", "default-secret-key"),
		JWTExpiry: func() time.Duration {
			return time.Duration(getEnvAsInt("JWT_EXPIRY_HOURS", 24)) * time.Hour
		}(),
	}
}

func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	if value, exists := os.LookupEnv(key); exists {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}